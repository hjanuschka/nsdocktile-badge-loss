import AppKit
let wnc = NSWorkspace.shared.notificationCenter
for name in [NSWorkspace.didLaunchApplicationNotification,
             NSWorkspace.didTerminateApplicationNotification] {
  wnc.addObserver(forName: name, object: nil, queue: .main) { note in
    let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    print("WS \(name.rawValue): \(app?.bundleIdentifier ?? "?")"); fflush(stdout)
  }
}
NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { _ in
  print("SCREEN PARAMS CHANGED"); fflush(stdout)
}
DistributedNotificationCenter.default().addObserver(forName: nil, object: nil, queue: .main) { note in
  let n = note.name.rawValue
  if n.lowercased().contains("dock") { print("DIST: \(n)"); fflush(stdout) }
}
print("watching 12s..."); fflush(stdout)
RunLoop.main.run(until: Date().addingTimeInterval(12))
