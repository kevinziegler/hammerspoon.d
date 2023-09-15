local Menu = require('Leader.Menu')
local Binding = require('Leader.Binding')

local applicationsMenu = require('leader-menus.applications')
local helpMenu = require('leader-menus.help')
local spotifyMenu = require('leader-menus.spotify')
local textHelpersMenu = require('leader-menus.text-helpers')
local spacesMenu = require('leader-menus.spaces')
local layoutsMenu = require('leader-menus.layouts')

local alfredBundleId = "com.runningwithcrayons.Alfred"

local function launchAlfred()
  hs.application.launchOrFocusByBundleID(alfredBundleId)
end


return Menu.named(nil, hs)
  :withAction({}, 'space', "Alfred", launchAlfred)
  :withAction({}, 'tab', "Desktops/Spaces", spacesMenu)
  :withAction({}, 'a', "Applications", applicationsMenu)
  :withAction({}, 'h', "Help", helpMenu)
  :withAction({}, 's', "Spotify Contols", spotifyMenu)
  :withAction({}, 'i', "Insert Text", textHelpersMenu)
  :withAction({}, 'w', "Window Management", layoutsMenu)
