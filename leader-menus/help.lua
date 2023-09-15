local Menu = require('Leader.Menu')

local function launch(bundleId)
  return function()
    hs.application.launchOrFocusByBundleID(bundleId)
  end
end

return Menu.named("Help", hs)
  :withAction({}, "a", "Activity Monitor", launch("com.apple.ActivityMonitor"))
  :withAction({}, "R", "Reload Configuration", hs.reload)
  :withAction({}, "C", "Launch Console", launch("org.hammerspoon.Hammerspoon"))
