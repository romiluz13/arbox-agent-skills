# Arbox API: Finance

Finance reports (date-range GETs) and the document-creation write.

Tier key: **R0** read-only. **R1** reversible internal write (notes, tasks, lead status, create a lead). **R2** member-facing or hard to undo (messages, bookings, edits to a person). **R3** money, identity or delete: never agent-executed in v1.

Data key: **S0** studio configuration. **S1** personal contact data. **S2** health, national ID, salary, payment or finance data. S1 and S2 reads stay out of chat and go to files by default.

Shared rules (pagination, id types, `location_id`, date formats) are in [quirks.md](quirks.md). Common multi-step chains are in [quirks.md](quirks.md#lookup-chains). Each operation ends with its official docs link.

## Contents

- [Create Document](#create-document)
- [Get Cash Flow Report](#get-cash-flow-report)
- [Get Failed Transactions](#get-failed-transactions)
- [Get Invoices Report](#get-invoices-report)
- [Get Receipts Report](#get-receipts-report)
- [Get Sales By Invoice Report](#get-sales-by-invoice-report)

### Create Document

`POST /v3/finance/documents` · Tier R3 · Data S2

Issue an invoice, receipt, refund invoice or price quote.

**Pagination:** none.

**Body (JSON, required):**

- `document_type` **required**, enum 'tax_invoice'|'tax_invoice_receipt'|'receipt'|'refund_invoice'|'transaction_account'|'price_quote'|'payment_receipt'
- `user_id`, integer|null - Arbox member ID. Use with customer_id or when customer_id exists for the member.
- `customer_id`, integer|null - customer unique identifier. Required unless user_id has customer_id.
- `invoice_name` **required**, string - Customer name on the document.
- `personal_id`, string|null - Customer ID number on the document.
- `amount` **required**, number - Invoice total amount.
- `comment`, string|null - Document comments.
- `email`, string|null (email) - Email to send the document to.
- `location_id`, integer|null - Location ID. Defaults to the API user's location.
- `items` **required**, array of objects - Line items on the document.
- `items[].item_number`, string|null - Product number.
- `items[].description` **required**, string - Item description.
- `items[].quantity` **required**, integer - Item quantity. Must be a positive whole number.
- `items[].item_price` **required**, number - Unit price per item.
- `items[].vat`, enum 'include_vat'|'exempt'
- `payments`, array|null - Required for tax_invoice_receipt, receipt, and payment_receipt. Each object is one payment line.

**Response 200:** `CreatedDocumentResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** A customer: either `user_id` (searchUser) or `customer_id` (no operation lists customer ids).

**Quirks:**

- `document_type` enum: tax_invoice, tax_invoice_receipt, receipt, refund_invoice, transaction_account, price_quote, payment_receipt.
- Required: `document_type`, `invoice_name`, `amount`, `items` (each needs `description`, `quantity` as a positive integer, `item_price`; optional `item_number`, `vat` = include_vat|exempt).
- `payments` is required for tax_invoice_receipt, receipt and payment_receipt, but its item shape is not defined.
- `email` sends the document to the customer. `location_id` defaults to the API user's location.
- Response is untyped: the document number or link is not guaranteed to come back.
- Legally meaningful documents. Never in v1.

**LIVE CHECK:**

- Whether `amount` must equal the sum of `items`.
- Whether a document can be voided or must be offset with a refund invoice.
- The `payments` item shape.
- What `customer_id` is and where to find it.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Document

### Get Cash Flow Report

`GET /v3/finance/reports/cashFlow` · Tier R0 · Data S2

See money in and out for a period.

**Parameters:**

- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.

**Pagination:** none.

**Response 200:** `CashFlowReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None beyond the date range.

**Quirks:**

- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

**LIVE CHECK:**

- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.
- What 'cash flow' includes.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cash%20Flow%20Report

### Get Failed Transactions

`GET /v3/finance/reports/failedTransactions` · Tier R0 · Data S2

List payments that failed.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `FailedTransactionsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `membership_user_id`, `membership_type_name`, `location_id`, `location_name`, `membership_location`, `department_name`, `amount`, `last_four_digits`, `custom_field_value`.

**Preconditions and lookup:** None.

**Quirks:**

- No date params: it returns whatever the system treats as current failures.
- Fields: `amount`, `last_four_digits`, `membership_user_id`, `membership_type_name`, `location_id`.
- Pagination params exist (unlike the other finance reports).

**LIVE CHECK:**

- How far back it goes and whether resolved failures drop out.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Failed%20Transactions

### Get Invoices Report

`GET /v3/finance/reports/invoices` · Tier R0 · Data S2

List invoices issued in a period.

**Parameters:**

- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.

**Pagination:** none.

**Response 200:** `InvoiceReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None beyond the date range.

**Quirks:**

- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

**LIVE CHECK:**

- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Invoices%20Report

### Get Receipts Report

`GET /v3/finance/reports/receipts` · Tier R0 · Data S2

List receipts issued in a period.

**Parameters:**

- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.

**Pagination:** none.

**Response 200:** `ReceiptReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None beyond the date range.

**Quirks:**

- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

**LIVE CHECK:**

- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Receipts%20Report

### Get Sales By Invoice Report

`GET /v3/finance/reports/sales` · Tier R0 · Data S2

See sales grouped by invoice for a period.

**Parameters:**

- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.

**Pagination:** none.

**Response 200:** `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None beyond the date range.

**Quirks:**

- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

**LIVE CHECK:**

- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.
- How it differs from the salesReport under GET /v3/reports/{reportName}.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Sales%20By%20Invoice%20Report
