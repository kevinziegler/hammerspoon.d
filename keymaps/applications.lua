local launch = require('keymaps.utilities').launch

return function(binder)
  return {
    [binder.singleKey("e", "Emacs")]    = launch("Emacs"),
    [binder.singleKey("f", "Firefox")]  = launch("Firefox"),
    [binder.singleKey("t", "iTerm")]    = launch("iTerm"),
    [binder.singleKey("c", "Calendar")] = launch("Fantastical"),
    [binder.singleKey("F", "Finder")]   = launch("Finder"),
    [binder.singleKey("m", "Mail")]     = launch("Mimestream"),
    [binder.singleKey("s", "Spotify")]  = launch("Spotify"),
    [binder.singleKey("S", "Slack")]    = launch("Slack"),
  }
end
