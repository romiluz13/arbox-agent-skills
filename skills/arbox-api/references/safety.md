# Safety: tiers, allowed writes, refusals

Why so strict: the owner's Arbox holds live members, money and health data, and most owners can't easily undo a mistake. A wrong message reaches real people; a wrong charge is real money. v1 allows only small internal updates. The helper can't undo them: a task can be marked done, and a note stays. Whether the Arbox screen can remove them is a LIVE CHECK, so never promise an undo.

## Contents
- [The 7 allowed writes (R1)](#the-7-allowed-writes-r1)
- [The confirm protocol](#the-confirm-protocol)
- [Member-facing actions (R2): prepare, don't do](#member-facing-actions-r2-prepare-dont-do)
- [Money, identity, deletes (R3): refuse](#money-identity-deletes-r3-refuse)
- [Reads that need care](#reads-that-need-care)
- [When the owner insists](#when-the-owner-insists)

## The 7 allowed writes (R1)

The helper's write allowlist. Anything else exits 5.

| Operation | What it does | Docs |
|---|---|---|
| `POST /v3/leads` | Create a lead | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Lead |
| `POST /v3/leads/updateStatus` | Move a lead to another status | https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Lead%20Status |
| `POST /v3/leads/markAsLost` | Mark a lead as lost, with a reason | https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Lead%20as%20Lost |
| `POST /v3/leads/createNote` | Add a note to a lead | https://arboxserver.arboxapp.com/docs/api#/operations/Add%20Note%20to%20Lead |
| `POST /v3/tasks` | Create a task (e.g. "call Dana") | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Task |
| `POST /v3/tasks/markAsCompleted/{task_id}` | Complete a task | https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Task%20as%20Completed |
| `POST /v3/users/createNote` | Add a note to a member | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20user%20note |

Whether these trigger Arbox automations (for example an auto action on a status change) is a LIVE CHECK; mention it when changing a lead status.

## The confirm protocol

1. Prepare the exact change: the operation, every body field, the target people (names and count) and the branch (`-p` profile).
2. Show it in plain words: "I'll create 4 follow-up tasks in Studio Tel Aviv, one per lead below, due tomorrow at 10:00, assigned to you. You can mark them done in Arbox; I can't delete them. Go ahead?"
3. Wait for an explicit yes to this change. "Sure", "yes", "go" count; silence, "maybe", or a yes to something else don't.
4. Call once per record: `~/.arbox/bin/arbox write POST /v3/tasks --body-file ~/Arbox/work/task-1.json --yes-i-confirmed`. Write bodies to files under `~/Arbox/work/` first so they're easy to show and log.
5. Report what happened per record. On any failure stop, show the error in plain words, and ask before trying anything else. Never retry automatically; a write may have succeeded even when the reply failed.
6. More than 20 records in one batch: split it and confirm each batch.

## Member-facing actions (R2): prepare, don't do

Messages (`POST /v3/message`), bookings (`/v3/schedule/bookSession`), cancellations (`/v3/schedule/cancelUserBooking`), trial bookings (`/v3/schedule/booking/trial`), and schedule edits (`PATCH /v3/schedule`) reach members or change what they see. Side effects (charges, notifications, session deductions) aren't verified yet. The helper refuses them.

Do instead:
- **Messages:** write drafts (see the `arbox-recipes` drafts reference) for members whose consent flag allows the channel. The owner sends them from Arbox (calendar → participant management, or their WhatsApp templates) or their own phone.
- **Bookings and cancellations:** produce the list (who, which class, when); the owner does it in Arbox in a few clicks.

## Money, identity, deletes (R3): refuse

Creating, cancelling, freezing or updating memberships; recurring payments; finance documents (invoices, receipts, refunds); grouping (merging) users; deleting users; editing member profiles; injury and health records; membership QR codes and commitment documents. Refuse kindly and point to the Arbox screen. Offer what you can do: a list, a draft, a reminder task (R1, with a yes).

## Reads that need care

- `GET /v3/schedule/entryFromWaitingList` with a `confirm` parameter may move people off a waiting list. The helper refuses `confirm`; read without it.
- Health, injury and medical fields, `personal_id`, addresses, card digits, salaries: don't output them unless explicitly asked for a specific person and reason.
- Large lists: always `--out` to a file.

## When the owner insists

"I trust you, just do it" doesn't change the tier. Say it warmly, once: "I can't send it or change it from here; that's on purpose, so nothing goes wrong with your members or money. Here's everything ready so it takes you one minute in Arbox." Then make the manual step as easy as possible.
