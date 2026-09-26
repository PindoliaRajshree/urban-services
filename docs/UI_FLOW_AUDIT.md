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

### C1. ✅ Fixed — registration never saved the user ID, so saving an address failed (user)
- **Before:** Google sign-up saved only the token and role, so saving an address failed with "You're not logged in".
- **Now:** `saveLogin` and `saveRegister` in `core/session/session_provider.dart` share one `_saveSession` that stores the token, user ID, name, email, mobile and role.
- **Still open:** stop sending `user_id` from the app and let the backend take it from the token (see H8).

### C2. ✅ Fixed — a manual sign-up left the user logged in without ever logging in
- **Before:** a manual sign-up stored the token and then went to Login, so a restart opened Home with a half-empty session.
- **Now:** `register_provider.dart` stores nothing after a manual sign-up. The user logs in on the Login screen.

### C3. ✅ Fixed — an expired login was never detected
- **Before:** an expired token left the user on Home while every API call failed.
- **Now:** `core/network/auth_interceptor.dart` clears the session on a 401 (exactly once, even if several requests fail together), and the router sends the user to Welcome.
- **Not affected:** login, register, forgot-password and logout calls, which are marked `skipAuth`.

### C4. ✅ Partly fixed — the Google Maps API key was committed in three places
- **Now:** the key is read at build time from gitignored files (see README "Local secrets"):
  - `dart_defines.json`, via `--dart-define-from-file`
  - `android/local.properties`, via a manifest placeholder
  - `ios/Flutter/Secrets.xcconfig`, via the Info.plist `MapsApiKey` entry
- **Still open:**
  - The old key is still in git history. Rotate it and restrict it by API.
  - The same key is used for the Geocoding web API straight from the app, and an app restriction can't really protect a web-API key. Ideally, reverse-geocode through the backend.

### C5. ✅ Fixed — location permission could never be granted on iOS
- **Now:**
  - `Info.plist` has `NSLocationWhenInUseUsageDescription`.
  - `ios/Podfile` sets `PERMISSION_LOCATION=1` for `permission_handler`.
  - The iOS deployment target is now 14.0, which `google_maps_flutter` needs.
- **Not yet checked on a device.** Needs a Mac: run `pod install`, then run the app.

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

### H3. ✅ Fixed — the back arrow on tab screens did nothing, and Android back exited the app
- **Now:**
  - `CommonAppBar` has `showBackButton`, which is off on the Bookings and Profile tabs.
  - `HomeMain` has a `PopScope`: back from any other tab goes to Home, and back from Home exits.

### H4. ✅ Fixed — the role picked on Welcome was silently replaced, and no screen was restricted by role
- **Now:**
  - Login and Google sign-up show "This account is registered as a …" when the account's role differs from the one picked (`roleMismatchMessage` in `core/session/user_role.dart`).
  - `routes/app_router.dart` has provider-only and user-only route sets. The other role is redirected to HomeMain (`appRedirect`, covered by `test/core/routing_test.dart`).

### H5. ✅ Fixed — login and Google sign-up continued even when the response had no token
- **Now:** `saveLogin` / `saveRegister` return `false` when there's no token, and the callers show an error instead of navigating.

### H6. ✅ Fixed — provider profile submission
- The upload data (FormData) is now built inside `safeApiCall`, so an unreadable file no longer leaves the button stuck on loading.
- The upload waits up to 2 minutes, and a second tap while submitting is ignored.
- Picked images are downscaled and recompressed (profile photo: 1024px; documents: 2000px; quality 80). All four are capped at 4 MB. The user profile photo is downscaled too.

### H7. ✅ Fixed — leaving the provider wizard lost everything (provider)
- **Now:** a `PopScope` makes Android back go one step at a time. Leaving from step 0 with anything entered asks "Discard profile details?" (new shared `widgets/confirm_dialog.dart`).
- **Still open:** there's no saved draft.

### H8. The saved address ignores the map pin and the "default" checkbox (user)
- **Where:** `features/address/models/service_address_request.dart` has no latitude, longitude or "is default" fields, although the response has them.
- **Problem:** the map pin and "Save as default" (`add_address_provider.dart`) are thrown away.
- **Also:** `user_id` is sent from the app. The backend must take it from the token (or at least check it).
- **Fix:** add the fields to the request, and drop `user_id` once the backend reads it from the token.

### H9. ✅ Fixed — Home and Profile always showed placeholder people
- **Now:**
  - Both home screens greet the user by first name from `sessionProvider`.
  - User Home shows the saved city and state from `addressProvider`, or "Add your address".
  - Provider Home has no location line until the provider profile API gives a city.
  - Profile shows the real name plus the email or mobile. The fake rating, category and call/chat icons are gone.

### H10. ✅ Partly fixed — every Profile menu item did nothing, so the address couldn't be changed
- **Now:**
  - "Saved Address" (users only), the Home location line and the location icon open `/address` in manage mode (`AddressArgs(manage: true)`). That mode has a back button and a "Save" button, and pops back after saving.
  - "Profile" opens the completion screen for the user's role.
- **Still open:** Payment Methods, Help & Support, Refer & Earn, About Us and Settings still do nothing.

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
  - ✅ The Profile screen is now built once (small screens wrap it in a `ListView`).
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

✅ Done:
- Session saving (C1, C2, H5), and config and iOS setup (C4, C5). The Maps key still needs to be rotated.
- Navigation (H3, H4, H7), photo size (H6), and real name and city (H9, most of H10).

1. **Store profile status and use it in routing** (H1, H2, M7): add a completion flag to the session and a router redirect. Waiting on the API.
2. **Saved address fields** (H8): waiting on the backend.
3. **Tab state and stack** (M3, M4): `StatefulShellRoute`. This also stops Home re-fetching the saved address on every tab switch.
4. **Booking with real data** (H11): waiting on the API.
5. **Validation, error states and shared widgets** (M6, M8, M12–M16).
