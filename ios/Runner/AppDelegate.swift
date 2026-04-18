import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Custom URL scheme: votera://workspace/join/{code} ─────────────────
  // Also handles https:// deep links on iOS < 13 (no SceneDelegate).
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Let app_links handle it — setIntent equivalent for Flutter.
    if super.application(app, open: url, options: options) { return true }

    let inviteCode = url.lastPathComponent
    if !inviteCode.isEmpty {
      // app_links picks up the URL automatically via the plugin;
      // calling super is sufficient. This block is here for future
      // native handling if needed.
    }
    return true
  }

  // ── Universal Links (iOS 13+, no SceneDelegate): NSUserActivity ───────
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Let app_links handle stream emission first.
    if super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    ) { return true }

    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
      return false
    }

    let inviteCode = url.lastPathComponent
    if !inviteCode.isEmpty {
      // app_links fires uriLinkStream automatically once super returns true.
      // Native-only logic (e.g. a MethodChannel call) would go here.
    }
    return true
  }
}
