# Connecting an owner's Arbox

The goal: the owner's key is in `~/.arbox/profiles` (readable only by them), `doctor --online` says it works, and the key never appeared in the chat. Talk in the owner's language, one step at a time, and wait for "done" before the next step.

## Step 0: install the helper

See SKILL.md section 1. Then run `~/.arbox/bin/arbox doctor`. It lists the tools on this computer and the key profiles (names only).

## Step 1: find the key in Arbox

Say something like:

> In Arbox, go to **Settings → Club Information**. You'll see an "API Key". Copy it (it's a long string of letters and numbers). This is the same key Arbox uses for its Zapier connection. (That's the menu name in Arbox's Zapier guide, not yet confirmed on a live account; if you can't find it, look around Settings for "API key" or ask Arbox support.) Don't paste it here in the chat; I'll show you a safer place in a moment.

Hebrew:

> בארבוקס, היכנסו ל**הגדרות ← פרטי המועדון** (Club Information) והעתיקו את מפתח ה-API. זה אותו מפתח שמשמש לחיבור Zapier. (זה שם התפריט לפי המדריך של ארבוקס ל-Zapier, ועוד לא אומת בחשבון אמיתי; אם לא מוצאים, חפשו "API" בהגדרות או פנו לתמיכה של ארבוקס.) אל תדביקו אותו כאן בצ'אט, תכף אראה לכם מקום בטוח יותר.

The English menu name comes from Arbox's Zapier guide and the Hebrew label is our translation; neither is confirmed on a live account. If the owner can't find it, describe it in English and ask what they see.

**No key, or no API access?** Some plans or accounts may not show a key. Offer this email to Arbox support:

> Subject: Enabling API access for my Arbox account
>
> Hi, I'd like to connect my Arbox account to an AI assistant using the Arbox public API. Could you please confirm that API access is enabled for my business, and tell me where to find my API key (Settings → Club Information)? If my business has several branches, do I need a separate key for each? Thank you!

> נושא: הפעלת גישת API לחשבון ארבוקס שלי
>
> שלום, אני רוצה לחבר את חשבון Arbox שלי לעוזר בינה מלאכותית דרך ה-API הציבורי של ארבוקס. אפשר לוודא שגישת API פעילה לעסק שלי, ולהסביר איפה אני מוצא/ת את מפתח ה-API (הגדרות ← פרטי המועדון)? אם יש לעסק כמה סניפים, האם צריך מפתח נפרד לכל סניף? תודה!

Meanwhile, offer sample data (`--demo`) so they can see what reports look like.

## Step 2: the owner enters the key (hidden)

Primary path, best for everyone:

> Open a new Terminal tab: press **⌘T** (or Shell → New Tab). Paste this line and press Enter:
> `~/.arbox/bin/arbox setup --prompt`
> It asks for the key. Paste it and press Enter. Nothing shows while you paste; that's on purpose. Then come back here and tell me "done".

For a second branch: `~/.arbox/bin/arbox setup haifa --prompt` (any short name: letters, numbers, dashes).

Fallback, if Terminal feels too much:

> I'll open a private file in TextEdit. Run: `~/.arbox/bin/arbox setup --open`. You'll see a line `default=PASTE_YOUR_ARBOX_KEY_HERE`. Replace the placeholder after `default=` with your key, save (⌘S), close it, and tell me "done". If the text looks formatted (fonts, bold), choose Format → Make Plain Text before saving.

You can run the `--open` command for them (it creates the file and opens TextEdit); the owner does the pasting. Never read the file afterwards: `doctor` tells you whether it is filled in.

## Step 3: test it

`~/.arbox/bin/arbox doctor --online`

- **OK for a profile:** "Connected to your Arbox. I can read your information now; nothing changes without your yes."
- **Rejected (401 or 403):** the key was mistyped or isn't active. Repeat step 2 with `--prompt`. If it fails twice, send the support email.
- **Network error:** check the internet connection; Arbox may be down. Try again in a minute.
- **"contains unexpected characters (spaces or quotes?)"** or **"has spaces inside it":** extra text was pasted with the key. Repeat step 2 and paste only the key.
- **"saved as a Rich Text file":** TextEdit saved it formatted. Open it, choose Format → Make Plain Text, save, then run `doctor --online` again.

## Step 4: permissions and privacy (once)

1. Explain the prompts and offer the settings rules (SKILL.md section 3). Show the exact JSON change before editing their settings, and wait for their yes.
2. Privacy in two lines: "What I read from your Arbox is processed by Claude's servers, like anything you type here. I leave out health details, ID numbers, addresses and card numbers unless you ask. Please don't use this on a shared front-desk computer."
3. Mark the profile file `~/Arbox/business-profile.md` (if `arbox-guide` created one) with `Connected to Arbox: yes (<profile names>)`. Never write the key there.

## Windows and Linux

The helper needs a POSIX shell and `curl`. On Windows, Claude Code runs commands through Git Bash, which includes both; the key file lives under the Git Bash home. This path is best-effort and untested; macOS is the tested path.

## Removing or rotating a key

- New key: run `setup <name> --prompt` again; it replaces that profile's key.
- Disconnect completely: the owner deletes `~/.arbox/profiles` (or the one line) and can revoke the key in Arbox if Arbox offers that. Say plainly that the agent won't open the file itself.
