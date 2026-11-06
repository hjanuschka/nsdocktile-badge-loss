# macOS Dock badge loss -- NSDockTile repro & probes

Tooling used to investigate and prove two macOS PWA Dock-badging bugs for
[crbug.com/579714589](https://issues.chromium.org/issues/579714589)
(`navigator.setAppBadge()` resolves but no badge appears on the Dock).

Fix CL: <https://chromium-review.googlesource.com/c/chromium/src/+/8749061>
Interactive sampler: <https://static.januschka.com/i-579714589/>

## Finding 1: usernoted silently suppresses unauthorized badges

With Chrome's `AppShimNotificationAttribution`, the PWA's app shim registers
its bundle id with `usernoted`. From then on macOS gates
`NSDockTile.badgeLabel` on notification authorization:

- authorization `notDetermined`: `setAppBadge(5)` resolves, **no prompt, no
  badge** -- silent suppression.
- granting via System Settings makes the *remembered* label appear instantly,
  without the app re-setting it.

## Finding 2: Dock relaunch wipes badges, identical re-sets are no-ops

Attribution-independent, affects any app using `NSDockTile.badgeLabel`:

1. The Dock process loses **all tile state** when it relaunches -- which
   happens at every login (`killall Dock` simulates it).
2. AppKit caches `badgeLabel` client-side and **skips notifying the Dock when
   the value does not change**. So after a Dock relaunch, re-setting the
   *same* badge value is a silent no-op: the badge stays gone until the value
   actually changes (e.g. clear + set).

Net effect for PWAs: badge disappears at login; a web app re-sending the same
unread count never gets its badge back, while `setAppBadge()` keeps resolving
and System Settings look perfectly fine.

### Repro (any Cocoa app)

```sh
swiftc mkappicon.swift -o mkappicon && ./mkappicon   # writes appicon.png
swiftc badgeapp.swift -o badgeapp
./badgeapp 5          # app appears in the Dock with a real "5" badge
killall Dock          # badge is gone and does not come back
```

## Probes: how to detect a Dock relaunch from an app

`probes/` contains the detection experiments (run one, then `killall Dock`):

| probe | mechanism | result |
|---|---|---|
| `probe_nsworkspace_notifications.swift` | `NSWorkspace.didLaunchApplicationNotification` | does **not** fire for the Dock |
| `probe_workspace_dist_screen.swift` | workspace launch/terminate, distributed notifications, screen params | nothing fires |
| `probe_kvo_isterminated.swift` | KVO on the Dock's `NSRunningApplication.isTerminated` | **fires reliably** |

The KVO approach is what the Chromium fix uses: observe the Dock's
`NSRunningApplication`, re-arm on the relaunched instance, and re-apply the
cached badge label (forcing the update through AppKit's same-value dedupe by
clearing first).

```sh
swiftc probes/probe_kvo_isterminated.swift -o probe && ./probe
# in another terminal: killall Dock
```

## Repro PWA

`pwa/` is the minimal installable PWA used against a Chromium dev build
(buttons for `Notification.requestPermission()`, `setAppBadge(5)`,
`clearAppBadge()`):

```sh
cd pwa && python3 -m http.server 8765
# install from http://localhost:8765/ in Chrome/Chromium
```

## Misc

- `capture_dock_icon.sh <dock item name> <out.png>`: screenshots a single
  Dock tile (rect via the Dock's accessibility tree) -- captures only that
  icon, nothing else on screen.
- `pwa/mkicon.swift`: regenerates the PWA icons.

Verified on macOS 26.x (Darwin 25.6, Apple Silicon). No warranty; research
tooling, expects a GUI session and (for the capture script) accessibility +
screen-recording permissions.
