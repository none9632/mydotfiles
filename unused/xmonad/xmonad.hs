
import XMonad
import XMonad.Util.Run
import XMonad.Util.EZConfig
import System.IO

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops

import XMonad.Util.SpawnOnce

import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

------------------------------------------------------------------------

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
--
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
--
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask  = mod4Mask
modm       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#282c34"
myFocusedBorderColor = "#828895"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys :: [(String, X ())]
myKeys =

    -- [ ("M-<Return>", spawn myTerminal)                                -- launch a terminal
    [ ("M-S-c", kill)                                                 -- close focused window
    -- , ("M-S-c", kill)                                                 -- close focused window
    , ("M-<Space>", sendMessage NextLayout)                           -- Rotate through the available layout algorithms
    -- , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf)             -- Reset the layouts on the current workspace to default
    , ("M-n", refresh)                                                -- Resize viewed windows to the correct size
    , ("M-j", windows W.focusDown)                                    -- Move focus to the next window
    , ("M-k", windows W.focusUp)                                      -- Move focus to the previous window
    , ("M-m", windows W.focusMaster)                                  -- Move focus to the master window
    , ("M-S-j", windows W.swapDown)                                   -- Swap the focused window with the next window
    , ("M-S-k", windows W.swapUp)                                     -- Swap the focused window with the previous window
    --, ("M-<Return>", windows W.SwapMaster)                            -- Swap the focused window and the master window
    , ("M-h", sendMessage Shrink)                                     -- Shrink the master area
    , ("M-l", sendMessage Expand)                                     -- Expand the master area
    , ("M-t", withFocused $ windows . W.sink)                         -- Push window back into tiling
    , ("M-,", sendMessage (IncMasterN 1))                             -- Increment the number of windows in the master area
    , ("M-,", sendMessage (IncMasterN (-1)))                          -- Deincrement the number of windows in the master area

    --, ("M-b", sendMessage ToggleStruts)                               -- Toggle the status bar gap
                                                                      -- Use this binding with avoidStruts from Hooks.ManageDocks.
                                                                      -- See also the statusBar function from Hooks.DynamicLog.

    , ("M-d", spawn "appsmenu.sh")                                    -- launch rofi
    , ("M-<Return>", spawn "apps.sh")                                 -- launch rofi with apps.sh script
    , ("M-p", spawn "powermenu.sh")                                   -- launch rofi with powermenu.sh script
    , ("M-c", spawn "conf_menu")                                      -- launch rofi with configmenu script
    , ("<Print>", spawn "screenshot.sh")                              -- launch rofi with screenshot.sh script
    -- , ("<Print>", spawn "just_screenshot.sh")

    , ("M-S-q", io (exitWith ExitSuccess))                            -- Quit xmonad
    , ("M-q", spawn "xmonad --recompile; xmonad --restart")           -- Restart xmonad

    -- Switch to workspace N
    , ("M-1", windows $ W.greedyView "1")
    , ("M-2", windows $ W.greedyView "2")
    , ("M-3", windows $ W.greedyView "3")
    , ("M-4", windows $ W.greedyView "4")
    , ("M-5", windows $ W.greedyView "5")
    , ("M-6", windows $ W.greedyView "6")
    , ("M-7", windows $ W.greedyView "7")
    , ("M-8", windows $ W.greedyView "8")
    , ("M-9", windows $ W.greedyView "9")

    -- Move client to workspace N
    , ("M-S-1", windows $ W.shift "1")
    , ("M-S-2", windows $ W.shift "2")
    , ("M-S-3", windows $ W.shift "3")
    , ("M-S-4", windows $ W.shift "4")
    , ("M-S-5", windows $ W.shift "5")
    , ("M-S-6", windows $ W.shift "6")
    , ("M-S-7", windows $ W.shift "7")
    , ("M-S-8", windows $ W.shift "8")
    , ("M-S-9", windows $ W.shift "9")
    ]

    -- --
    -- -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    -- --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        -- | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        -- , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    spawnOnce "feh --bg-scale ~/Pictures/wallpapers/0240.jpg"

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = fadeInactiveLogHook fadeAmount
    --where fadeAmount = 1.0

myLogHook = return ()

------------------------------------------------------------------------
--
main = do
    xmproc <- spawnPipe "xmobar -x 0 /home/none9632/.config/xmobar/xmobarrc0"

    xmonad $ ewmh $ docks defaultConfig
        {
        -- simple stuff
          terminal           = myTerminal
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , borderWidth        = myBorderWidth
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses

        -- key bindings
        -- , keys               = myKeys
        , mouseBindings      = myMouseBindings

        -- hooks, layouts
        , layoutHook         = avoidStruts $ layoutHook defaultConfig
        , logHook            = myLogHook <+> dynamicLogWithPP xmobarPP
                               { ppOutput          = hPutStrLn xmproc
                               -- , ppCurrent         = xmobarColor "#98be65" "" . wrap "<fc=#707880>[</fc>" "<fc=#707880>]</fc>"
                               , ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]"
                               , ppVisible         = xmobarColor "#98be65" ""
                               , ppHidden          = xmobarColor "#82aaff" "" . wrap "*" ""
                               , ppHiddenNoWindows = xmobarColor "#c792ea" ""
                               , ppTitle           = xmobarColor "#b3afc2" "" . shorten 50
                               , ppSep             = " <icon=separator.xpm/> "
                               }
        , startupHook          = myStartupHook
        }
        `additionalKeysP` myKeys
