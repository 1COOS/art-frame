import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let securityScopedBookmarkStore = SecurityScopedBookmarkStore()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureSecurityScopeChannel(with: flutterViewController)

    super.awakeFromNib()
  }

  private func configureSecurityScopeChannel(with flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "art_frame/security_scope",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleSecurityScope(call: call, result: result)
    }
  }

  private func handleSecurityScope(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let paths = arguments["paths"] as? [String] else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Expected a paths array.",
          details: nil
        )
      )
      return
    }

    do {
      switch call.method {
      case "persistPaths":
        try securityScopedBookmarkStore.persistBookmarks(for: paths)
        result(nil)
      case "startAccessingPaths":
        try securityScopedBookmarkStore.startAccessingPaths(paths)
        result(nil)
      case "syncKnownPaths":
        securityScopedBookmarkStore.syncKnownPaths(paths)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      result(
        FlutterError(
          code: "security_scope_error",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }
}

private final class SecurityScopedBookmarkStore {
  private let defaultsKey = "art_frame_security_scoped_bookmarks"
  private var activeURLs: [String: URL] = [:]

  func persistBookmarks(for paths: [String]) throws {
    var storedBookmarks = loadStoredBookmarks()

    for path in normalizedPaths(paths) {
      let url = URL(fileURLWithPath: path)
      let data = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      storedBookmarks[path] = data.base64EncodedString()
    }

    saveStoredBookmarks(storedBookmarks)
  }

  func startAccessingPaths(_ paths: [String]) throws {
    var storedBookmarks = loadStoredBookmarks()

    for path in normalizedPaths(paths) {
      if activeURLs[path] != nil {
        continue
      }

      guard let encodedBookmark = storedBookmarks[path],
            let bookmarkData = Data(base64Encoded: encodedBookmark) else {
        continue
      }

      var isStale = false
      let url = try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      if isStale {
        let refreshedData = try url.bookmarkData(
          options: .withSecurityScope,
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        )
        storedBookmarks[path] = refreshedData.base64EncodedString()
      }

      if url.startAccessingSecurityScopedResource() {
        activeURLs[path] = url
      }
    }

    saveStoredBookmarks(storedBookmarks)
  }

  func syncKnownPaths(_ paths: [String]) {
    let allowedPaths = Set(normalizedPaths(paths))
    var storedBookmarks = loadStoredBookmarks()

    for path in storedBookmarks.keys where !allowedPaths.contains(path) {
      if let url = activeURLs.removeValue(forKey: path) {
        url.stopAccessingSecurityScopedResource()
      }
      storedBookmarks.removeValue(forKey: path)
    }

    saveStoredBookmarks(storedBookmarks)
  }

  private func normalizedPaths(_ paths: [String]) -> [String] {
    Array(Set(paths.filter { !$0.isEmpty }))
  }

  private func loadStoredBookmarks() -> [String: String] {
    UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: String] ?? [:]
  }

  private func saveStoredBookmarks(_ bookmarks: [String: String]) {
    UserDefaults.standard.set(bookmarks, forKey: defaultsKey)
  }
}
