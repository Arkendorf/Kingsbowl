function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  prep = love.graphics.newImage("char/prep.png")
  prepQuad = loadSpriteSheet(prep, 32)
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
