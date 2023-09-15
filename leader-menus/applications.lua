local Menu = require('Leader.Menu')

local function launch(bundleId)
  return function()
    hs.application.launchOrFocusByBundleID(bundleId)
  end
end

return Menu.named("Applications", hs)
    :withAction({}, "e", "Emacs", launch("org.gnu.Emacs"))
    :withAction({}, "f", "Firefox", launch("org.mozilla.firefox"))
    :withAction({}, "t", "iTerm", launch("com.googlecode.iterm2"))
    :withAction({}, "c", "Calendar", launch("com.flexibits.fantastical2.mac"))
    :withAction({}, "F", "Finder", launch("com.apple.finder"))
    :withAction({}, "m", "Mail", launch("com.mimestream.Mimestream"))
    :withAction({}, "s", "Spotify", launch("com.spotify.client"))
    :withAction({}, "S", "Slack", launch("Slack"))
