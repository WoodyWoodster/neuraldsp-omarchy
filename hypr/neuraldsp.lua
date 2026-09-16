-- Neural DSP standalone apps (Wine/XWayland).
-- Keep them opaque (default translucency wrecks the amp UI), floating and
-- centered, and inhibit idle while they run. Follows the Steam / Resolve
-- pattern in $OMARCHY_PATH/default/hypr/apps/.
--
-- Class/title values get tightened against `hyprctl clients` output once a
-- title has run; these broad matches are the starting point.

local ndsp = ".*(Archetype|Neural DSP|Gojira|Plini|Nolly|Petrucci|Parallax|Nameless|Soldano|Wong|Abasi|Granophyre|Tone King|Henson|Rabea|Mesa|Fortin|Darkglass|Quad Cortex).*"

o.window({ class = ndsp }, {
  float = true,
  center = true,
  size = { 1280, 800 },
  tag = "-default-opacity",
  opacity = "1 1",
  idle_inhibit = "always",
})

o.window({ title = ndsp }, {
  float = true,
  center = true,
  size = { 1280, 800 },
  tag = "-default-opacity",
  opacity = "1 1",
  idle_inhibit = "always",
})
