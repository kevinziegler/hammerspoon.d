local util = {
  __debugEnabled = false
}

function util.setDebug(enabled)
  util.__debugEnabled = enabled
  print(
    "Set debug for window management: "
    .. (enabled and "ENABLED" or "DISABLED")
  )
end

function util.toggleDebug()
  util.setDebug(not util.__debugEnabled)
end

function util.debug(...)
  if util.__debugEnabled then
    print(...)
  end
end

function util.frameToCoords(frame)
  return {
    x1 = frame.x,
    x2 = frame.x + frame.w,
    y1 = frame.y,
    y2 = frame.y + frame.h,
  }
end

function util.frameOverlap(frame1, frame2)
  local coords1 = util.frameToCoords(frame1)
  local coords2 = util.frameToCoords(frame2)
  local overlap = { x = 0, y = 0 }
  -- print("Overlap F1, F2", hs.inspect(coords1), hs.inspect(coords2))

  if coords2.x1 > coords1.x2 or coords2.x2 < coords1.x1 then
    return 0
  else
    overlap.x = math.min(coords1.x2, coords2.x2) - math.max(coords1.x1, coords2.x1)
  end

  if coords2.y1 > coords1.y2 or coords2.y2 < coords1.y1 then
    return 0
  else
    overlap.y = math.min(coords1.y2, coords2.y2) - math.max(coords1.y1, coords2.y1)
  end

  return overlap.x * overlap.y
end

return util
