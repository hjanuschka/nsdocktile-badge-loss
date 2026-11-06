import AppKit

let args = CommandLine.arguments
let badge = args.count > 1 ? args[1] : ""   // "" = no badge, else label

let app = NSApplication.shared
app.setActivationPolicy(.regular)

if let icon = NSImage(contentsOfFile: "/tmp/badge_demo/appicon.png") {
  app.applicationIconImage = icon
}
if !badge.isEmpty {
  app.dockTile.badgeLabel = badge
}
app.dockTile.display()

// print a marker once the dock tile is up, then idle so we can capture it.
DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
  print("DOCK_READY pid=\(ProcessInfo.processInfo.processIdentifier)")
  fflush(stdout)
}
app.run()
