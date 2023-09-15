local Menu = require('Leader.Menu')
local ScreenManager = require('window-management.ScreenManager')
local layoutChooser = require('window-management.LayoutFilter')
local manager = require('screen-manager')

local function selectLayoutForCurrentSpace()
  layoutChooser(manager, hs.spaces.focusedSpace())
end

local actions = {
  moveToLeft   = { key = "h", window = true, description = "Move focused window to left column" },
  moveToRight  = { key = "l", window = true, description = "Move focused window to right column" },
  moveToMain   = { key = "space", window = true, description = "Move focused window to main column" },
  growMain     = { key = "L", repeatable = true, description = "Grow main column" },
  shrinkMain   = { key = "H", repeatable = true, description = "Shrink main column" },
  reset        = { key = "x", description = "Reset layout dimensions" },
  toggleActive = { key = "a", description = "Toggle layout active/passive mode" },
}

return function()
  local menu = Menu.named("Manage Windows", hs)
    :withAction({}, "w", "Select Layout", selectLayoutForCurrentSpace)

  for action, binding in pairs(actions) do
    menu:withAction(
      {},
      binding.key,
      binding.description,
      manager:bindableAction(action)
    )
  end

  return menu()
end
