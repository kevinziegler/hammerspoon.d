local windowManagerFilter = hs.window.filter.new()
  :rejectApp("Alfred")
  :rejectApp("System Settings")
  :setCurrentSpace(true)

return ScreenManager(hs.screen.primaryScreen(), windowManagerFilter, hs.spaces)
