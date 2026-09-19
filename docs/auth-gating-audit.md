# Auth-Gating Audit — Now Delivery User App

_Which locations and actions require login, and which are open to guests._

Last reviewed: 2026-08-12.

## Policy

Guests may **browse** (home, categories, search, stores, products, promos, FAQ, privacy) **and build/view a cart**. Anything else that is **user-specific, money-related, or account-bound** requires login — the guest is sent to phone verification first. Login on the cart path is enforced at **checkout**, not on the cart screen or add-to-cart (deliberate: guests can fill a cart, then log in to check out).

## How gating works

- **Login state** is a single JSON blob in SharedPreferences (`{token, isGuest}`), read via `WelcomeCacheService().getToken()`. Guest vs user is *one token slot + an `isGuest` flag*, not two tokens. Canonical resolver: `AuthRepo.getSessionType()` (`lib/features/auth/data/repo/auth_repo.dart`).
- **Route gating**: gated routes attach `redirect: _redirectToLogin` in `lib/core/routing/app_router.dart` — a guest is redirected to `phone-verification`.
- **Action gating**: in-widget actions that no route covers (add-to-cart, favourite, cart tab) call `redirectGuestToLogin(context)` from `lib/core/utils/auth_guard.dart` — the single shared helper. Returns `true` (tap consumed, bounce to login) for a guest, `false` (proceed) for a user.
- **API auth**: `AuthTokenInterceptor` (`lib/core/dio/interceptors/`) attaches `X-Guest-Token: <token>` for guests and `Authorization: Bearer <token>` for users, so the backend can enforce independently.

## 1. Auth / onboarding flow

| Route (`name` / path) | Screen | Behaviour |
|---|---|---|
| `splash` `/` | SplashScreen | entry point |
| `onboarding` `/onboarding` | OnBoardingScreen | redirects to `/main` if any token exists |
| `phone-verification` | PhoneVerificationScreen | redirects to `/main` if already a logged-in user |
| `otp-verification` | OtpVerificationScreen | redirects to `/main` if already a logged-in user |

## 2. Open to guests — browsing

No redirect (correct): `main` (shell), `cart`, `categories`, `category-details`, `search`, `all-stores`, `store-details`, `store-category-products`, `product-details`, `top-brands`, `most-popular`, `offers-cannot-wait`, `faq`, `privacy-policy`.

The **cart** (screen, tab, and add-to-cart) is intentionally open to guests — see Policy.

The **Settings/Profile** tab is also open — it's the entry point to the gated features via their own gated routes, and adapts its UI (e.g. hides Log Out for guests).

## 3. Requires login (route-gated via `_redirectToLogin`)

`wallet`, `notifications`, `personal-information`, `checkout`, `my-address`, `discount-code`, `support`, `order-details`, `favourites`, `order-confirmed`, `track-order`, `payment-failed`, `address-details`, `add-address-from-map`, `address-search`, `payment-methods`, `add-payment-card`, `edit-information`, `file-complaint`.

## 4. Action-level gates (`redirectGuestToLogin`)

| Action | Where |
|---|---|
| Switch to Favourites / Orders bottom-nav tab | `lib/features/main/presentation/screens/main_screen.dart` (`_loginRequiredTabs = {1, 3}`) |
| Add / remove favourite (heart icon) | `lib/core/presentation/widgets/favourites/circular_app_favourite_icon.dart` |
| Checkout (bottom button and per-store pill) | `lib/features/cart/presentation/widgets/cart/cart_view.dart` (`_checkout`) |

Adding to cart and opening the cart are **not** gated (see Policy). Login is enforced when the user leaves the cart for `checkout`. The `checkout` **route** is gated too, but that redirect alone is not enough: `_checkout` drafts the order first and pushes only on success, so a guest would fail the draft and never reach the route — hence the action-level gate.

## 5. Gaps found and closed (this audit)

Before this pass, gating was route-redirect-only with these holes — all now fixed:

- **`favourites` route** ungated (only the tab was gated).
- **`order-details`, `order-confirmed`, `track-order`, `payment-failed`** ungated.
- **`address-details`, `add-address-from-map`, `address-search`** ungated while `my-address` was gated.
- **`payment-methods`, `add-payment-card`** ungated.
- **`edit-information`** ungated while `personal-information` was gated.
- **`file-complaint`** ungated while `support` was gated.
- **Duplicated guard logic** — the `isGuest`→push-verification snippet was copy-pasted inline; consolidated into `redirectGuestToLogin` (`lib/core/utils/auth_guard.dart`).

## 6. Known limitations (not addressed here)

- Token is stored in plain **SharedPreferences**, not secure storage.
- `AuthRepo.getSessionType()` trusts the `isGuest` flag alone; its doc-comment claims it also checks token emptiness.
- The `no-internet` route constant is declared with no matching `GoRoute`.
- Client gating is defense-in-depth; the backend must still reject guest (`X-Guest-Token`) requests to protected endpoints.
