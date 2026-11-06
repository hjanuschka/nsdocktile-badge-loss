import AppKit
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { _ in
  print("SCREEN PARAMS CHANGED"); fflush(stdout)
}
// also KVO the Dock process object for termination
if let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first {
  print("dock pid=\(dock.processIdentifier)"); fflush(stdout)
  var obs: NSKeyValueObservation? = nil
  obs = dock.observe(\.isTerminated, options: [.new]) { d, _ in
    print("DOCK TERMINATED (kvo)"); fflush(stdout)
    _ = obs
  }
  objc_setAssociatedObject(app, "obs", obs, .OBJC_ASSOCIATION_RETAIN)
}
DispatchQueue.main.asyncAfter(deadline: .now() + 12) { app.terminate(nil) }
print("watching 12s..."); fflush(stdout)
app.run()
