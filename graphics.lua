function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  font = love.graphics.newImageFont("font.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "abcdefghijklmnopqrstuvwxyz" ..
    "0123456789!?.:", 1)
  love.graphics.setFont(font)

  prep = love.graphics.newImage("char/prep.png")
  prepQuad = loadSpriteSheet(prep, 32)

  dissapear = love.graphics.newImage("char/dissapear.png")
  dissapearQuad = loadSpriteSheet(dissapear, 32)

  switch = love.graphics.newImage("char/switch.png")
  switchQuad = loadSpriteSheet(switch, 32)

  sliderImg = love.graphics.newImage("gui/slider.png")
  bar = love.graphics.newQuad(0, 2, 50, 2, sliderImg:getDimensions())
  knob = love.graphics.newQuad(50, 0, 2, 6, sliderImg:getDimensions())

  bannerImg = love.graphics.newImage("gui/banner.png")
  bannerColor = love.graphics.newQuad(0, 0, 100, 64, bannerImg:getDimensions())
  banner = love.graphics.newQuad(0, 64, 100, 64, bannerImg:getDimensions())

  buttonImg = love.graphics.newImage("gui/button.png")
  buttonSide1 = love.graphics.newQuad(0, 0, 15, 16, buttonImg:getDimensions())
  buttonMiddle = love.graphics.newQuad(15, 0, 2, 16, buttonImg:getDimensions())
  buttonSide2 = love.graphics.newQuad(17, 0, 15, 16, buttonImg:getDimensions())
  buttonColorSide1 = love.graphics.newQuad(0, 16, 15, 16, buttonImg:getDimensions())
  buttonColorMiddle = love.graphics.newQuad(15, 16, 2, 16, buttonImg:getDimensions())
  buttonColorSide2 = love.graphics.newQuad(17, 16, 15, 16, buttonImg:getDimensions())

  textboxImg = love.graphics.newImage("gui/textbox.png")
  textboxSide1 = love.graphics.newQuad(0, 0, 10, 16, textboxImg:getDimensions())
  textboxSide2 = love.graphics.newQuad(10, 0, 10, 16, textboxImg:getDimensions())

  playerButtonImg = love.graphics.newImage("gui/playerbutton.png")
  playerButton = {}
  playerButtonOverlay = {}
  bannerButton = {}
  for i = 0, 21 do
    playerButton[#playerButton + 1] = love.graphics.newQuad(0, i * 32, 82, 16, playerButtonImg:getDimensions())
    playerButtonOverlay[#playerButtonOverlay + 1] = love.graphics.newQuad(82, i * 32, 82, 16, playerButtonImg:getDimensions())
    bannerButton[#bannerButton + 1] = love.graphics.newQuad(0, i * 32 + 16, 16, 16, playerButtonImg:getDimensions())
  end
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
