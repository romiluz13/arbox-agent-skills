# Reading Arbox fields

Every recipe reads these fields with the same rules. The values below were seen on a live account (field report, 2026-10-15); the spec types these response fields as plain strings and lists no values for them. A recipe's jq copies the definitions it needs from this file, word for word, so the rules stay the same everywhere.

## Flags (yes or no)

Seen live as `"yes"` and `"no"`: `has_waiver`, `cancelled`, `has_another_plan`, `has_another_session`, `future_registration`. `allow_sms` and `allow_email` also take `"unknown"` (seen live). Other flags (`medical_cert`, task `done`, `check_in`) have not been read live. Request bodies use JSON `true`/`false` and the demo uses `"1"`/`"0"` for `done` and `check_in`, so the rule accepts those too.

- yes, true, 1 mean yes.
- no, false, 0 mean no.
- Anything else (empty, null, `"unknown"`) is unknown. Unknown is never no: put the row in a "check" group, and never message on it.

## Booked ahead (`future_registration`)

A date means something is booked. Empty, null or a no flag (`"no"`) means nothing is booked. A yes flag means booked.

## Phones

Phones come in mixed formats on one account (`050-...` and `+972 50-...`). Compare phones by key: digits only; drop a leading `00`; a leading `972` becomes `0` (`+972 (0)50...` too). An empty key never matches anything. Two people with the same key are "not matched, check", never a guess.

## Amounts

Amounts and counts come as strings in some reports and numbers in others (`debtReport` `debt` is a number). Cast to a number; null or empty is 0 for a sum, and "not reported" for a count shown to the owner.

## Sales rows (`action`, `sub_action`)

On a live account both fields are always filled. Seen values:

| `action` | Meaning for the recipes |
|---|---|
| `New purchase` | a sale, and a new buyer |
| `Lead converted purchase` | a sale, and a new buyer (a lead who bought) |
| `Renew` | a sale, not a new buyer |
| `Purchase` | a sale, not a new buyer (an existing member buying another item) |
| anything else | a special row: keep it out of every total, count it and list its `action` value |

Assumed, not documented (LIVE CHECK): the meanings in the `sub_action` table. If `Separated Payment` or `Debt` rows repeat money already in another row, totals double count; that is why sales-snapshot shows their row counts and asks the owner to compare the total with Arbox first.

| `sub_action` | Meaning for the recipes |
|---|---|
| `Free` | a free item: count it as "free items", outside the sales count and the totals |
| `Debt` | a sale not yet paid in full: keep it in; the unpaid part is in `debt` |
| `Separated Payment`, `Purchase Occasion`, anything else | a sale: keep it in |

LIVE CHECK: what refunds and cancellations look like (none were seen). A refund would carry an `action` value not in the table, so it stays out of the totals.

## Tasks on a row (`task_status`)

Seen values: `taskNone` and `taskPast`. `taskNone` is no task. `taskPast` most likely means the only task is old or overdue (LIVE CHECK). Both mean nobody has a current task, so the person still needs a call; show `taskPast` as "old or overdue task". Any other non-empty value counts as a current task.

## jq definitions

```
def flag: (if . == null then "" else tostring | ascii_downcase end) as $v
  | if $v == "yes" or $v == "true" or $v == "1" then true
    elif $v == "no" or $v == "false" or $v == "0" then false else null end;
def booked_ahead: (if . == null then "" else tostring end) as $v | ($v | flag) as $f
  | if $v == "" then false elif $f == null then true else $f end;
def phone_key: if . == null then "" else tostring | gsub("[^0-9]"; "") | sub("^00"; "") | if startswith("972") then .[3:] | (if startswith("0") then . else "0" + . end) else . end end;
def num: if . == null or . == "" then 0 else tonumber end;
def sale_row: (.action // "") as $a | $a == "New purchase" or $a == "Lead converted purchase" or $a == "Renew" or $a == "Purchase";
def new_buyer_row: (.action // "") as $a | $a == "New purchase" or $a == "Lead converted purchase";
def free_row: (.sub_action // "") == "Free";
def current_task: (.task_status // "") as $t | $t != "" and $t != "taskNone" and $t != "taskPast";
```

`flag` gives `true`, `false` or `null` (unknown). Test it with `== true` or `== false`, never with `//` or `not`, which treat unknown as no.
