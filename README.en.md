[🇪🇸 Español](README.md) | **🇬🇧 English**

# Auto-vote for the Solsticio Project Zomboid server

This little tool votes for our **Solsticio** server on top-games.net **for you,
automatically, every 2 hours** — so you never forget, and the server climbs the
ranking. You set your name once and forget about it.

The vote page has a "Verify you are human" check (Cloudflare Turnstile) that
normally blocks robots. This tool gets past it the honest way — by using a real
Chrome window — so your vote counts just like clicking by hand.

---

## How to set it up (about 5 minutes, no coding)

### Step 1 — Install Python (one time)
- Go to **https://www.python.org/downloads/** and click the big **Download**
  button.
- Run the installer. **VERY IMPORTANT:** on the first screen, tick the box
  **“Add Python to PATH”**, then click **Install Now**.

### Step 2 — Download this tool
- At the top of this page click the green **`< > Code`** button → **Download
  ZIP**.
- **Right-click the ZIP → Extract All.** Put the folder somewhere it can stay,
  like your Documents.

### Step 3 — Install it (and pick your language)
- Double-click **`1-INSTALL.bat`**.
- It first asks **[S] Spanish / [E] English** — press your choice. From then on
  every window speaks your language.
- It installs everything and says *Done*. Close it.
- (If Windows shows a blue "protected your PC" box, click **More info → Run
  anyway**.)

### Step 4 — Put your name
- Open **`username.txt`** (double-click → opens in Notepad).
- Replace `YOUR_USERNAME_HERE` with **your top-games username**, and **Save**
  (Ctrl+S).

### Step 5 — Test it once
- Double-click **`2-TEST-vote-now.bat`**.
- A Chrome window pops up for a few seconds and votes. When it says
  **“Vote CONFIRMED”**, it works! 🎉
  *(If it says “On cooldown”, you already voted in the last 2 hours — that’s
  normal, try later.)*

### Step 6 — Turn on automatic voting
- Double-click **`3-SCHEDULE-every-2h.bat`**.
- That’s it — it now votes every 2 hours by itself.

To turn it off later, double-click **`4-STOP-scheduling.bat`**.

---

## Buttons (day-to-day)

| Button | What it does |
|---|---|
| **`2-TEST-vote-now.bat`** | Votes **right now**. Says *Vote CONFIRMED* (and resets the timer to ~2h2m) or *On cooldown* with a link to see how much time is left. |
| **`PAUSE.bat`** | Pauses automatic voting (without deleting it). |
| **`RESUME.bat`** | Resumes automatic voting and shows the next run time. |
| **`STATUS.bat`** | Shows if it's active, last/next run, and the log. |
| **`4-STOP-scheduling.bat`** | Removes automatic voting completely. |

> Pause or stop? **`PAUSE`** turns it off for a while and **`RESUME`** turns it
> back on. **`4-STOP`** removes it entirely (run `3-SCHEDULE` again to re-add it).
> There's a quick summary in **`BUTTONS.txt`**.

---

## Keep these in mind
- **Leave your PC on and logged in.** The vote needs a real window, so a small
  Chrome window will flash for a few seconds every 2 hours — that’s normal, just
  ignore it.
- **Keep any VPN turned OFF.** Voting through a VPN makes the human-check fail.

## Something went wrong?
- **It says it can’t find Python** → you missed the “Add Python to PATH” box in
  Step 1. Re-run the Python installer (Modify) and tick it.
- **The test says exit code 2** → make sure the VPN is off, then try again a bit
  later.
- Everything that happens is written to **`vote.log`** — open it to see the
  history.

---

## Need help?

If it's not working, we're happy to help:

- **Open an issue** (the **Issues** tab at the top of this page → **New issue**)
  and **attach your `vote.log` file**. It tells us exactly what went wrong.
  *(The log only contains timestamps and status messages — no passwords or
  personal data.)*
- **Or message on Discord:** **`michaelizer1`**.

## ⭐ Liked it?

If it helped you, give it a star! Click the **Star** ⭐ button at the top-right
of this page. It's free, takes a second, and helps a lot. 🙌

---

*For players of the server only. It simply does the same one-vote-every-2-hours
you could do by hand, on a timer. MIT licensed.*
