import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps SDK API key — used by the google_maps_flutter plugin (Add
    // Address screen's live map). Currently set to the same key used on
    // Android (AndroidManifest.xml) and for the Geocoding API
    // (api_constants.dart). If that key is restricted to "Android apps" in
    // Google Cloud Console, it will NOT work here — iOS needs either an
    // unrestricted key or one separately restricted to this app's bundle ID
    // (com.service.urbanService) under "Maps SDK for iOS".
    GMSServices.provideAPIKey("AIzaSyCqhp43e2-dckwF04XtGyFMeTQKxkjpfD4")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
