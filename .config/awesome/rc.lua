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
      awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", "hidden_tag" }, s, awful.layout.layouts[1])
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

    ruled.client.append_rule {
       rule       = { class = "Evince" },
       properties = { floating = true },
       callback = function(c)
          awful.placement.maximize(c, { margins = beautiful.useless_gap * 2, honor_workarea = true })
       end
    }

    ruled.client.append_rule {
       rule       = { class = "Font-viewer" },
       properties = { floating = true },
       callback = function(c)
          c.width = 1000
          c.height = 600
          awful.placement.centered(c, { margins = { top = 56 }})
       end
    }

    ruled.client.append_rule {
       rule_any   = {
          class = {
             "Rofi",
             "Gpick"
          }
       },
       properties = {
          floating = true,
          ontop    = true,
       }
    }
end)

client.connect_signal('manage', function(c)
                         if c.class == "Gpick" then
                            awful.spawn.with_shell("killall picom")
                         end
                         -- Sometimes the rofi is not in the right position
                         if c.class == "Rofi" and c.x == 0 then
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.class == "Gpick" then
                            awful.spawn.with_shell("picom -b --experimental-backends --config $HOME/.config/picom/picom.conf")
                         end
end)

local terminal_id = 'notnil'
local terminal_client

function create_terminal()
   local t = awful.screen.focused().selected_tag

   for _, c in ipairs(client.get()) do
      if c.instance == "Alacritty-splash" then
         terminal_id = c.pid
         terminal_client = c
         awful.placement.centered(c, { margins = { top = 56 }})
         terminal_client:move_to_tag(t)
         client.focus = terminal_client
         terminal_client:raise()
      end
   end

   if not terminal_client then
      terminal_id = awful.spawn("alacritty --class Alacritty-splash")
   end

   awful.spawn("xdotool key Mode_switch")
end

function toggle_splash_height()
   c = client.focus

   if c.pid == terminal_id or c.class == "firefox" then
      if c.width <= 1350 then
         awful.placement.maximize(c, { margins = beautiful.useless_gap * 2, honor_workarea = true })
      else
         c.width = 1350
         c.height = 800
         awful.placement.centered(c, { margins = { top = 56 }})
      end
   end
end

function toggle_terminal()
   local t = awful.screen.focused().selected_tag
   local c = client.focus

   if not terminal_client then
      create_terminal()
   else
      if c ~= terminal_client then
         terminal_client:move_to_tag(t)
         client.focus = terminal_client
         terminal_client:raise()
         awful.spawn("xdotool key Mode_switch")
      else
         terminal_client:move_to_tag(awful.screen.focused().tags[8])
      end
   end
end

client.connect_signal('manage', function(c)
                         if c.pid == terminal_id then
                            terminal_client = c
                            c.floating = true
                            c.width = 1350
                            c.height = 800
                            client.focus = c
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.pid == terminal_id then
                            terminal_client = nil
                            terminal_id = 'notnil'
                         end
end)

local firefox_id = 'notnil'
local firefox_client

function create_firefox()
   local t = awful.screen.focused().selected_tag

   for _, c in ipairs(client.get()) do
      if c.width == 1350 and c.class == "firefox" then
         firefox_id = c.pid
         firefox_client = c
         awful.placement.centered(c, { margins = { top = 56 }})
         firefox_client:move_to_tag(t)
         client.focus = firefox_client
         firefox_client:raise()
      end
   end

   if not firefox_client then
      firefox_id = awful.spawn("firefox")
   end
end

function toggle_firefox()
   local t = awful.screen.focused().selected_tag
   local c = client.focus

   if not firefox_client then
      create_firefox()
   else
      if c ~= firefox_client then
         firefox_client:move_to_tag(t)
         client.focus = firefox_client
         firefox_client:raise()
      else
         firefox_client:move_to_tag(awful.screen.focused().tags[8])
      end
   end
end

client.connect_signal('manage', function(c)
                         if c.pid == firefox_id then
                            firefox_client = c
                            c.floating = true
                            c.width = 1350
                            c.height = 800
                            client.focus = firefox_client
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.pid == firefox_id then
                            firefox_client = nil
                            firefox_id = 'notnil'
                         end
end)

local emacs_fm_id = 'notnil'

function create_emacs_fm(path)
   emacs_fm_id = awful.spawn.with_shell("alacritty -e lfrun " ..
                                        "-command \"cd " .. path .. "\" " ..
                                        "-command \"map <esc> quit_for_emacs\" " ..
                                        "-command \"map <enter> quit_for_emacs\"")
end

client.connect_signal('manage', function(c)
                         if c.pid == emacs_fm_id then
                            c.ontop = true
                            c.floating = true
                            c.width = 1400
                            c.height = 800
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

local lf_terminal_id = 'notnil'

function create_lf_terminal(command)
   lf_terminal_id = awful.spawn.with_shell("alacritty -e zsh -c '" .. command .. "'")
end

client.connect_signal('manage', function(c)
                         if c.pid == lf_terminal_id then
                            c.ontop = true
                            c.floating = true
                            c.width = 1000
                            c.height = 600
                            client.focus = c
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

local theme_assets = require("beautiful.theme_assets")

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "Iosevka Nerd Font 13"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#cad0da"
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

theme.taglist_bg_focus = "#51afef"
theme.taglist_fg_focus = "#1c252a"

theme.taglist_fg_occupied = "#51afef"

theme.taglist_fg_empty = "#cad0da"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
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

mycpu = wibox.widget {
   {
      id     = "text",
      widget = wibox.widget.textbox
   },
   bg     = "#364852cc",
   widget = wibox.container.background
}

mycputemp = wibox.widget {
   {
      id     = "text",
      widget = wibox.widget.textbox
   },
   bg     = "#32424bcc",
   widget = wibox.container.background
}

myram = wibox.widget {
   {
      id     = "text",
      widget = wibox.widget.textbox
   },
   bg     = "#2e3c44cc",
   widget = wibox.container.background
}

mybattery = wibox.widget {
   {
      id     = "text",
      widget = wibox.widget.textbox
   },
   bg     = "#29363ecc",
   widget = wibox.container.background
}

myupdates = wibox.widget {
   {
      id     = "text",
      widget = wibox.widget.textbox
   },
   bg     = "#253137cc",
   widget = wibox.container.background
}

mykeyboardlayout = wibox.widget {
   {
      {
         markup = " <span font='MyFont' size='16.5pt' foreground='#d499e5'>䂌</span>",
         widget = wibox.widget.textbox
      },
      {
         widget = awful.widget.keyboardlayout
      },
      layout = wibox.layout.fixed.horizontal,
      widget = wibox.container.margin
   },
   bg     = "#202b31cc",
   widget = wibox.container.background
}

mytextclock = wibox.widget {
   {
      {
         markup = " <span font='MyFont' size='16pt' foreground='#51afef'>䂋</span>",
         widget = wibox.widget.textbox
      },
      {
         format = ' %H:%M ',
         widget = wibox.widget.textclock
      },
      layout = wibox.layout.fixed.horizontal,
      widget = wibox.container.margin
   },
   bg     = "#1c252acc",
   widget = wibox.container.background
}

awful.screen.connect_for_each_screen(function(s)
      local sgeo = s.geometry
      local gap = beautiful.useless_gap

      s.tagbar = wibox({
            x 	  	= sgeo.x + gap * 2,
            y 	  	= sgeo.y + gap * 2,
            screen  = s,
            width   = 245,
            height  = 42,
            visible = true,
            bg      = "#1c252acc",
      })

      s.tagbar:setup {
         {
            layout = wibox.layout.fixed.horizontal,
            expand = "none",

            awful.widget.taglist {
               screen  = s,
               filter  = awful.widget.taglist.filter.all,
               buttons = {
                  awful.button({ }, 1, function(t) t:view_only() end),
                  awful.button({ modkey }, 1, function(t)
                        if client.focus then
                           client.focus:move_to_tag(t)
                        end
                  end),
                  awful.button({ }, 3, awful.tag.viewtoggle),
                  awful.button({ modkey }, 3, function(t)
                        if client.focus then
                           client.focus:toggle_tag(t)
                        end
                  end),
                  awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
                  awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
               }
            }
         },

         widget = wibox.container.margin
      }

      s.tagbar:struts({ top = s.tagbar.height + gap * 2 })

      s.mywibox = awful.popup {
         screen = s,
         placement = function(c)
            return awful.placement.top_right(c, { margins = gap * 2 })
         end,
         minimum_height = 42,
         bg = "#00000000",
         widget = {
            {
               layout = wibox.layout.fixed.horizontal,
               expand = "none",

               mycpu,
               mycputemp,
               myram,
               mybattery,
               myupdates,
               mykeyboardlayout,
               mytextclock,
            },
            widget = wibox.container.margin
         }
      }
end)

cputemp_icons = { "䂓", "䂒", "䂑", "䂐", "䂏" }

gears.timer {
   timeout   = 1.5,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async_with_shell("cpu",
                                        function(out)
                                           mycpu.text.markup = " <span font='Myfont' size='16.5pt' foreground='#ff6c6b'>䂄</span> " ..
                                              out:gsub("%\n", "") .. " "
      end)
      awful.spawn.easy_async_with_shell("cat /sys/class/hwmon/hwmon3/temp1_input",
                                        function(out)
                                           cputemp = math.floor(tonumber(out) / 1000 + 0.5)
                                           if cputemp <= 35 then
                                              icon = cputemp_icons[1]
                                           elseif cputemp <= 44 then
                                              icon = cputemp_icons[2]
                                           elseif cputemp <= 53 then
                                              icon = cputemp_icons[3]
                                           elseif cputemp <= 62 then
                                              icon = cputemp_icons[4]
                                           else
                                              icon = cputemp_icons[5]
                                           end

                                           if cputemp > 70 then
                                              mycputemp.bg = "#ff6c6bcc"
                                           else
                                              mycputemp.bg = "#32424bcc"
                                           end

                                           mycputemp.text.markup = " <span font='Myfont' size='16.5pt' foreground='#ffaf00'>" ..
                                              icon .. "</span> " .. cputemp .. "°C "
      end)
      awful.spawn.easy_async_with_shell("ram",
                                        function(out)
                                           myram.text.markup = " <span font='Myfont' size='18pt' foreground='#98be65'>䂎</span> " ..
                                              out:gsub("%\n", "") .. " "
      end)
   end
}

bat_notification_count_1 = 1
bat_notification_count_2 = 1
bat_icons = { "䂉", "䂈", "䂇", "䂆", "䂅" }
bat_prev_status = ""
bat_prev_index = 0

gears.timer {
   timeout   = 1,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async_with_shell("capacity=$(cat /sys/class/power_supply/BAT1/capacity | tr -d '\n');" ..
                                        "status=$(cat /sys/class/power_supply/BAT1/status | tr -d '\n');" ..
                                        "echo -n \"$capacity $status\"",
                                        function(out)
                                           out = out:gsub("\n", "")
                                           capacity = tonumber(out:match("^(.+)%s"))
                                           status = out:match(" (.+)")

                                           if status ~= bat_prev_status then
                                              if status == "Discharging" then
                                                 bat_notification_count_1 = 0
                                                 bat_notification_count_2 = 0
                                                 bat_prev_index = 0
                                              end
                                              bat_prev_status = status
                                           end

                                           if capacity <= 10 and bat_notification_count_1 == 0 then
                                              awful.spawn.with_shell("notify-send -t 0 -u normal \"Battery is low\" \"10% battery remaining\"")
                                              bat_notification_count_1 = 1
                                           elseif capacity <= 1 and bat_notification_count_2 == 0 then
                                              awful.spawn.with_shell("notify-send -t 0 -u normal \"Battery is low\" \"1% battery remaining\"")
                                              bat_notification_count_2 = 1
                                           end

                                           icon_index = 1 + math.floor((capacity - 15) / 25 + 0.96)
                                           if status == "Charging" then
                                              if bat_prev_index == 0 or bat_prev_index == 5 then
                                                 bat_prev_index = icon_index - 1
                                              end
                                              bat_prev_index = bat_prev_index + 1
                                              icon_index = bat_prev_index
                                           end

                                           mybattery.text.markup = " <span font='MyFont' size='16.5pt' foreground='#46d9ff'>" ..
                                              bat_icons[icon_index] .. "</span> " .. capacity .. "% "
      end)
   end
}

myupdates.text.markup = " <span font='MyFont' size='16.5pt' foreground='#c38a48'>䂍</span> .. "
updates_prev = 0

gears.timer {
   timeout   = 1000,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async_with_shell("updates",
                                        function(out)
                                           if updates_prev == 0 then
                                              awful.spawn.with_shell("notify-send -u normal \"You should update soon\" \"" ..
                                                                     out:gsub("%\n", "") .. " new updates\"")
                                           end
                                           updates_prev = tonumber(out)

                                           myupdates.text.markup = " <span font='MyFont' size='16.5pt' foreground='#c38a48'>䂍</span> " ..
                                              out:gsub("%\n", "") .. " "
      end)
   end
}

-- General Awesome keys
awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "s", hotkeys_popup.show_help,
         {description="show help", group="awesome"}),
      awful.key({ modkey, "Control" }, "r", awesome.restart,
         {description = "reload awesome", group = "awesome"}),
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
      awful.key({ "Mod1" }, "Escape", function ()
            -- If you want to always position the menu on the same place set coordinates
            awful.menu.menu_keys.down = { "Down", "Alt_L" }
            awful.menu.clients({theme = { width = 250 }}, { keygrabber=true, coords={x=525, y=330} })
      end),
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
         {description = "take a screenshot", group = "launcher"}),
      awful.key({        }, "F11", function() awful.util.spawn("screenshot") end,
         {description = "take a screenshot", group = "launcher"}),
      awful.key({ modkey }, "`", function() toggle_terminal() end,
         {description = "toggle splash terminal", group = "launcher"}),
      awful.key({ modkey }, "b", function() toggle_firefox() end,
         {description = "toggle splash firefox", group = "launcher"}),
      awful.key({ modkey }, "m", function() toggle_splash_height() end,
         {description = "resize splash app", group = "launcher"})
})

awful.keyboard.append_global_keybindings({
      awful.key {
         modifiers   = { modkey },
         keygroup    = "numrow",
         description = "only view tag",
         group       = "tag",
         on_press    = function (index)
            if index ~= 8 then
               local screen = awful.screen.focused()
               local tag = screen.tags[index]
               if tag then
                  tag:view_only()
               end
            end
         end,
      },
      awful.key {
         modifiers   = { modkey, "Control" },
         keygroup    = "numrow",
         description = "toggle tag",
         group       = "tag",
         on_press    = function (index)
            if index ~= 8 then
               local screen = awful.screen.focused()
               local tag = screen.tags[index]
               if tag then
                  awful.tag.viewtoggle(tag)
               end
            end
         end,
      },
      awful.key {
         modifiers = { modkey, "Shift" },
         keygroup    = "numrow",
         description = "move focused client to tag",
         group       = "tag",
         on_press    = function (index)
            if index ~= 8 and client.focus then
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
            if index ~= 8 and client.focus then
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
            if index ~= 8 then
               local t = awful.screen.focused().selected_tag
               if t then
                  t.layout = t.layouts[index] or t.layout
               end
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
                               awful.key({ modkey,           }, "q",
                                  function (c)
                                     if c.pid == terminal_id then
                                        toggle_terminal()
                                     elseif c.pid ~= emacs_fm_id then
                                        c:kill()
                                     end
                                  end,
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

awful.spawn.with_shell("lf -server")
awful.spawn.with_shell("picom -b --experimental-backends --config $HOME/.config/picom/picom.conf")
awful.spawn.with_shell("feh -z --bg-fill $HOME/Pictures/wallpapers")
