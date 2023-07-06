local launch = require('keymaps.utilities').launch

return function(binder)
    return {
        [binder.singleKey("a", "Activity Monitor")] = launch("Activity Monitor"),
        [binder.singleKey("R", "Reload Configuration")] = hs.reload,
        [binder.singleKey("C", "Launch Console")] = launch("Hammerspoon"),
    }
end
