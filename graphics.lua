function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  font = love.graphics.newImageFont("font.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "abcdefghijklmnopqrstuvwxyz" ..
    "0123456789!?.", 1)
  love.graphics.setFont(font)

  prep = love.graphics.newImage("char/prep.png")
  prepQuad = loadSpriteSheet(prep, 32)

  sliderImg = love.graphics.newImage("gui/slider.png")
  bar = love.graphics.newQuad(0, 2, 50, 2, sliderImg:getDimensions())
  knob = love.graphics.newQuad(50, 0, 2, 6, sliderImg:getDimensions())

  bannerImg = love.graphics.newImage("gui/banner.png")
  bannerColor = love.graphics.newQuad(0, 0, 100, 64, bannerImg:getDimensions())
  banner = love.graphics.newQuad(0, 64, 100, 64, bannerImg:getDimensions())

  buttonImg = love.graphics.newImage("gui/button.png")
  buttonSide = love.graphics.newQuad(0, 0, 3, 16, buttonImg:getDimensions())
  buttonMiddle = love.graphics.newQuad(3, 0, 26, 16, buttonImg:getDimensions())
  buttonColorSide = love.graphics.newQuad(0, 16, 3, 16, buttonImg:getDimensions())
  buttonColorMiddle = love.graphics.newQuad(3, 16, 26, 16, buttonImg:getDimensions())

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
