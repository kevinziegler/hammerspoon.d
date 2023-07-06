return function(binder)
  return {
    [binder.singleKey("space", "Play/Pause")] = hs.spotify.playpause,
    [binder.singleKey("n", "Play Next")] = hs.spotify.next,
    [binder.singleKey("p", "Play Previous")] = hs.spotify.previous,
  }
end
