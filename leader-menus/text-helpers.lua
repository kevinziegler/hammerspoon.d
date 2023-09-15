local Menu = require('Leader.Menu')
local Binding = require('Leader.Binding')

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

local tableMenu = Menu.named("Table Flips", hs)
  :withAction({}, "a", emoji.table_flip_alarmed, insertText(emoji.table_flip_alarmed))
  :withAction({}, "A", emoji.table_flip_angry, insertText(emoji.table_flip_angry))
  :withAction({}, "d", emoji.table_down, insertText(emoji.table_down))
  :withAction({}, "f", emoji.table_flip, insertText(emoji.table_flip))
  :withAction({}, "l", emoji.table_flip_look, insertText(emoji.table_flip_look))
  :withAction({}, "p", emoji.table_flip_pointing, insertText(emoji.table_flip_pointing))

return Menu.named("Insert Unicode", hs)
  :withAction({}, "s", emoji.shrug, insertText(emoji.shrug))
  :withAction({}, "t", "Table Flips", tableMenu)
  :withAction({}, "z", emoji.zoidberg_of_disapproval, insertText(emoji.zoidberg_of_disapproval))
