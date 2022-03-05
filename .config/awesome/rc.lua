-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi
-- Notification library
local old_dbus = dbus
dbus = nil
local naughty = require("naughty")
dbus = old_dbus
package.loaded["naughty.dbus"] = {}
-- Declarative object management
local ruled = require("ruled")
-- local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
                          naughty.notification {
                             urgency = "critical",
                             title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
                             message = message
                          }
end)

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
                      awful.layout.append_default_layouts({
                            -- awful.layout.suit.floating,
                            awful.layout.suit.tile,
                            awful.layout.suit.tile.left,
                            awful.layout.suit.tile.bottom,
                            awful.layout.suit.tile.top,
                            awful.layout.suit.fair,
                            awful.layout.suit.fair.horizontal,
                            awful.layout.suit.spiral,
                            awful.layout.suit.spiral.dwindle,
                            awful.layout.suit.max,
                            awful.layout.suit.max.fullscreen,
                            awful.layout.suit.magnifier,
                            awful.layout.suit.corner.nw,
                      })
end)

-- Each screen has its own tag table.
awful.screen.connect_for_each_screen(function(s)
      awful.tag({ "1", "2", "3", "4", "5", "6", "7" }, s, awful.layout.layouts[1])
end)

-- General Awesome keys
awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
         {description="show help", group="awesome"}),
      awful.key({ modkey, "Control" }, "r", awesome.restart,
         {description = "reload awesome", group = "awesome"}),
      awful.key({ modkey, "Shift"   }, "q", awesome.quit,
         {description = "quit awesome", group = "awesome"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
         {description = "view previous", group = "tag"}),
      awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
         {description = "view next", group = "tag"}),
      awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
         {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "j",
         function ()
            awful.client.focus.byidx( 1)
         end,
         {description = "focus next by index", group = "client"}
      ),
      awful.key({ modkey,           }, "k",
         function ()
            awful.client.focus.byidx(-1)
         end,
         {description = "focus previous by index", group = "client"}
      ),
      awful.key({ modkey,           }, "Tab",
         function ()
            awful.client.focus.history.previous()
            if client.focus then
               client.focus:raise()
            end
         end,
         {description = "go back", group = "client"}),
      awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
         {description = "focus the next screen", group = "screen"}),
      awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
         {description = "focus the previous screen", group = "screen"}),
      awful.key({ modkey, "Control" }, "n",
         function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
               c:activate { raise = true, context = "key.unminimize" }
            end
         end,
         {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
      awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
         {description = "swap with next client by index", group = "client"}),
      awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
         {description = "swap with previous client by index", group = "client"}),
      awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
         {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})

-- My keybinding
awful.keyboard.append_global_keybindings({
      awful.key({ modkey }, "Return", function () awful.util.spawn("appsmenu") end,
         {description = "open a apps menu", group = "launcher"}),
      awful.key({ modkey }, "d", function () awful.util.spawn("appslauncher") end,
         {description = "run rofi launcher", group = "launcher"}),
      awful.key({ modkey }, "p", function() awful.util.spawn("powermenu") end,
         {description = "power menu", group = "launcher"}),
      awful.key({ modkey }, "z", function() awful.util.spawn("brightness") end,
         {description = "brightness menu", group = "launcher"}),
      awful.key({ modkey }, "x", function() awful.util.spawn("volume") end,
         {description = "volume menu", group = "launcher"}),
      awful.key({ modkey }, "w", function() awful.spawn.with_shell("feh -z --bg-fill $HOME/Pictures/wallpapers") end,
         {description = "wallpaper change", group = "launcher"}),
      awful.key({        }, "Print", function() awful.util.spawn("screenshot") end,
         {description = "take a screenshot", group = "launcher"})
})

awful.keyboard.append_global_keybindings({
      awful.key {
         modifiers   = { modkey },
         keygroup    = "numrow",
         description = "only view tag",
         group       = "tag",
         on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
               tag:view_only()
            end
         end,
      },
      awful.key {
         modifiers   = { modkey, "Control" },
         keygroup    = "numrow",
         description = "toggle tag",
         group       = "tag",
         on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end,
      },
      awful.key {
         modifiers = { modkey, "Shift" },
         keygroup    = "numrow",
         description = "move focused client to tag",
         group       = "tag",
         on_press    = function (index)
            if client.focus then
               local tag = client.focus.screen.tags[index]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
      },
      awful.key {
         modifiers   = { modkey, "Control", "Shift" },
         keygroup    = "numrow",
         description = "toggle focused client on tag",
         group       = "tag",
         on_press    = function (index)
            if client.focus then
               local tag = client.focus.screen.tags[index]
               if tag then
                  client.focus:toggle_tag(tag)
               end
            end
         end,
      },
      awful.key {
         modifiers   = { modkey },
         keygroup    = "numpad",
         description = "select layout directly",
         group       = "layout",
         on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
               t.layout = t.layouts[index] or t.layout
            end
         end,
      }
})

client.connect_signal("request::default_mousebindings", function()
                         awful.mouse.append_client_mousebindings({
                               awful.button({ }, 1, function (c)
                                     c:activate { context = "mouse_click" }
                               end),
                               awful.button({ modkey }, 1, function (c)
                                     c:activate { context = "mouse_click", action = "mouse_move"  }
                               end),
                               awful.button({ modkey }, 3, function (c)
                                     c:activate { context = "mouse_click", action = "mouse_resize"}
                               end),
                         })
end)

client.connect_signal("request::default_keybindings", function()
                         awful.keyboard.append_client_keybindings({
                               awful.key({ modkey,           }, "f",
                                  function (c)
                                     c.fullscreen = not c.fullscreen
                                     c:raise()
                                  end,
                                  {description = "toggle fullscreen", group = "client"}),
                               awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
                                  {description = "close", group = "client"}),
                               awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                                  {description = "toggle floating", group = "client"}),
                               awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                                  {description = "move to master", group = "client"}),
                               awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                                  {description = "move to screen", group = "client"}),
                               awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                                  {description = "toggle keep on top", group = "client"}),
                               awful.key({ modkey,           }, "n",
                                  function (c)
                                     -- The client currently has the input focus, so it cannot be
                                     -- minimized, since minimized clients can't have the focus.
                                     c.minimized = true
                                  end ,
                                  {description = "minimize", group = "client"}),
                               awful.key({ modkey,           }, "m",
                                  function (c)
                                     c.maximized = not c.maximized
                                     c:raise()
                                  end ,
                                  {description = "(un)maximize", group = "client"}),
                               awful.key({ modkey, "Control" }, "m",
                                  function (c)
                                     c.maximized_vertical = not c.maximized_vertical
                                     c:raise()
                                  end ,
                                  {description = "(un)maximize vertically", group = "client"}),
                               awful.key({ modkey, "Shift"   }, "m",
                                  function (c)
                                     c.maximized_horizontal = not c.maximized_horizontal
                                     c:raise()
                                  end ,
                                  {description = "(un)maximize horizontally", group = "client"}),
                         })
end)

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

local theme_assets = require("beautiful.theme_assets")

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "SauceCodePro Nerd Font Mono 10"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(7)
theme.border_width  = dpi(0)
theme.border_normal = "#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
   taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
   taglist_square_size, theme.fg_normal
)

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- You can use your own layout icons like this:
theme.layout_fairh         = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv         = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating      = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier     = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max           = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen    = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom    = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft      = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile          = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop       = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral        = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle       = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw      = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne      = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw      = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse      = themes_path .. "default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
   theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

beautiful.init(theme)

awful.spawn.with_shell("lf -server")
awful.spawn.with_shell("picom -b --experimental-backends --config $HOME/.config/picom/picom.conf")
awful.spawn.with_shell("$POLYBAR_LAUNCH")
awful.spawn.with_shell("feh -z --bg-fill $HOME/Pictures/wallpapers")
