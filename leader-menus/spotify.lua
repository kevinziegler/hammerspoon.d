local Menu = require('Leader.Menu')

return Menu.named("Spotify Controls", hs)
    :withAction({}, "space", "Play/Pause", hs.spotify.playpause)
    :withAction({}, "n", "Play Next", hs.spotify.next)
    :withAction({}, "p", "Play Previous", hs.spotify.previous)
