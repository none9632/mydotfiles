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
           placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    }

    ruled.client.append_rule {
       rule_any = {
          name  = { "emacsclient" },
          class = {
             "Eog",
             "Inkscape"
          }
       },
       properties = {
          floating  = true,
          placement = function(c)
             return awful.placement.maximize(c, { margins = beautiful.useless_gap * 2, honor_workarea = true })
          end,
       }
    }

    ruled.client.append_rule {
       rule       = { class = "Evince" },
       properties = {
          -- This property allows to hide the resizing
          hidden   = true,
          floating = true,
       },
       callback = function(c)
          c:emit_signal('request::geometry')
       end
    }

    ruled.client.append_rule {
       rule       = { class = "Font-viewer" },
       properties = {
          floating  = true,
          width     = 1000,
          height    = 600,
          placement = function(c)
             return awful.placement.centered(c, { margins = { top = 56 }})
          end,
       }
    }

    ruled.client.append_rule {
       rule_any = {
          instance = {
             "Places",
             "librewolf"
          }
       },
       properties = {
          floating  = true,
          width     = 1350,
          height    = 800,
          placement = function(c)
             return awful.placement.centered(c, { margins = { top = 56 }})
          end,
       },
    }

    ruled.client.append_rule {
       rule       = { class = "Gimp-2.10", floating = true },
       properties = {
          ontop     = true,
          placement = function(c)
             return awful.placement.centered(c, { margins = { top = 56 }})
          end,
       },
    }

    ruled.client.append_rule {
       rule_any = {
          class = {
             "Rofi",
             "Gpick",
             "Gcr-prompter",
             "Nextcloud",
             "Electron",
          }
       },
       properties = {
          floating  = true,
          ontop     = true,
          placement = function(c)
             return awful.placement.centered(c, { margins = { top = 56 }})
          end,
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

client.connect_signal('request::geometry', function(c)
                         if c.class == "Evince" then
                            awful.placement.maximize(c, { margins = beautiful.useless_gap * 2, honor_workarea = true })
                            c.hidden = false
                            raise_client(c)
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.class == "Gpick" then
                            awful.spawn.with_shell("picom -b --experimental-backends --config $HOME/.config/picom/picom.conf")
                         end
end)

local splash_width = 1900
local splash_height = 1150

function create_blurbg(pid_file)
   local s = awful.screen.focused()
   return awful.spawn("rofi " ..
                      "-pid /run/user/1000/" .. pid_file .. " " ..
                      "-replace " ..
                      "-normal-window " ..
                      "-theme /home/none9632/.config/rofi/themes/other/blurbg.rasi " ..
                      "-p \"\" " ..
                      "-dmenu", {
                         focus  = false,
                         above  = true,
                         width  = s.geometry.width,
                         height = s.geometry.height,
   })
end

function raise_client(rclient)
   local t = awful.screen.focused().selected_tag
   rclient:move_to_tag(t)
   rclient:raise()
   client.focus = rclient
end

function toggle_splash_height()
   c = client.focus

   if c.pid == terminal_pid or c.class == "firefox" then
      if c.width <= splash_width then
         awful.placement.maximize(c, { margins = beautiful.useless_gap * 2, honor_workarea = true })
      else
         c.width = splash_width
         c.height = splash_height
         awful.placement.centered(c, { margins = { top = 56 }})
      end
   end
end

local terminal_pid = 'notnil'
local terminal_client
local terminal_blurbg_pid = 'notnil'
local terminal_blurbg_client

function create_terminal()
   for _, c in ipairs(client.get()) do
      if c.instance == "Alacritty-splash" then
         terminal_pid = c.pid
         terminal_client = c
         c.ontop = true
         awful.placement.centered(c, { margins = { top = 56 }})
         raise_client(terminal_client)
      end
   end

   if not terminal_blurbg_client then
      terminal_blurbg_pid = create_blurbg("rofi-terminal.pid")
   end

   if not terminal_client then
      terminal_pid = awful.spawn("alacritty --class Alacritty-splash")
   end
end

function toggle_terminal()
   local s = awful.screen.focused()
   local c = client.focus
   awful.spawn.with_shell("xkb-switch -s us")

   if not terminal_client then
      create_terminal()
   elseif c ~= terminal_client then
      if not terminal_blurbg_client then
         terminal_blurbg_pid = create_blurbg("rofi-terminal.pid")
      else
         terminal_blurbg_client:move_to_tag(s.selected_tag)
         terminal_blurbg_client:raise()
      end
      raise_client(terminal_client)
   else
      terminal_client:move_to_tag(s.tags[8])
      if terminal_blurbg_client then
         terminal_blurbg_client:move_to_tag(s.tags[8])
      end
   end
end

client.connect_signal('manage', function(c)
                         if c.pid == terminal_pid then
                            terminal_client = c
                            c.floating = true
                            c.ontop = true
                            c.width = splash_width
                            c.height = splash_height
                            client.focus = c
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
                         if c.pid == terminal_blurbg_pid then
                            terminal_blurbg_client = c
                            c:lower()
                            awful.placement.centered(c)
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.pid == terminal_pid then
                            terminal_client = nil
                            terminal_pid = 'notnil'
                            if terminal_blurbg_client then
                               terminal_blurbg_client:kill()
                            end
                         end
                         if c.pid == terminal_blurbg_pid then
                            terminal_blurbg_client = nil
                            terminal_blurbg_pid = 'notnil'
                         end
end)

local deepl_window_name = "DeepL Translate: The world's most accurate translator — Mozilla Firefox"
local deepl_pid = 'notnil'
local deepl_client
local deepl_blurbg_pid = 'notnil'
local deepl_blurbg_client

function create_firefox()
   for _, c in ipairs(client.get()) do
      if c.name == deepl_window_name then
         deepl_pid = c.pid
         deepl_client = c
         c.ontop = true
         awful.placement.centered(c, { margins = { top = 56 }})
         raise_client(deepl_client)
      end
   end

   if not deepl_blurbg_client then
      deepl_blurbg_pid = create_blurbg("rofi-firefox.pid")
   end

   if not deepl_client then
      deepl_pid = awful.spawn("firefox -P deepl --no-remote")
   end
end

function toggle_deepl()
   local s = awful.screen.focused()
   local c = client.focus

   if not deepl_client then
      create_firefox()
   elseif c ~= deepl_client then
      if not deepl_blurbg_client then
         deepl_blurbg_pid = create_blurbg("rofi-firefox.pid")
      else
         deepl_blurbg_client:move_to_tag(s.selected_tag)
         deepl_blurbg_client:raise()
      end
      raise_client(deepl_client)
   else
      deepl_client:move_to_tag(s.tags[8])
      if deepl_blurbg_client then
         deepl_blurbg_client:move_to_tag(s.tags[8])
      end
   end
end

client.connect_signal('manage', function(c)
                         if c.pid == deepl_pid then
                            deepl_client = c
                            c.floating = true
                            c.ontop = true
                            c.width = splash_width
                            c.height = splash_height
                            client.focus = c
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
                         if c.pid == deepl_blurbg_pid then
                            deepl_blurbg_client = c
                            c:lower()
                            awful.placement.centered(c)
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.name == deepl_window_name then
                            deepl_client = nil
                            deepl_pid = 'notnil'
                            if deepl_blurbg_client then
                               deepl_blurbg_client:kill()
                            end
                         end
                         if c.pid == deepl_blurbg_pid then
                            deepl_blurbg_client = nil
                            deepl_blurbg_pid = 'notnil'
                         end
end)

local emacs_fm_pid = 'notnil'

function create_emacs_fm(path)
   emacs_fm_pid = awful.spawn.with_shell("alacritty -e lfrun " ..
                                         "-command \"cd " .. path .. "\" " ..
                                         "-command \"map <esc> quit_for_emacs\" " ..
                                         "-command \"map q quit_for_emacs\" " ..
                                         "-command \"map l open_for_emacs\" " ..
                                         "-command \"map <enter> select_for_emacs\"")
end

client.connect_signal('manage', function(c)
                         if c.pid == emacs_fm_pid then
                            c.ontop = true
                            c.floating = true
                            c.width = splash_width
                            c.height = splash_height
                            awful.placement.centered(c, { margins = { top = 56 }})
                         end
end)

client.connect_signal('unmanage', function(c)
                         if c.pid == emacs_fm_pid then
                            emacs_fm_pid = 'notnil'
                         end
end)

local lf_terminal_pid = 'notnil'
local lf_terminal_width = 0
local lf_terminal_height = 0
local lf_terminal_centered = true
local lf_pid = nil

function create_lf_terminal(command, width, height, centered, term_pid)
   lf_terminal_width = width
   lf_terminal_height = height
   lf_terminal_centered = centered
   lf_pid = term_pid
   lf_terminal_pid = awful.spawn.with_shell("alacritty -e sh -c 'tput civis;" .. command .. "'")
end

client.connect_signal('manage', function(c)
                         if c.pid == lf_terminal_pid then
                            c.ontop = true
                            c.floating = true
                            c.width = lf_terminal_width
                            c.height = lf_terminal_height
                            if lf_terminal_centered == true then
                               awful.placement.centered(c, { margins = { top = 56 }})
                            else
                               local lf_client = get_client(lf_pid)
                               c.x = lf_client.x + lf_client.width/2 - c.width/2
                               c.y = lf_client.y + lf_client.height/2 - c.height/2
                            end
                            client.focus = c
                         end
end)

local theme_assets = require("beautiful.theme_assets")

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "Iosevka Nerd Font 15"

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
theme.taglist_bg_urgent = "#ff6c6b"
theme.taglist_fg_urgent = "#1c252a"
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
         markup = " <span font='MyFont' size='17.5pt' foreground='#d499e5'>䂌</span>",
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
         markup = " <span font='MyFont' size='17pt' foreground='#51afef'>䂋</span>",
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
            width   = 266,
            height  = 47,
            ontop   = true,
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
         minimum_height = 47,
         bg = "#00000000",
         ontop = true,
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
                                           mycpu.text.markup = " <span font='Myfont' size='17.5pt' foreground='#ff6c6b'>䂄</span> " ..
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

                                           mycputemp.text.markup = " <span font='Myfont' size='17.5pt' foreground='#ffaf00'>" ..
                                              icon .. "</span> " .. cputemp .. "°C "
      end)
      awful.spawn.easy_async_with_shell("ram",
                                        function(out)
                                           myram.text.markup = " <span font='Myfont' size='19pt' foreground='#98be65'>䂎</span> " ..
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
      awful.spawn.easy_async_with_shell("capacity=$(cat /sys/class/power_supply/BAT*/capacity | tr -d '\n');" ..
                                        "status=$(cat /sys/class/power_supply/BAT*/status | tr -d '\n');" ..
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
                                              awful.spawn.with_shell("notify-send -i ~/.local/share/icons/battery/low-battery.png -u normal \"Battery is low\" \""
                                                                     .. capacity .. "% battery remaining\"")
                                              bat_notification_count_1 = 1
                                           elseif capacity <= 1 and bat_notification_count_2 == 0 then
                                              awful.spawn.with_shell("notify-send -i ~/.local/share/icons/battery/empty-battery.png -t 0 -u normal \"Battery is low\" \"1% battery remaining\"")
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

                                           mybattery.text.markup = " <span font='MyFont' size='17.5pt' foreground='#46d9ff'>" ..
                                              bat_icons[icon_index] .. "</span> " .. capacity .. "% "
      end)
   end
}

myupdates.text.markup = " <span font='MyFont' size='17.5pt' foreground='#c38a48'>䂍</span> .. "
updates_prev = 0

gears.timer {
   timeout   = 1000,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async_with_shell("updates",
                                        function(out)
                                           if updates_prev == 0 and tonumber(out) ~= 0 then
                                              awful.spawn.with_shell("notify-send -u normal \"You should update soon\" \"" ..
                                                                     out:gsub("%\n", "") .. " new updates\"")
                                           end
                                           updates_prev = tonumber(out)

                                           myupdates.text.markup = " <span font='MyFont' size='17.5pt' foreground='#c38a48'>䂍</span> " ..
                                              out:gsub("%\n", "") .. " "
      end)
   end
}

client.connect_signal("property::fullscreen", function(c)
                         local s = awful.screen.focused()
                         if c.width == s.geometry.width and c.class ~= "Rofi" then
                            s.mywibox.ontop = false
                            s.tagbar.ontop = false
                         elseif c.class ~= "Rofi" then
                            s.mywibox.ontop = true
                            s.tagbar.ontop = true
                         end
end)

function get_client(pid)
   for _, c in ipairs(client.get()) do
      if c.pid == pid then
         return c
      end
   end
end

client.connect_signal('property::width', function(c)
                         if c.class == "Alacritty" and c.floating == false then
                            awful.spawn.with_shell("lf -remote \"send recol\"")
                            if lf_terminal_centered == false then
                               for _, c in ipairs(client.get()) do
                                  if c.pid == lf_terminal_pid then
                                     local lf_client = get_client(lf_pid)
                                     c.x = lf_client.x + lf_client.width/2 - c.width/2
                                     c.y = lf_client.y + lf_client.height/2 - c.height/2
                                     break
                                  end
                               end
                            end
                         end
end)

-- General Awesome keys
awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "s", hotkeys_popup.show_help,
         {description = "show help", group = "awesome"}),
      awful.key({ modkey, "Control" }, "r",
         function ()
            if translator_client then
               translator_client:kill()
            end
            awesome.restart()
         end,
         {description = "reload awesome", group = "awesome"}),
})

awful.keyboard.append_global_keybindings({
      awful.key({ modkey,           }, "l", function ()
            local s = awful.screen.focused()
            local t = s.selected_tag
            if t.index == 7 then
               s.tags[1]:view_only()
            else
               awful.tag.viewnext()
            end
      end,
         {description = "view next tag", group = "tag"}),
      awful.key({ modkey,           }, "h", function ()
            local s = awful.screen.focused()
            local t = s.selected_tag
            if t.index == 1 then
               s.tags[7]:view_only()
            else
               awful.tag.viewprev()
            end
      end,
         {description = "view previous tag", group = "tag"}),
      awful.key({ modkey,           }, "n", awful.tag.history.restore,
         {description = "go back", group = "tag"}),
      awful.key {
         modifiers   = { modkey },
         keygroup    = "numrow",
         description = "only view tag",
         group       = "tag",
         on_press    = function (index)
            if index ~= 8 then
               local screen = awful.screen.focused()
               local tag = screen.tags[index]
               local has_fullscreen = false

               if tag then
                  for _, c in ipairs(tag:clients()) do
                     if c.width == screen.geometry.width and c.class ~= "Rofi" then
                        has_fullscreen = true
                        break
                     end
                  end
                  if has_fullscreen then
                     screen.mywibox.ontop = false
                     screen.tagbar.ontop = false
                  else
                     screen.mywibox.ontop = true
                     screen.tagbar.ontop = true
                  end
                  tag:view_only()
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
})

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
      -- awful.key({ modkey, "Control" }, "n",
      --    function ()
      --       local c = awful.client.restore()
      --       -- Focus restored client
      --       if c then
      --          c:activate { raise = true, context = "key.unminimize" }
      --       end
      --    end,
      --    {description = "restore minimized", group = "client"}),
})

awful.keyboard.append_global_keybindings({
      awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
         {description = "swap with next client by index", group = "client"}),
      awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
         {description = "swap with previous client by index", group = "client"}),
      awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
         {description = "jump to urgent client", group = "client"}),
      awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
         {description = "increase master width factor", group = "layout"}),
      awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
         {description = "decrease master width factor", group = "layout"}),
      -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
      --    {description = "increase the number of master clients", group = "layout"}),
      -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
      -- {description = "decrease the number of master clients", group = "layout"}),
      awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
         {description = "increase the number of columns", group = "layout"}),
      awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
         {description = "decrease the number of columns", group = "layout"}),
      awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
         {description = "select next", group = "layout"}),
      awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
         {description = "select previous", group = "layout"}),
})

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
      awful.key({ modkey }, "w", function() awful.spawn.with_shell("update-wall") end,
         {description = "wallpaper change", group = "launcher"}),
      awful.key({        }, "Print", function() awful.util.spawn("screenshot") end,
         {description = "take a screenshot", group = "launcher"}),
      awful.key({        }, "F11", function() awful.util.spawn("screenshot") end,
         {description = "take a screenshot", group = "launcher"}),
      awful.key({ modkey }, "`", function() toggle_terminal() end,
         {description = "toggle splash terminal", group = "launcher"}),
      awful.key({ modkey }, "b", function() toggle_deepl() end,
         {description = "toggle splash firefox with deepl website", group = "launcher"}),
      awful.key({ modkey }, "m", function() toggle_splash_height() end,
         {description = "resize splash app", group = "launcher"})
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
                                     if c.pid == terminal_pid then
                                        toggle_terminal()
                                     elseif c.pid ~= emacs_fm_pid
                                        and c.pid ~= terminal_blurbg_pid
                                        and c.pid ~= firefox_blurbg_pid then
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
                               -- awful.key({ modkey,           }, "n",
                               --    function (c)
                               --       -- The client currently has the input focus, so it cannot be
                               --       -- minimized, since minimized clients can't have the focus.
                               --       c.minimized = true
                               --    end,
                               --    {description = "minimize", group = "client"}),
                         })
end)

awful.spawn.with_shell("nextcloud --background")
awful.spawn.with_shell("lf -server")
awful.spawn.with_shell("compfy")
awful.spawn.with_shell("update-wall")
awful.spawn.with_shell("emacs --daemon --name emacsclient")
