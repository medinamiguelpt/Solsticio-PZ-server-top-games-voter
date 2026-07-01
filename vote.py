"""
Solsticio PZ server — top-games.net auto-voter (Cloudflare Turnstile bypass).

Why nodriver: the vote page is protected by Cloudflare Turnstile, which instantly
fails ordinary Selenium/Playwright/CDP automation. nodriver launches Chrome
WITHOUT the automation tells (no navigator.webdriver, no --enable-automation),
so Turnstile's "managed" challenge passes like a human.

Exit codes:
  0 = vote submitted & confirmed
  1 = on cooldown (normal; too soon to vote again)
  2 = Turnstile never issued a token (captcha not passed)
  3 = unexpected error / not configured
"""

import datetime
import json
import os
import pathlib
import re
import sys

import nodriver as uc
from nodriver import cdp

# ===== MAINTAINER ONLY — the vote link (changes each new season) =====
# Normal users do NOT touch this. To set your name, edit "username.txt".
VOTE_URL = ("https://es.top-games.net/project-zomboid/vote/"
            "esp-x-latam-la-frontera-b42-pvx-solsticio-pz-server")
# =====================================================================

BASE = pathlib.Path(__file__).resolve().parent
PROFILE_DIR = BASE / "chrome-profile"   # dedicated profile (auto-created)
LOG_FILE = BASE / "vote.log"
SHOT_FILE = BASE / "last-run.png"
TOKEN_WAIT_SECONDS = 35


def _load_username() -> str:
    """Read the voter name from username.txt (first real line)."""
    try:
        for line in (BASE / "username.txt").read_text(
                encoding="utf-8").splitlines():
            s = line.strip()
            if s and not s.startswith("#"):
                return s
    except FileNotFoundError:
        pass
    return "YOUR_USERNAME_HERE"


USERNAME = _load_username()


def _find_chrome():
    """Locate a real Chrome (or Brave) binary. Returns None to let nodriver
    auto-detect."""
    cands = [
        r"%ProgramFiles%\Google\Chrome\Application\chrome.exe",
        r"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe",
        r"%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe",
        r"%ProgramFiles%\BraveSoftware\Brave-Browser\Application\brave.exe",
        r"%ProgramFiles(x86)%\BraveSoftware\Brave-Browser\Application\brave.exe",
    ]
    for c in cands:
        p = os.path.expandvars(c)
        if pathlib.Path(p).exists():
            return p
    return None


CHROME = _find_chrome()


def log(msg: str) -> None:
    line = f"{datetime.datetime.now():%Y-%m-%d %H:%M:%S}  {msg}"
    print(line, flush=True)
    with open(LOG_FILE, "a", encoding="utf-8") as fh:
        fh.write(line + "\n")


async def get_token_len(tab) -> int:
    """Length of the Cloudflare token (Cloudflare's own field)."""
    return await tab.evaluate(
        "(function(){var e=document.querySelector("
        "'input[name=\"cf-turnstile-response\"]');"
        "return e ? (e.value||'').length : 0;})()"
    )


async def vote_ready(tab) -> bool:
    """Real submit-ready signal: the site's callback copied the token into
    #cloudflareToken AND enabled #btnSubmitVote. Clicking before this is a
    silent no-op (disabled submit buttons don't submit)."""
    return await tab.evaluate(
        "(function(){var b=document.querySelector('#btnSubmitVote');"
        "var t=document.querySelector('#cloudflareToken');"
        "return !!(b && !b.disabled && t && (t.value||'').length>0);})()"
    )


async def is_on_cooldown(tab) -> bool:
    """True only when the cooldown view is showing."""
    return await tab.evaluate(
        "/antes de que puedas votar de nuevo|Por favor, espera|"
        "Debes ser paciente/i.test(document.body.innerText)"
    )


async def get_cooldown_seconds(tab) -> int:
    """Parse the remaining cooldown (e.g. '105m 3s' or '1h 45m') into seconds.
    Retries a few times because the countdown renders a moment after load.
    Returns 0 if it can't be read."""
    for _ in range(5):
        raw = await tab.evaluate(
            "(function(){var m=document.body.innerText.match("
            "/esperar\\s+([0-9hms\\s]+?)\\s+antes de que puedas votar/i);"
            "return m?m[1].trim():'';})()"
        )
        total = 0
        for val, unit in re.findall(r"(\d+)\s*([hms])", (raw or "").lower()):
            v = int(val)
            total += v * 3600 if unit == "h" else v * 60 if unit == "m" else v
        if total > 0:
            return total
        await tab.sleep(1)
    return 0


async def wait_for_page_ready(tab, timeout: int = 45) -> bool:
    """Wait past the Cloudflare interstitial ('Just a moment...') until the REAL
    vote page is loaded — i.e. the form is present OR the cooldown view is shown.
    nodriver clears the interstitial on its own; we just have to wait for it."""
    deadline = timeout
    while deadline > 0:
        raw = await tab.evaluate(
            "(function(){"
            "var t=document.body?document.body.innerText:'';"
            "var d=(document.title||'')+' '+t;"
            "var inter=/just a moment|checking your browser|performing security "
            "verification|un momento|comprobando tu navegador|verificando/i.test(d);"
            "var form=!!document.querySelector('#btnSubmitVote')||"
            "!!document.querySelector('#playername');"
            "var cd=/antes de que puedas votar de nuevo|Debes ser paciente/i.test(t);"
            "return JSON.stringify({inter:inter, ready:((!inter)&&(form||cd))});})()"
        )
        try:
            st = json.loads(raw)
        except Exception:
            st = {}
        if st.get("ready"):
            return True
        await tab.sleep(1.5)
        deadline -= 1.5
    return False


async def set_username(tab, name: str) -> str:
    """Set #playername robustly and return the value actually in the field.
    Done LAST (right before submit) because the Turnstile callback re-renders
    the form and can wipe an earlier value."""
    try:
        f = await tab.select("#playername")
        await f.clear_input()
        await f.send_keys(name)
    except Exception as e:
        log(f"  send_keys failed: {e}")
    # json.dumps turns ANY name (apostrophes, quotes, backslashes, unicode)
    # into a safe JS string literal, so the injection can't break the script.
    try:
        await tab.evaluate(
            "(function(n){var e=document.querySelector('#playername');"
            "if(e){e.value=n;"
            "e.dispatchEvent(new Event('input',{bubbles:true}));"
            "e.dispatchEvent(new Event('change',{bubbles:true}));}})("
            + json.dumps(name) + ")"
        )
    except Exception as e:
        log(f"  js-set failed: {e}")
    try:
        val = await tab.evaluate(
            "(document.querySelector('#playername')||{}).value || ''"
        )
    except Exception:
        val = name
    log(f"  username field at submit = {val!r}")
    return val


async def vote_succeeded(tab) -> bool:
    """Confirmation shown immediately after a real vote ('Voto aprobado')."""
    return await tab.evaluate(
        "/Gracias por tu voto|Voto aprobado|Acabas de votar|"
        "antes de que puedas votar de nuevo|Debes ser paciente/i"
        ".test(document.body.innerText)"
    )


async def dismiss_consent(tab) -> bool:
    """A TCF/GDPR consent modal appears on a fresh profile and intercepts the
    VOTAR click. Click a dismiss button (choice is saved to the profile)."""
    present = await tab.evaluate(
        "/asks for your consent|Welcome to Top-Games|consentimiento|"
        "gestionar tus cookies/i.test(document.body.innerText)"
    )
    if not present:
        return False
    for label in ("Do not consent", "Consent", "No acepto", "Acepto"):
        try:
            btn = await tab.find(label, best_match=True, timeout=4)
            if btn:
                await btn.click()
                log(f"  dismissed consent modal via '{label}'")
                await tab.sleep(1.5)
                return True
        except Exception:
            continue
    log("  ! consent modal present but no dismiss button matched")
    return False


async def click_turnstile_checkbox(tab) -> None:
    """Dispatch a real mouse click at the checkbox inside the Turnstile iframe
    (only used if the managed challenge doesn't auto-pass)."""
    raw = await tab.evaluate(
        "JSON.stringify((function(){var f=document.querySelector("
        "'iframe[src*=\"challenges.cloudflare.com\"]');"
        "if(!f) return null;var r=f.getBoundingClientRect();"
        "return {x:r.left, y:r.top, w:r.width, h:r.height};})())"
    )
    if not raw or raw == "null":
        log("  ! Turnstile iframe not found yet")
        return
    rect = json.loads(raw)
    x = rect["x"] + 28
    y = rect["y"] + rect["h"] / 2
    await tab.send(cdp.input_.dispatch_mouse_event(type_="mouseMoved", x=x, y=y))
    await tab.sleep(0.15)
    await tab.send(cdp.input_.dispatch_mouse_event(
        type_="mousePressed", x=x, y=y,
        button=cdp.input_.MouseButton.LEFT, click_count=1))
    await tab.sleep(0.08)
    await tab.send(cdp.input_.dispatch_mouse_event(
        type_="mouseReleased", x=x, y=y,
        button=cdp.input_.MouseButton.LEFT, click_count=1))
    log(f"  clicked Turnstile checkbox at ({x:.0f},{y:.0f})")


async def run() -> int:
    if not USERNAME or USERNAME == "YOUR_USERNAME_HERE":
        log("ERROR: open 'username.txt' and put your top-games name in it first.")
        return 3

    PROFILE_DIR.mkdir(exist_ok=True)
    log("=== run start ===")
    start_kwargs = dict(
        user_data_dir=str(PROFILE_DIR),
        headless=False,                 # Turnstile fails in headless
        # Turnstile requires a normal, on-screen, reasonably-sized window:
        # off-screen, minimized, tiny, and headless windows all FAIL it.
        # The window appears for ~8-10s per run; that's the cost of passing.
        browser_args=["--window-size=900,1000"],
    )
    if CHROME:
        start_kwargs["browser_executable_path"] = CHROME
    browser = await uc.start(**start_kwargs)
    try:
        tab = await browser.get(VOTE_URL)
        await tab.sleep(2)
        # Get past the Cloudflare interstitial ("Just a moment...") and wait for
        # the real vote page (form or cooldown view) before doing anything.
        await wait_for_page_ready(tab)

        await dismiss_consent(tab)

        if await is_on_cooldown(tab):
            secs = await get_cooldown_seconds(tab)
            log(f"On cooldown ({secs}s left) -> nothing to do.")
            print(f"COOLDOWN_SECONDS={secs}")   # used by setup_task.ps1
            return 1

        # Wait for the form to be submit-ready (token copied + button enabled).
        deadline = TOKEN_WAIT_SECONDS
        clicked = False
        ready = False
        while deadline > 0:
            if await vote_ready(tab):
                ready = True
                break
            if not clicked and deadline <= TOKEN_WAIT_SECONDS - 4:
                await click_turnstile_checkbox(tab)
                clicked = True
            await tab.sleep(1.5)
            deadline -= 1.5

        if not ready:
            token_len = await get_token_len(tab)
            log(f"Vote form never became ready (token_len={token_len}). -> exit 2")
            await tab.save_screenshot(str(SHOT_FILE))
            return 2

        log("Vote form READY (token set, button enabled).")
        await dismiss_consent(tab)

        # Fill the username LAST, right before submit, and verify it stuck.
        val = await set_username(tab, USERNAME)
        if val != USERNAME:
            log(f"  ! username did not stick (got {val!r}); retrying once")
            await tab.sleep(0.5)
            val = await set_username(tab, USERNAME)

        votar = await tab.select("#btnSubmitVote")
        await votar.click()
        log("  clicked VOTAR, waiting for confirmation...")

        ok = False
        for _ in range(8):
            await tab.sleep(1.5)
            if await vote_succeeded(tab):
                ok = True
                break

        await tab.save_screenshot(str(SHOT_FILE))
        if ok:
            log(f"Vote CONFIRMED for '{USERNAME}'. -> exit 0")
            return 0
        log("VOTAR clicked but no confirmation appeared. -> exit 3")
        return 3
    finally:
        try:
            browser.stop()
        except Exception:
            pass
        log("=== run end ===\n")


def main() -> int:
    try:
        return uc.loop().run_until_complete(run())
    except Exception as e:
        log(f"FATAL: {e!r}")
        return 3


if __name__ == "__main__":
    sys.exit(main())
