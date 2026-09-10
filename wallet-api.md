# Wallet API Guide for Flutter Developers

Updated: 2026-09-09

This guide describes the customer wallet screen, transaction history, Add Balance
flow, and the saved-card API contracts that the wallet UI depends on. Examples
use illustrative IDs, amounts, and dates; use the values returned by your server.

## 1. Current delivery status

The wallet backend is implemented: balance, history, amount validation, ownership
checks, local card validation, and protection against duplicate credits from
overlapping requests or retries after a crash.

**Live payment-provider integration is deferred.** Develop and test the UI using
the backend team's development environment and test cards. A successful top-up
with the fake gateway demonstrates wallet behavior; it does not represent a real
card charge. Do not enable live funding based on this guide alone. Tokenization,
payment authentication/3DS, provider callbacks, and reconciliation will be
specified when payment integration is implemented.

Saved-card endpoints are listed in section 9 because the wallet needs a
`payment_method_id`. They belong to the Payments module. This guide does not
define a provider SDK integration.

## 2. Base URL, authentication, and language

Configure the server origin per environment, for example:

```text
BASE_URL = https://api.example.com
GET BASE_URL/api/v1/wallet
```

The domain above is a placeholder. Obtain the development/staging URL from the
backend team. If the Flutter HTTP client already has `/api/v1` in its base URL,
use paths such as `/wallet` and do not add that prefix twice.

Send these headers on every request:

```http
Authorization: Bearer <customer-access-token>
Accept: application/json
lang: en
```

For requests containing JSON, also send:

```http
Content-Type: application/json
```

Use a logged-in **customer access token**, not a refresh token, guest token,
admin token, or courier token. The backend identifies the wallet owner from that
token; Flutter does not send `user_id` or `wallet_id`.

Use `lang: en` or `lang: ar`. This header takes priority over
`Accept-Language`. Wallet messages, titles, and merchant names use the resolved
locale where translations are wired up. Some existing top-up errors and card
messages still return English. Never use localized message text as an enum or a
stable error identifier.

## 3. Screen-to-API flow

| Screen or action | Flutter behavior | API |
|---|---|---|
| Open Wallet | Load the balance/configuration and first history page; the two reads can run concurrently | `GET /api/v1/wallet` and `GET /api/v1/wallet/transactions` |
| Pull to refresh | Replace balance and reload history from page 1 | Same two GET requests |
| See All / load more | Display the full history and request subsequent pages | `GET /api/v1/wallet/transactions?page=2&per_page=15` |
| Open Add Balance | Render limits and quick-pick amounts from the overview response | No extra wallet request needed if overview is current |
| Choose a funding card | Fetch saved cards and keep the selected card ID in local state | `GET /api/v1/payment-methods/cards` |
| Confirm top-up | Submit amount, selected card ID, and one attempt key; disable repeat taps while submitting | `POST /api/v1/wallet/top-up` |
| Top-up succeeds | Replace the displayed balance with the response wallet and reload history page 1 | Use the POST response, then refresh history |
| My Cards / Add Card | Use the related card contracts in section 9 | Payments-module endpoints |

The three wallet endpoints are:

| Method | Endpoint | Successful HTTP status |
|---|---|---|
| GET | `/api/v1/wallet` | 200 |
| GET | `/api/v1/wallet/transactions` | 200 |
| POST | `/api/v1/wallet/top-up` | 201, including a successful replay |

There is no separate create-wallet request. The first wallet read creates a
zero-balance wallet if the customer does not already have one.

## 4. Money and JSON conventions

The current currency is **SAR**. One SAR equals 100 halalas.

| Field | Unit / type | Example |
|---|---|---|
| `wallet.balance` | JSON number, SAR | `310.5` |
| `wallet.balance_halalas` | Integer, halalas | `31050` |
| Top-up request `amount` | SAR, number or numeric decimal string | `300` or `"300.00"` |
| Transaction `amount` | Positive magnitude, SAR | `10.0` |
| Transaction `signed_amount` | Signed SAR number | `-10.0` or `10.0` |
| Transaction `amount_label` | Signed decimal string, without currency symbol | `"+10.00"` |
| Transaction `balance_after` | SAR number or null | `310.0` |
| Overview limits and suggested amounts | SAR numbers | `5000.0` |

Send `300` to add SAR 300; sending `30000` means SAR 30,000 and exceeds
the default limit. Prefer integer halalas for local arithmetic and convert to a
two-decimal SAR string when building a request.

JSON numeric values can decode as either `int` or `double` in Dart. Parse
them through `num`, such as `(json['balance'] as num).toDouble()`.

The server is authoritative for balance. Do not calculate it by summing a
history page, and do not increment it optimistically after tapping Continue.

## 5. Get wallet overview

```http
GET /api/v1/wallet
```

No query parameters or body are required.

Example HTTP 200 response:

```json
{
  "success": true,
  "message": "Wallet retrieved successfully.",
  "data": {
    "wallet": {
      "id": 7,
      "balance": 10.0,
      "balance_halalas": 1000,
      "currency": "SAR"
    },
    "top_up": {
      "minimum": 1.0,
      "maximum": 5000.0,
      "suggested_amounts": [300.0, 400.0, 500.0, 1000.0]
    }
  }
}
```

Use `data.wallet.balance` for the Now Credit card and
`data.top_up.suggested_amounts` for the quick-pick buttons. The current
defaults match the design, but the backend can change the limits. Read them from
this response instead of hardcoding them.

For the Other amount field, enable Continue only when an amount is valid and
a funding card has been selected. Keep amount selection and submission as
separate steps; selecting a quick-pick button must not submit a top-up.

## 6. Get transaction history

```http
GET /api/v1/wallet/transactions?page=1&per_page=15
```

| Parameter | Default | Behavior |
|---|---|---|
| `page` | 1 | Page number; send a positive integer |
| `per_page` | 15 | Results per page; the server clamps this to 1–50 |

Results are scoped to the authenticated customer and sorted newest first by
`created_at`, with `id` descending as the tie-breaker.

Example HTTP 200 response containing a settled order refund:

```json
{
  "success": true,
  "message": "Wallet transactions retrieved successfully.",
  "data": {
    "transactions": [
      {
        "id": 41,
        "type": "credit",
        "source": "refund",
        "status": "successful",
        "display_status": "refunded",
        "amount": 10.0,
        "signed_amount": 10.0,
        "amount_label": "+10.00",
        "currency": "SAR",
        "description": "Refund — Order ORD-20260909-ABC123",
        "title": "Haji Shawarma",
        "merchant": {
          "type": "vendor",
          "id": 3,
          "name": {
            "ar": "شاورما حاجي",
            "en": "Haji Shawarma"
          },
          "display_name": "Haji Shawarma",
          "logo_url": null,
          "vendor_count": 1
        },
        "reference": {
          "type": "order",
          "id": 92,
          "uuid": "650f64d3-f9eb-4e2b-bd9a-bfba87e72227",
          "number": "ORD-20260909-ABC123"
        },
        "balance_after": 10.0,
        "created_at": "2026-09-09T09:00:00.000000Z",
        "occurred_at": "2026-09-09T09:00:00.000000Z",
        "processed_at": "2026-09-09T09:00:00.000000Z"
      }
    ],
    "meta": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 15,
      "total": 1
    }
  }
}
```

### Row fields and display rules

| Field | Meaning / UI use |
|---|---|
| `id` | Stable transaction ID; use for list keys and deduplication |
| `type` | `credit` adds funds; `debit` deducts funds when settled |
| `source` | Business event: `topup`, `order_payment`, `refund`, `reward`, `earning`, `payout`, or `adjustment` |
| `status` | Ledger state: `pending`, `successful`, `failed`, or `refunded` |
| `display_status` | Status to use for the UI badge; see mapping below |
| `title` | Customer-facing, localized row title |
| `description` | Stored description; may be English/internal text. Prefer `title` for the main label |
| `merchant` | Vendor identity for a single-vendor reference, otherwise platform identity |
| `reference` | Order/order-group link, or null |
| `balance_after` | Balance immediately after that transaction settled; not the customer's current balance |
| `created_at` / `occurred_at` | ISO 8601 timestamps; currently both represent transaction creation |
| `processed_at` | Settlement time; nullable for unsettled entries |

A settled refund has `source: refund`, `status: successful`, and
`display_status: refunded`. Its amount is normally **positive**, because
money was returned to the wallet. Render the server's sign instead of deriving
it from the badge color or the example Figma amount.

| `display_status` | Suggested label | Meaning |
|---|---|---|
| `successful` | Successful | Completed ledger entry |
| `pending` | Pending | Not yet settled; do not add its amount to the displayed balance |
| `failed` | Failed | Attempt failed |
| `refunded` | Refunded | Refund presentation state; preserve the supplied amount sign |
| Any unknown value | Neutral fallback | Preserve compatibility with future states |

A pending or failed refund keeps its actual status; it is not displayed as
refunded yet. A transaction's positive sign alone does not mean funds are
available.

`merchant.name` contains translations, while `merchant.display_name`
is already localized. `merchant.logo_url` can be null or fail to load; show
a fallback image. Platform rows, such as top-ups, have `merchant.type:
platform` and a null merchant ID. An order group involving multiple vendors
also uses platform identity and reports the count in `vendor_count`.

A reference can have `type: order` or `type: order_group`, with
`id`, `uuid`, and `number`; top-ups normally have `reference: null`.
The wallet does not provide a transaction-expiry date. Use `occurred_at` for
the date beneath a record, not an "Expired" label copied from the mockup.

### Pagination and empty state

An empty history returns HTTP 200 with `data.transactions: []` and
`data.meta.total: 0`. Show an empty state, not an error.

Append another page only while
`current_page < last_page`. Deduplicate rows by transaction ID because new
entries can shift offset-based pages. On refresh or after a successful top-up,
discard the old pagination cursor/page state and reload page 1. There are no
documented customer history filters by status, source, or date.

## 7. Add balance / top up

```http
POST /api/v1/wallet/top-up
Idempotency-Key: 9e377bf3-9487-4321-8901-c3cd85df3a72
Content-Type: application/json
```

Request body:

```json
{
  "amount": 300,
  "payment_method_id": 12
}
```

| Input | Required | Validation |
|---|---|---|
| `amount` | Yes | Numeric SAR amount, at most two decimal places, within overview minimum/maximum |
| `payment_method_id` | Yes | Positive integer ID of the customer's saved, undeleted card |
| `Idempotency-Key` header | Yes | String of 8–255 characters; allowed characters: `A-Z a-z 0-9 . _ : -` |

A UUID string is suitable for the key. The header is required even if a JSON
field named `idempotency_key` is sent. The backend reads the header.

The wallet rejects other users' cards, non-card payment methods, and cards with
a known expired date. Unknown expiry metadata is not a guarantee of validity.
A default card is **not** selected automatically by this endpoint; always send
the chosen `payment_method_id`.

Example HTTP 201 response, starting from a balance of SAR 10:

```json
{
  "success": true,
  "message": "Wallet Topped Up.",
  "data": {
    "transaction": {
      "id": 42,
      "type": "credit",
      "source": "topup",
      "status": "successful",
      "display_status": "successful",
      "amount": 300.0,
      "signed_amount": 300.0,
      "amount_label": "+300.00",
      "currency": "SAR",
      "description": "Wallet top-up",
      "title": "Wallet top-up",
      "merchant": {
        "type": "platform",
        "id": null,
        "name": {
          "ar": "ناو ديليفري",
          "en": "Now Delivery"
        },
        "display_name": "Now Delivery",
        "logo_url": "https://api.example.com/assets/now-logo.png",
        "vendor_count": 0
      },
      "reference": null,
      "balance_after": 310.0,
      "created_at": "2026-09-09T09:05:00.000000Z",
      "occurred_at": "2026-09-09T09:05:00.000000Z",
      "processed_at": "2026-09-09T09:05:01.000000Z"
    },
    "wallet": {
      "id": 7,
      "balance": 310.0,
      "balance_halalas": 31000,
      "currency": "SAR"
    }
  }
}
```

On success, close the Add Balance sheet, replace the wallet state with
`data.wallet`, and refresh transaction history. A successful retry returns
the original transaction ID. Its `balance_after` is historical, while
`data.wallet` reflects the freshly read balance.

There is currently no wallet response containing a 3DS redirect URL or a
dedicated wallet top-up status endpoint. These should not be invented in Flutter.

## 8. Idempotency and error handling

### Keep one key per deliberate attempt

1. Validate the amount and chosen card locally.
2. Generate a key once when the customer confirms the top-up.
3. Keep the key, amount, and card ID together in state before sending.
4. While a request is outstanding, disable duplicate submission.
5. If a response is lost, retain that same attempt. A retry of that attempt must
   use exactly the same key, amount, and card ID.
6. After confirmed success, clear the attempt. A later, deliberate top-up gets
   a new key.

Changing a key after a timeout creates a new operation and defeats retry
protection. Do not generate keys inside an HTTP retry interceptor. Closing a
sheet or cancelling a local HTTP request does not cancel a server-side attempt.

The backend records the request key and its pending transaction together.
Overlapping calls inspect the same attempt. A pending attempt remains blocked
after the lock timeout; waiting 60 seconds does not make it safe to start again.
A confirmed successful attempt replays the original transaction, including
after a crash while saving the response or after removal of the saved card.

Wallet keys are scoped per customer and separately from checkout. Completed
wallet requests from the earlier shared namespace remain replayable.

### Two different HTTP 422 response shapes

**Field validation** returns an `errors` map. The `success` and
`code` fields may be absent. Example with `amount` omitted:

```json
{
  "message": "The amount field is required.",
  "errors": {
    "amount": ["The amount field is required."]
  }
}
```

Possible field names are `amount`, `payment_method_id`, and
`idempotency_key`. Show the first message near the corresponding control.

**Wallet-operation errors** normally use this envelope:

```json
{
  "success": false,
  "message": "Selected card has expired.",
  "code": 422
}
```

Current English wallet messages include:

| Message / situation | Flutter handling |
|---|---|
| `Selected card was not found.` | Refresh cards; the ID may be invalid, deleted, not a card, or owned by another user |
| `Selected card has expired.` | Ask the customer to choose another card |
| `This idempotency key was already used with different top-up parameters.` | Fix the attempt state; never reuse one key for different amounts/cards |
| `A top-up with this key is already in progress.` | Keep the attempt, prevent repeat taps, and refresh balance/history |
| `Wallet top-up could not be confirmed. Please check your wallet before retrying.` | Keep the attempt unresolved and refresh the wallet; do not create a replacement key |
| `Wallet top-up failed. No funds were captured.` | Display the returned failure and refresh; no automatic POST loop |
| Amount below/above the allowed range | Reload overview limits and show a field error |

The API does not currently return stable, distinct machine-readable codes for
these business errors; `code: 422` is just the HTTP status. The English
messages above explain behavior, but UI control flow must not depend on exact
English matching. Treat an unclassified operation error conservatively and
preserve the attempt state.

A recorded failed attempt can currently be retried with the same parameters
and key. An unknown/pending attempt cannot. A generic 422 or transport exception
alone does not prove which state was recorded. The deferred payment integration
must finalize provider error classification before live automatic retries are
introduced.

### Other errors

| HTTP / transport outcome | Handling |
|---|---|
| 401 | Use the app's authentication flow; do not substitute a refresh token in the wallet request |
| 403 | Customer access is not authorized; do not retry repeatedly |
| 404 | A referenced resource is unavailable; refresh the relevant screen |
| 429 | Respect `Retry-After` when present and disable rapid retry |
| 5xx, timeout, connection loss, or unreadable response | A top-up outcome may be unknown; retain the attempt and refresh with GET requests |

Use HTTP status, `message`, and optional `errors`; do not assume every
failure contains `data`, `transaction`, or `wallet`. A failed top-up
response currently does not return its transaction ID.

The customer API has no lookup by idempotency key. Do not guess which history row
matches an unresolved request using amount/time alone. Preserve the key for
support/reconciliation and avoid promising that refresh will automatically
resolve a pending row. Do not log access tokens or raw card details.

Current per-customer limits are 120 wallet reads/minute (shared between overview
and history) and 6 top-up requests/minute, including retries. Prefer explicit
refresh or bounded refresh while the screen is visible; stop on disposal.

## 9. Saved-card contracts used by the wallet UI

These are supporting Payments-module APIs. Provider integration remains deferred
as described in section 1; the contracts are included so the Flutter developer
can build the My Cards screen and select `payment_method_id`.

| Method | Endpoint | Body | Successful response |
|---|---|---|---|
| GET | `/api/v1/payment-methods/cards` | None | 200, `data.cards` array |
| POST | `/api/v1/payment-methods/cards` | Token plus optional name/default flag | 201, `data.card` object |
| PATCH | `/api/v1/payment-methods/cards/{id}/default` | None | 200, `data.card` object |
| DELETE | `/api/v1/payment-methods/cards/{id}` | None | 200, success message and `data: []` |

Example list response:

```json
{
  "success": true,
  "message": "Saved Cards",
  "data": {
    "cards": [
      {
        "id": 12,
        "type": "card",
        "cardholder_name": "Mohamed Yasser",
        "brand": "visa",
        "last_four": "4242",
        "masked_number": "•••• 4242",
        "expiry_month": null,
        "expiry_year": null,
        "expiry": null,
        "is_expired": null,
        "is_default": true
      }
    ]
  }
}
```

Expiry and other display metadata can be missing. When known, `expiry` is
formatted as `MM/YY`, and `is_expired` is a boolean. Null means unknown,
not explicitly valid. Support unknown brands and missing names/masked numbers.

Cards are returned default first, then newest ID first. For funding selection,
use a `type: card` row and disable rows with `is_expired: true`.
Preselect a usable default if appropriate, but still send its ID explicitly.

Example add-card request contract:

```json
{
  "token": "tok_test_visa",
  "cardholder_name": "Mohamed Yasser",
  "set_default": true
}
```

`tok_test_visa` is a development fake-gateway example, **not** a live token.
The token is a required string, at most 2048 characters; the optional name is at
most 120 characters, and `set_default` is an optional boolean.

The first saved card becomes the default automatically. Adding or setting a
default returns the updated card under `data.card`. Selecting a card for
one top-up can remain local state; call the default endpoint only if the user
wants to change the saved default.

Deleting a default card promotes the newest remaining card. Refresh the card
list after deletion. Invalid or other-user IDs on set-default/delete return 404
with `Card not found.`.

Raw card number, CVV/CVC, and expiry entry from the Add Card design must not be
posted to the wallet or saved-card API. The card endpoint prohibits
`card_number`, `number`, `cvv`, `cvc`, `security_code`, and
`expiry_date`. Gateway tokens are not returned by the list-card API.
Use only the agreed development fixtures until the provider token flow is ready.

## 10. Dart examples for the Flutter client

These snippets use Dart primitives and can be connected to the project's
existing HTTP client and state management. They are examples, not a generated
SDK or a payment-provider implementation.

### Parse the wallet balance safely

```dart
class WalletBalance {
  final int id;
  final int balanceHalalas;
  final String currency;

  const WalletBalance({
    required this.id,
    required this.balanceHalalas,
    required this.currency,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      id: (json['id'] as num).toInt(),
      balanceHalalas: (json['balance_halalas'] as num).toInt(),
      currency: json['currency'] as String,
    );
  }

  double get balanceSar => balanceHalalas / 100;
}

// After checking the HTTP status and success flag:
WalletBalance walletFromSuccess(Map<String, dynamic> response) {
  final data = response['data'] as Map<String, dynamic>;
  return WalletBalance.fromJson(data['wallet'] as Map<String, dynamic>);
}
```

The same parsing function works for an overview success and a top-up success.
For display, format to two decimal places. For transaction dates, use
`DateTime.tryParse(value)?.toLocal()` when the value is non-null.

### Keep a top-up attempt immutable

```dart
class WalletTopUpAttempt {
  final int amountHalalas;
  final int paymentMethodId;
  final String idempotencyKey;

  const WalletTopUpAttempt({
    required this.amountHalalas,
    required this.paymentMethodId,
    required this.idempotencyKey,
  });

  // Builds an exact SAR decimal string without floating-point multiplication.
  // Validate a positive amount and overview limits before creating the attempt.
  String get amountSar {
    final whole = amountHalalas ~/ 100;
    final fraction = (amountHalalas % 100).toString().padLeft(2, '0');
    return '${whole}.${fraction}';
  }

  Map<String, dynamic> toBody() => {
    'amount': amountSar,
    'payment_method_id': paymentMethodId,
  };

  Map<String, String> toHeaders() => {
    'Idempotency-Key': idempotencyKey,
  };
}
```

When the customer confirms, generate a UUID using the app's existing UUID
utility and construct one `WalletTopUpAttempt`. Send `toBody()` as JSON
to `POST /api/v1/wallet/top-up`, and merge `toHeaders()` with the
authentication/language headers.

Keep that object across retry attempts. If unresolved requests survive app
restarts, persist the key, amount, and card ID under the current customer
account; never reuse another account's attempt. Clear the active UI state when
switching accounts. Keep token storage in the app's existing authentication
layer.

For field errors, `errors` is a map of field names to arrays of strings.
For unknown transaction statuses or incomplete card/merchant metadata, render
a neutral fallback instead of throwing a parsing exception.

## 11. Postman walkthrough

Import either collection:

- [Main Backend collection](../postman/Backend%20API.postman_collection.json)
- [Standalone Wallet/Payments collection](postman/NowDelivery-Payments.postman_collection.json)

In the main collection, open:

```text
User App
  > 04 - Checkout & Payments
  > 5. Wallet, Payments & Cards (user)
  > 1. Wallet
```

The requests are `Wallet Overview`, `Wallet Transactions`, and
`Top Up Wallet`. The adjacent `2. Saved Cards` folder contains
`List Cards`, `Add Card`, `Set Default Card`, and `Delete Card`.
The standalone collection exposes `1. Wallet` and `2. Saved Cards`
directly.

Configure `base_url` and `user_token`. In the agreed fake-gateway
development environment, run Add Card first; its script stores `card_id`.
Then set `wallet_topup_amount` and run Top Up Wallet.

For a new top-up, use a new `wallet_topup_idempotency_key`. Repeat the
exact request with the existing key to test replay: it must return the same
transaction ID and must not increase the balance again.

## 12. Flutter acceptance checklist

- Opening a new customer's wallet displays zero balance and an empty history.
- Overview limits drive the amount field and quick-pick buttons.
- Amounts with more than two decimal places are blocked locally and handled as
  server validation errors if submitted.
- A funding card ID is explicitly sent; deleted, expired, non-card, and other-user
  methods are handled without crashing the screen.
- Double-tapping does not create multiple local attempt keys.
- A lost response retains the original amount/card/key tuple.
- Successful replay uses the original transaction ID and replaces the balance
  with `data.wallet`; it does not add the amount again locally.
- Pending/unknown outcomes never generate automatic replacement keys.
- Pull-to-refresh resets history paging; load-more deduplicates by ID.
- Refund rows display the server's sign and `display_status`.
- Missing logos, names, references, expiry data, and settlement timestamps have
  fallback UI.
- Both field-validation and business-error response shapes are supported.
- Arabic and English work via the `lang` header, with fallbacks for existing
  English-only messages.
- Real provider funding and authentication stay deferred until integration is
  supplied and verified.

Customer wallets are store credit. The customer wallet module exposes no cash
withdrawal, wallet-to-wallet transfer, manual balance edit, or direct
customer-triggered refund endpoint.

## 13. Backend contract references

These files are the source of truth when the API changes:

- [Wallet routes](../app/Modules/Wallet/Interfaces/API/V1/Routes/api.php)
- [Wallet controller](../app/Modules/Wallet/Interfaces/API/V1/Controllers/WalletController.php)
- [Top-up request validation](../app/Modules/Wallet/Interfaces/API/V1/Requests/TopUpWalletRequest.php)
- [Wallet resource](../app/Modules/Wallet/Interfaces/API/V1/Resources/WalletResource.php)
- [Transaction resource](../app/Modules/Wallet/Interfaces/API/V1/Resources/WalletTransactionResource.php)
- [Top-up action and retry handling](../app/Modules/Wallet/Application/Actions/TopUpWalletAction.php)
- [Wallet configuration](../config/wallet.php)
- [Saved-card resource](../app/Modules/Payments/Interfaces/API/V1/Resources/PaymentMethodResource.php)
