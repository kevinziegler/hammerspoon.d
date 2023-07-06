local emoji = {
  confused = "ↁ_ↁ",
  derp = "¯\\(◉◡◔)/¯",
  disapproval = "ಠ_ಠ" ,
  disapproving_shrug = "¯\\_ಠ_ಠ_/¯",
  disbelief = "☉_☉",
  doubtful_look = "ಠಿ_ಠ",
  lenny = "( ͡° ͜ʖ ͡°)",
  not_sure_if = "(≖_≖ )",
  serious_look = "(ಠ_ಠ)",
  shrug = "¯\\_(ツ)_/¯",
  suspicious = "(;¬_¬)",
  table_flip = "(╯°□°)╯︵ ┻━┻",
  table_flip_alarmed = "(┛◉Д◉)┛彡┻━┻",
  table_flip_angry = "(ノಠ益ಠ)ノ彡┻━┻",
  table_flip_jake = "(┛❍ᴥ❍﻿)┛彡┻━┻",
  table_flip_look = "(┛ಠ_ಠ)┛彡┻━┻",
  table_flip_pointing = "(☞ﾟヮﾟ)☞ ┻━┻",
  table_down = "┬─┬ノ( º _ ºノ)",
  tears_of_joy = "(ಥ⌣ಥ)",
  unsure = "⊜_⊜",
  you_gotta_be_kidding = "●_●",
  zoidberg = "(V) (°,,,,°) (V)",
  zoidberg_of_disapproval = "(V) (ಠ,,,ಠ) (V)",
  whatever = "◔_◔"
}

local function insertText (text)
  return function ()
    hs.eventtap.keyStrokes(text)
  end
end

return function(binder)
  local singleKey = binder.singleKey
  return {
    [singleKey("s", emoji.shrug)] = insertText(emoji.shrug),
    [singleKey("t", "Tables")] = {
      [singleKey("a", emoji.table_flip_alarmed)] = insertText(emoji.table_flip_alarmed),
      [singleKey("A", emoji.table_flip_angry)] = insertText(emoji.table_flip_angry),
      [singleKey("d", emoji.table_down)] = insertText(emoji.table_down),
      [singleKey("f", emoji.table_flip)] = insertText(emoji.table_flip),
      [singleKey("l", emoji.table_flip_look)] = insertText(emoji.table_flip_look),
      [singleKey("p", emoji.table_flip_pointing)] = insertText(emoji.table_flip_pointing),
    },
    [singleKey("z", emoji.zoidberg_of_disapproval)] = insertText(emoji.zoidberg_of_disapproval),
  }
end
