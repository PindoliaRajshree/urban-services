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
    // Address screen's live map). Read from Info.plist's MapsApiKey, which
    // is filled from MAPS_API_KEY in Flutter/Secrets.xcconfig (gitignored;
    // see README "Local config"). If the key is restricted to "Android
    // apps" in Google Cloud Console it will NOT work here — iOS needs a key
    // restricted to this app's bundle ID under "Maps SDK for iOS".
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "MapsApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
