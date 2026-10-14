--------------------------------------------------------------------------------
-- Hyprland config (Lua)
-- Docs: https://wiki.hypr.land
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"

local mainMod = "SUPER"

--- Builds a keybind string like "SUPER + Return".
local function mod(keys)
    return mainMod .. " + " .. keys
end


--------------------------------------------------------------------------------
-- Monitors
--------------------------------------------------------------------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


--------------------------------------------------------------------------------
-- Autostart
-- Wrapped in the start event so it runs once per session, not on every reload.
--------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
end)


--------------------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------------------

hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

--------------------------------------------------------------------------------
-- Look and feel
--------------------------------------------------------------------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,
        layout      = "dwindle",

        col = {
            active_border   = { colors = { "rgba(b2d7ffee)", "rgba(393a4bee)" }, angle = 45 },
            inactive_border = "rgba(2f3041aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee0d0d0d,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})


--------------------------------------------------------------------------------
-- Animations
--------------------------------------------------------------------------------

-- Curves
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1    }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0,    0    }, { 1,    1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5,  0.5  }, { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0    }, { 0.1,  1 } } })

hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Each entry is passed to hl.animation(); `enabled` defaults to true.
local animations = {
    { leaf = "global",        speed = 10,   bezier = "default" },
    { leaf = "border",        speed = 5.39, bezier = "easeOutQuint" },

    { leaf = "windows",       speed = 4.79, spring = "easy" },
    { leaf = "windowsIn",     speed = 4.1,  spring = "easy",         style = "popin 87%" },
    { leaf = "windowsOut",    speed = 1.49, bezier = "linear",       style = "popin 87%" },

    { leaf = "fade",          speed = 3.03, bezier = "quick" },
    { leaf = "fadeIn",        speed = 1.73, bezier = "almostLinear" },
    { leaf = "fadeOut",       speed = 1.46, bezier = "almostLinear" },

    { leaf = "layers",        speed = 3.81, bezier = "easeOutQuint" },
    { leaf = "layersIn",      speed = 4,    bezier = "easeOutQuint", style = "fade" },
    { leaf = "layersOut",     speed = 1.5,  bezier = "linear",       style = "fade" },
    { leaf = "fadeLayersIn",  speed = 1.79, bezier = "almostLinear" },
    { leaf = "fadeLayersOut", speed = 1.39, bezier = "almostLinear" },

    { leaf = "workspaces",    speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesIn",  speed = 1.21, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesOut", speed = 1.94, bezier = "almostLinear", style = "fade" },

    { leaf = "zoomFactor",    speed = 7,    bezier = "quick" },
}

for _, anim in ipairs(animations) do
    if anim.enabled == nil then anim.enabled = true end
    hl.animation(anim)
end


--------------------------------------------------------------------------------
-- Layouts, misc, input
--------------------------------------------------------------------------------

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },

    misc = {
        force_default_wallpaper = 0,     -- wallpaper is handled by hyprpaper
        disable_hyprland_logo   = true,
    },

    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0, 0 means no modification

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Per-device config (placeholder name; replace with `hyprctl devices` output)
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------

-- Apps and session
hl.bind(mod("Return"), hl.dsp.exec_cmd(terminal))
hl.bind(mod("E"),      hl.dsp.exec_cmd(fileManager))
hl.bind(mod("D"),      hl.dsp.exec_cmd(menu))
hl.bind(mod("M"),      hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
))

-- Screenshots (requires grim, slurp, wl-clipboard)
local shotDir  = "$HOME/Pictures/Screenshots"
local shotFile = shotDir .. "/$(date +%Y-%m-%d_%H-%M-%S).png"

-- Print: select a region, copy to clipboard
hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- SHIFT + Print: select a region, save to file
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    "mkdir -p " .. shotDir .. [[ && grim -g "$(slurp)" ]] .. shotFile .. [[ && notify-send "Screenshot saved"]]
))

-- CTRL + Print: whole screen, save to file
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p " .. shotDir .. " && grim " .. shotFile .. [[ && notify-send "Screenshot saved"]]
))

-- Notifications (swaync)
hl.bind(mod("N"),         hl.dsp.exec_cmd("swaync-client -t -sw")) -- toggle notification center
hl.bind(mod("SHIFT + N"), hl.dsp.exec_cmd("swaync-client -d -sw")) -- toggle do-not-disturb

-- Window management
hl.bind(mod("Q"), hl.dsp.window.close())
hl.bind(mod("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod("P"), hl.dsp.window.pseudo())
hl.bind(mod("J"), hl.dsp.layout("togglesplit")) -- dwindle only

-- Focus
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod(dir), hl.dsp.focus({ direction = dir }))
end

-- Workspaces: SUPER + [1-0] to switch, SUPER + SHIFT + [1-0] to move window
for i = 1, 10 do
    local key = i % 10 -- workspace 10 is bound to key 0
    hl.bind(mod(key),            hl.dsp.focus({ workspace = i }))
    hl.bind(mod("SHIFT + " .. key), hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mod("S"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mod("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with the mouse
hl.bind(mod("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Media keys (work on the lockscreen too)
local function bindLocked(key, cmd, repeating)
    local opts = { locked = true }
    if repeating then opts.repeating = true end
    hl.bind(key, hl.dsp.exec_cmd(cmd), opts)
end

-- Volume and brightness (hold to repeat)
bindLocked("XF86AudioRaiseVolume",  "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", true)
bindLocked("XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",      true)
bindLocked("XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",     true)
bindLocked("XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",   true)
bindLocked("XF86MonBrightnessUp",   "brightnessctl -e4 -n2 set 5%+",                  true)
bindLocked("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-",                  true)

-- Playback (requires playerctl)
bindLocked("XF86AudioNext",  "playerctl next")
bindLocked("XF86AudioPause", "playerctl play-pause")
bindLocked("XF86AudioPlay",  "playerctl play-pause")
bindLocked("XF86AudioPrev",  "playerctl previous")


--------------------------------------------------------------------------------
-- Window rules
--------------------------------------------------------------------------------

-- Ignore maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Position the hyprland-run launcher
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
