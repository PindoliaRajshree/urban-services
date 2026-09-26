# UI Flow Audit — Urban Services

**Date:** 2026-09-26
**Scope:** every screen flow for both roles (user and provider), read from the code after the Riverpod / go_router migration. Nothing here was checked on a device.

**How to read it:**
- File paths are relative to `lib/` and use the new file names.
- **✅ Fixed** means the migration already fixed it.
- Everything else is still open, in priority order. Each entry gives the problem, then a suggested fix.

## Flow map

```
Splash ─┬─ has token ──────────────────────────────► HomeMain (tab by role)
        └─ no token ─► Welcome ─► (pick role) ─► Login ─┬─ user     ─► Address ─► HomeMain
                                                        └─ provider ───────────► HomeMain
                                   Login ─► Register (manual → Login | Google → same as login)
                                   Login ─► Forgot password ─► Check email (OTP) ─► Reset ─► Login
HomeMain tabs: Services (placeholder) · Bookings · Home (user/provider) · Chat · Profile
User:     Home avatar ─► Complete profile (single page)
          Home ─► Category ─► Service details ─► Book ─► Payment ─► Success ─► Live tracking
Provider: Home avatar ─► Complete profile (3-step wizard)
Any 401 from the API ─► session cleared ─► Welcome   (new)
```

---

## 🔴 Critical

### C1. Registration never saves the user ID, so saving an address fails (user)
- **Where:**
  - `core/session/session_provider.dart` — `saveRegister` saves only the token and role.
  - `features/address/address_provider.dart` (`_fetchAndSaveCurrentLocation`) and `add_address_provider.dart` (`saveAddress`) both need `session.userId`.
- **What happens:**
  1. The user signs up with Google.
  2. The app sends them to the Address screen.
  3. Saving an address fails with "You're not logged in. Please log in again."
- **Fix:** have `saveRegister` store the same fields as `saveLogin` (`RegisterResponse` already parses `userId`, name, email and mobile). Better still, stop sending `user_id` from the app and let the backend take it from the token (see H8).

### C2. A manual sign-up leaves the user logged in without ever logging in
- **Where:** `features/authentication/register/register_provider.dart` `_handleResult`. It saves the token and then goes to Login.
- **What happens:**
  1. The user signs up manually.
  2. They kill the app on the Login screen.
  3. On the next launch, Splash finds the token and opens Home, with no user ID or name saved (so C1 applies too).
- **Fix:** either don't store the token after a manual sign-up, or treat sign-up as a login (store the full session and route by role).

### C3. ✅ Fixed — an expired login was never detected
- **Before:** an expired token left the user on Home while every API call failed.
- **Now:** `core/network/auth_interceptor.dart` clears the session on a 401 (exactly once, even if several requests fail together), and the router sends the user to Welcome.
- **Not affected:** login, register, forgot-password and logout calls, which are marked `skipAuth`.

### C4. The Google Maps API key is committed in three places
- **Where:**
  - `core/constants/api_constants.dart:74`
  - `android/app/src/main/AndroidManifest.xml:39`
  - `ios/Runner/AppDelegate.swift:18`
- **Problem:** the same key is also used for the Geocoding web API straight from the app, and an app restriction can't really protect a web-API key.
- **Fix:**
  - Rotate the key and restrict it by API.
  - Inject it at build time (`--dart-define`, `local.properties`, xcconfig).
  - Ideally, reverse-geocode through the backend.

### C5. Location permission can never be granted on iOS
- **Where:** `ios/Runner/Info.plist` has no `NSLocationWhenInUseUsageDescription`, and there's no Podfile with `PERMISSION_LOCATION=1` for `permission_handler`.
- **Impact:** every permission request returns denied, and the App Store will reject the build.
- **Fix:** add the Info.plist entry and the Podfile macro.

---

## 🟠 High

### H1. User profile completion saves nothing, and the OTP is fake (user)
- **User form:** `features/home/complete_profile/user_complete_profile_provider.dart` `submitProfile` only navigates to Home. There's no API call.
- **OTP dialog** (`widgets/verify_number_dialog.dart`):
  - It accepts any non-empty code and never sends an OTP.
  - "Resend" can't be tapped.
  - The hint shows 5 dashes.
- **Provider wizard:** it uses the same fake OTP.
- **Fix:** add the profile-update and OTP endpoints for the user role. Block Submit until the number is verified.

### H2. Profile completion is never stored, so the "complete your profile" highlight never stops
- **Where:** `features/home/home_screen.dart:40` and `features/home_provider/provider_home_screen.dart:41` start the showcase on every `initState`.
- **Why it repeats:** `HomeMain` rebuilds its tab widgets on every tab change, so the showcase comes back each time the user returns to Home.
- **Also:** Splash and Login never check whether the profile is complete.
- **Fix:**
  - Store `profile_completed` (from the API) in the session.
  - Only show the showcase while it's false, plus a "seen" flag.
  - Consider a router redirect to the completion screen.

### H3. The back arrow on tab screens does nothing, and the Android back button exits the app
- **Where:** `CommonAppBar` in `features/profile/profile_screen.dart:39,250` and `features/my_bookings/my_bookings_screen.dart:132`.
- **Now:** after the migration the arrow calls `maybePop`, so it no longer shows a blank screen, but it still does nothing.
- **Still broken:** `HomeMain` has no `PopScope`, so Android back exits the app from any tab.
- **Fix:**
  - Hide the arrow on tab roots (`showBackButton: false`).
  - Add a `PopScope` to `HomeMain` that goes back to the Home tab first.

### H4. The role picked on Welcome is silently replaced, and no screen is restricted by role
- **Where:** `login_provider.dart` routes on the role the server returns.
- **What happens:** someone who tapped "Continue as Provider" with a user account lands in the user flow with no message.
- **Missing checks in `routes/app_router.dart`:**
  - A user can open `/completeProviderProfile`.
  - A provider can open `/address` and the booking screens.
- **Fix:**
  - Show a message when the two roles differ.
  - Add role checks to the router's `redirect` (for example, provider-only and user-only route sets).

### H5. Login and Google sign-up continue even when the response has no token
- **Where:** `session_provider.dart` `saveLogin` / `saveRegister` skip saving an empty token, but the callers still show "success" and navigate.
- **Also:** after the redirect on the next API call, the user lands on Welcome with no explanation.
- **Fix:** treat a missing token as an error.

### H6. Provider profile submission — ✅ partly fixed
- **✅ Fixed:**
  - The upload data (FormData) is now built inside `safeApiCall`, so an unreadable file no longer leaves the button stuck on loading.
  - The upload now waits up to 2 minutes.
  - A second tap while submitting is ignored.
- **Still open:**
  - The profile photo has no size limit or compression (`complete_profile_provider.dart` `pickPhotoFor`).
  - Documents are sent at full camera resolution.

### H7. Leaving the provider wizard loses everything (provider)
- **Where:** `features/home_provider/complete_profile/complete_profile_screen.dart`.
- **Problem:** the app-bar back goes back one step, but the Android back button closes the whole wizard. There's no "discard changes?" prompt and no saved draft.
- **Fix:** add a `PopScope` that calls `_previousStep`, plus a confirmation on step 0.

### H8. The saved address ignores the map pin and the "default" checkbox (user)
- **Where:** `features/address/models/service_address_request.dart` has no latitude, longitude or "is default" fields, although the response has them.
- **Problem:** the map pin and "Save as default" (`add_address_provider.dart`) are thrown away.
- **Also:** `user_id` is sent from the app. The backend must take it from the token (or at least check it).
- **Fix:** add the fields to the request, and drop `user_id` once the backend reads it from the token.

### H9. Home and Profile always show placeholder people
- **Where:**
  - "Hi, Anamika" / "Indore, MP": `home_screen.dart:139,155` and `provider_home_screen.dart:141,157`.
  - "Ram Kumar Yadav", a rating and "Deep Cleaning": `profile_screen.dart:72,283`.
- **Problem:** users see a provider-style rating and category.
- **Fix:** read the name from `sessionProvider` and the city from `addressProvider` or the profile API.

### H10. Every Profile menu item does nothing, so the address can't be changed
- **Where:** `profile_screen.dart:162` onwards (`onTap: () {}` on every item).
- **Problem:** once past the Address screen, a user can't change their address. The location on Home can't be tapped either.
- **Fix:** link "Saved Address" to `/address` (a "manage" mode that pops instead of going to Home), and hide menu items that aren't built yet.

### H11. The booking flow always uses fake data (user)
- **Where:**
  - Dates are hard-coded to May 2024, with a fixed "2024" (`booking_service_screen.dart:427`).
  - The address is a constant.
  - "Pay" goes straight to success, and the success screen shows the default booking ID and service name (`routes/route_args.dart`).
  - Back from the success screen returns to the booking screen.
- **Fix:**
  - Generate dates from `DateTime.now()`.
  - Pass the real address and service through the route arguments.
  - Use `context.go` to the success screen.
  - Integrate payments before release.

---

## 🟡 Medium

- **M1 Logout — ✅ fixed.** The old `Get.deleteAll(force: true)` is gone; screen state resets because the providers depend on the session.
  - **Still open:** logout clears *all* stored preferences (future flags like "seen showcase" will be lost too), and Google sign-in isn't signed out.
  - **Fix:** clear only the session keys, and call `GoogleSignIn().signOut()`.
- **M2 Bottom-bar listener leak — ✅ fixed.** It now uses `ref.listenManual`, which is cleaned up automatically.
- **M3 Tab switches lose state.** `home_main/home_main.dart` rebuilds the tab widgets on every switch (scroll position and carousel are lost), and has nested `SafeArea`s. Tab 0 is a `Text('Services')` placeholder.
  - **Fix:** use an `IndexedStack`, or `StatefulShellRoute` like the starter kit.
- **M4 Duplicate Login screens.** Login → Sign Up → "Login" uses `pushReplacement`, leaving [Welcome, Login, Login].
  - **Fix:** use `context.pop()` when Login is already underneath.
- **M5 Forgot password.**
  - OTP boxes aren't cleared after a wrong code.
  - Pasting a whole code isn't supported (`maxLength: 1`).
  - A successful reset uses `go(login)`, which removes Welcome from the stack.
- **M6 Password rules don't match.** Reset only requires 8 characters; sign-up requires 8–20 with upper, lower, digit and special. `core/utils/password_validator.dart` exists but isn't used.
  - **Fix:** use it in both places.
- **M7 Address loading hides errors.** `address_provider.dart` `fetchAddress` treats a network error or 500 as "no address saved yet", with no retry.
  - **Also:** users must press Next on every login, while a restart skips the Address screen entirely.
- **M8 Location edge cases.**
  - When permission is denied, the dialog stays open with no message.
  - When it is permanently denied, the dialog closes before the user comes back from Settings.
  - `Geolocator.getCurrentPosition` has no time limit anywhere, so it can spin forever.
  - **Fix:** add `timeLimit: Duration(seconds: 15)`.
- **M9 Map-tap race.** Rapid taps on the Add Address map can finish out of order, and the results overwrite what the user typed. There's no loading indicator for taps.
- **M10 Address dialog.**
  - `widgets/address_choice_dialog.dart` can't be dismissed and has no Cancel.
  - "Enter manually" pre-fills from the *saved* address, not the unsaved manual entry.
  - The text says "We need a service address to continue" even when the user is only changing it.
- **M11 Map picker.** `full_screen_map_picker.dart` calls `setState` after an `await` without a `mounted` check, and never disposes `_mapController`. The default map centre is defined twice.
- **M12 Service types have no error or retry.** When `serviceTypesProvider` / `subServiceTypesProvider` fail, the dropdown is just empty.
  - **Fix:** show `AsyncValue.error` with a retry (`ref.invalidate`).
- **M13 Weak wizard validation.**
  - Price fields accept any text.
  - IFSC is only checked on "Verify", with no uppercase formatter.
  - Account number has no digits-only filter and no confirmation field.
  - Mobile fields have no digits-only filter.
- **M14 Image picking can crash.** There's no try/catch around `pickImage`, so a camera-permission denial throws.
- **M15 Tokens are stored in plain SharedPreferences.**
  - **Fix:** consider `flutter_secure_storage` for the auth token.
- **M16 Duplicated code.**
  - ✅ The OTP dialog is now one shared widget.
  - The avatar/greeting/showcase header is still duplicated in the two home screens.
  - The Profile screen is written twice (small vs large layout).
  - The basic-info notifier logic is duplicated between user and provider.
- **M17 Snackbar messages can hide backend detail.** Validation errors now show the first field error. Consider showing `ApiFailure.fieldErrors` on the fields themselves.

## 🟢 Low

- **L1** The base URL contains a space and points at a test path on a third-party domain.
  - **Fix:** use flavors or `--dart-define`.
- **L2** Splash always waits a fixed 3 s on top of a 2 s animation.
- **L3** Sign-up:
  - The Terms & Policy text can't be tapped.
  - The comment says email is optional, but it's required.
  - The mobile field has no length limit.
- **L4** Both Login and Google buttons show a spinner while either is loading.
- **L5** Date of birth allows ages under 18 (`lastDate: DateTime.now()`).
- **L6** Provider "Available for Work" is local only. Dashboard numbers and bookings are hard-coded, and the absolutely-positioned badges overlap long text.
- **L7 Overflow.**
  - The widget test shows the **Welcome buttons overflow** when text is wider (large accessibility font sizes).
  - The service-radius chip row, the fixed-height Profile layout and the header rows are also at risk.
  - **Fix:** use `Flexible`/`FittedBox` in `SecondaryButton` and `PrimaryButton`.
- **L8** Theming is minimal (seed colour and font only). Every screen styles its own fields, and raw font sizes and shadows are repeated.
- **L9** Dead code:
  - `core/utils/password_validator.dart` (unused)
  - The commented-out `CompleteProfileCard`
  - The `flutter_easyloading` dependency
  - Several dependencies never used: `connectivity_plus`, `internet_connection_checker_plus`, `firebase_crashlytics`, `firebase_messaging`, `cached_network_image`
- **L10** Route arguments fall back to fake defaults (`routes/route_args.dart`), which hides callers that forget to pass data.
- **L11** All text is hard-coded; there's no localisation.
- **L12** The geocoding SHA-1 is the release key's, so debug builds fall back to on-device geocoding when the key is app-restricted.
- **L13** Chat search and the booking notes counter call `setState` on every keystroke. Fine for now.
- **L14** Crashlytics is a dependency but is never initialised.
  - **Fix:** wire `FlutterError.onError` / `PlatformDispatcher.onError` to it for release builds.

---

## Suggested fix order

1. **Save the session consistently** (C1, C2, H5): one path in `SessionNotifier` for login and both sign-up types.
2. **Config and iOS setup** (C4, C5).
3. **Store profile status and use it in routing** (H1, H2, M7): add a completion flag to the session and a router redirect.
4. **Navigation polish** (H3, H4, H7, M3, M4): `PopScope`, role checks in `redirect`, and `StatefulShellRoute`.
5. **Real data on Home, Profile and Booking** (H9, H10, H11).
6. **Validation, error states and shared widgets** (M6, M8, M12–M16).
