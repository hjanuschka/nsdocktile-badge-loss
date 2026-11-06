#!/bin/bash
# Capture ONLY one Dock tile by app name. No other Dock icons, no desktop.
# usage: capture_dock_icon.sh "<dock item name>" <output.png>
NAME="$1"; OUT="$2"
RECT=$(osascript <<OSA 2>/dev/null
tell application "System Events" to tell process "Dock"
  repeat with di in (UI elements of list 1)
    set nm to ""
    try
      set nm to name of di
    end try
    if nm is "$NAME" then
      set p to position of di
      set s to size of di
      return ((item 1 of p) as string) & "," & ((item 2 of p) as string) & "," & ((item 1 of s) as string) & "," & ((item 2 of s) as string)
    end if
  end repeat
  return "NOTFOUND"
end tell
OSA
)
if [ "$RECT" = "NOTFOUND" ] || [ -z "$RECT" ]; then
  echo "dock item '$NAME' not found"; exit 1
fi
IFS=',' read -r X Y W H <<<"$RECT"
# pad a few px so the badge (top-right, may slightly overhang) is included, clamp >=0
PAD=3
X=$((X-PAD)); Y=$((Y-PAD)); W=$((W+2*PAD)); H=$((H+2*PAD))
[ "$X" -lt 0 ] && X=0; [ "$Y" -lt 0 ] && Y=0
echo "rect: $X,$Y,$W,$H"
screencapture -x -R"${X},${Y},${W},${H}" -t png "$OUT"
echo "saved $OUT"; ls -l "$OUT"
