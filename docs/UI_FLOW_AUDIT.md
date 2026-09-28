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

All Medium items are fixed. What changed, and what's left:

- **M1 Logout — ✅ fixed.** Logout removes only the account's data (`StorageKeys.sessionKeys` plus the secure token), so device-level flags survive. It also signs out of Google, so the next Google login shows the account picker.
- **M2 Bottom-bar listener leak — ✅ fixed.** It uses `ref.listenManual`, which is cleaned up automatically.
- **M3 Tab switches lost state — ✅ fixed.** `HomeMain` keeps every tab alive in an `IndexedStack` (scroll position, carousel and loaded data), and the nested `SafeArea` is gone. Home no longer re-fetches the address, and the showcase no longer restarts on every tab switch.
  - **Still open:** tab 0 is a `Text('Services')` placeholder.
- **M4 Duplicate Login screens — ✅ fixed.** Register's "Login" link and a manual sign-up both pop back to the Login screen underneath.
- **M5 Forgot password — ✅ fixed.**
  - Pasting a whole code fills every box.
  - A wrong code clears the boxes (`verifyOtp` returns false).
  - A successful reset lands on Login with Welcome underneath.
- **M6 Password rules — ✅ fixed.** Sign-up and reset both use `PasswordValidator.getPasswordError` (`test/core/password_validator_test.dart`).
- **M7 Address loading hid errors — ✅ fixed.**
  - A connection, timeout or server error on the address fetch shows "Couldn't load your address" with Retry. Other failures still mean "no address yet".
  - After login (and Google sign-up), users with a saved address go straight to Home; only users without one see the Address screen. That matches what a restart does. This uses the GET API only.
  - **Backend:** GET `user/get-service-address` currently doesn't return the latest saved address. The app keeps using it as the only source; fix it on the backend.
- **M8 Location edge cases — ✅ fixed.**
  - New `core/location/location_helper.dart`: permission, service check and a 15 s `timeLimit` for every current-position request, with a "Taking too long" message.
  - Denied permission closes the dialog with a message.
  - Permanently denied opens Settings; on return, if granted, current location is selected.
- **M9 Map-tap race — ✅ fixed.** Only the latest tap's geocode result fills the fields, and a spinner shows on the map while geocoding.
- **M10 Address dialog — ✅ fixed.**
  - It can be dismissed and has Cancel.
  - "Enter manually" pre-fills from the unsaved manual entry when there is one.
  - The message says "change" when an address already exists.
- **M11 Map picker — ✅ fixed.** It checks `mounted` after the await, disposes `_mapController`, and uses the shared `defaultMapCenter`.
- **M12 Service types error — ✅ fixed.** A failed category or sub-service load shows an error with Retry (`ref.invalidate`).
- **M13 Wizard validation — ✅ fixed.**
  - Price and mobile fields accept digits only; required prices must be above 0.
  - IFSC is uppercased, filtered, limited to 11 characters and checked on Submit.
  - The account number accepts digits only, and a new "Confirm account number" field must match.
- **M14 Image picking crash — ✅ fixed.** `pickCompressedImage` (`features/profile_common/basic_info.dart`) catches camera/gallery failures and explains them.
- **M15 Token storage — ✅ fixed.**
  - The auth token is in `flutter_secure_storage` (`core/session/token_store.dart`). An existing token is migrated from SharedPreferences on first launch.
  - A keychain token left over from a previous iOS install is cleared.
- **M16 Duplicated code — ✅ fixed.**
  - One OTP dialog.
  - One `widgets/home_header.dart` for both Home screens (avatar showcase, greeting, location, actions).
  - One Profile layout.
  - Shared basic-info logic (`features/profile_common/basic_info.dart`: mobile/email checks, DOB, image picking). The user and provider state classes stay separate on purpose, since they hold different fields.
- **M17 Snackbar cut messages off — ✅ fixed.** The toast is full width, shows the whole message, and stays up longer for long messages.

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
  - ✅ `core/utils/password_validator.dart` is now used (M6).
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
- All Medium items (M1, M3–M17).

1. **Store profile status and use it in routing** (H1, H2): add a completion flag to the session and a router redirect. Waiting on the API.
2. **Saved address fields** (H8) and the GET address fix: waiting on the backend.
3. **Booking with real data** (H11): waiting on the API.
4. **The rest of H10**: Payment Methods, Help & Support, Refer & Earn, About Us, Settings.
5. **Low items** (L1–L14).
