import AppKit
let nc = NSWorkspace.shared.notificationCenter
nc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { note in
  let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
  print("LAUNCH: \(app?.bundleIdentifier ?? "?")")
  fflush(stdout)
}
print("watching for 12s...")
RunLoop.main.run(until: Date().addingTimeInterval(12))
