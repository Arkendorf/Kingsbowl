function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  font = love.graphics.newImageFont("font.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "abcdefghijklmnopqrstuvwxyz" ..
    "0123456789!?.", 1)
  love.graphics.setFont(font)

  prep = love.graphics.newImage("char/prep.png")
  prepQuad = loadSpriteSheet(prep, 32)

  banner = love.graphics.newImage("gui/banner.png") 

end

function loadSpriteSheet(image, size)
  table = {}
  for h = 0, (image:getHeight() / size) - 1 do
    for w = 0, (image:getWidth() / size) - 1 do
      table[#table + 1] = love.graphics.newQuad(w * size, h * size, size, size, image:getDimensions())
    end
  end
  return table
end
