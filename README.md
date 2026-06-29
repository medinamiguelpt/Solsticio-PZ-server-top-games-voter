# Solsticio PZ server — top-games.net auto-voter

Automatically votes for the **Solsticio** Project Zomboid server on
top-games.net every **2 hours 2 minutes**, under **your** username — so you
never forget to vote and the server climbs the ranking.

The vote page is protected by **Cloudflare Turnstile** (the "Verify you are
human" box). Normal automation (Selenium/Playwright/Puppeteer) gets detected and
blocked. This uses **[nodriver](https://github.com/ultrafunkamsterdam/nodriver)**
— a stealth Chrome driver — so Turnstile's challenge passes automatically.

> ⚠️ For personal use. Voting is one per ~2 hours per person (enforced by IP +
> cookie), exactly like voting by hand — this just does it for you on a timer.

---

## Quick start (Windows)

**1. Install Python** (3.10+). During install, tick **“Add Python to PATH”.**
Get it from <https://www.python.org/downloads/>.

**2. Download this project.** Green **Code → Download ZIP**, then unzip it
somewhere permanent (e.g. `C:\Tools\Solsticio-Voter`).

**3. Install the dependency.** Open the folder, type `cmd` in the address bar,
press Enter, then run:
```
pip install -r requirements.txt
python patch_nodriver.py
```
(`patch_nodriver.py` fixes a nodriver bug on Python 3.13/3.14 — harmless to run
either way.)

**4. Set your username.** Open **`vote.py`** in Notepad and change this line:
```python
USERNAME = "YOUR_USERNAME_HERE"
```
to your top-games username, e.g. `USERNAME = "michaelizer"`. Save.

**5. Test it once:**
```
python vote.py
```
A Chrome window opens for a few seconds. Check `vote.log` — you want to see
`username field at submit = '...'` then `Vote CONFIRMED`. (If you already voted
in the last 2h it will say `On cooldown` — that's fine.)

**6. Schedule it forever.** Right-click **`setup_task.ps1`** → **Run with
PowerShell**. Done — it now votes every 2h2m automatically.

To stop it later: right-click **`uninstall_task.ps1`** → Run with PowerShell.

---

## Important for it to keep working

- **Stay logged in to Windows.** Turnstile only passes with a *visible* window,
  so headless/minimized/off-screen all fail. A Chrome window will briefly appear
  (~8–10 seconds) every 2 hours — that's normal.
- **Keep your VPN OFF.** Cloudflare distrusts VPN/datacenter IPs and will throw
  a puzzle. Vote on your normal home connection.
- Leave the `chrome-profile` folder alone (it stores the bot's cookies).

## New season? Just change one line

When the server starts a new season with a new vote link (same page, same
everything), open `vote.py` and update:
```python
VOTE_URL = "https://es.top-games.net/project-zomboid/vote/<new-season-link>"
```

## Files

| File | What it is |
|---|---|
| `vote.py` | The bot. Edit `USERNAME` (and `VOTE_URL` per season). |
| `setup_task.ps1` | Creates the every-2h2m scheduled task. |
| `uninstall_task.ps1` | Removes the scheduled task. |
| `patch_nodriver.py` | One-time fix for nodriver on new Python versions. |
| `requirements.txt` | Python dependency (`nodriver`). |
| `vote.log` | Created on first run — log of every attempt. |

## Exit codes (in `vote.log`)

- `0` — vote submitted & confirmed
- `1` — on cooldown (normal)
- `2` — Turnstile not passed (try: VPN off, window visible, run again later)
- `3` — not configured / unexpected error

## Troubleshooting

- **`nodriver` won't import** → run `python patch_nodriver.py`.
- **Exit code 2 repeatedly** → make sure the VPN is off and you're not running
  it dozens of times in a row (that lowers your IP's trust score). Wait and
  retry on your home IP.
- **No Chrome?** Install Google Chrome (Brave also works); the script
  auto-detects it.

## License

MIT — see [LICENSE](LICENSE).
