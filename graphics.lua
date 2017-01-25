function graphics_load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  font = love.graphics.newImageFont("font.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "abcdefghijklmnopqrstuvwxyz" ..
    "0123456789!?.:", 1)
  love.graphics.setFont(font)

  window = love.graphics.newImage("gui/window.png")

  charShadow = love.graphics.newImage("char/charShadow.png")

  arrowTarget = love.graphics.newImage("art/target.png")

  arrowImg = love.graphics.newImage("art/arrow.png")
  arrowWobble = love.graphics.newImage("art/arrowWobble.png")
  arrowWobbleQuad =loadSpriteSheet(arrowWobble, 32)

  bloodDrop = love.graphics.newImage("art/bloodDrop.png")
  bloodDropQuad = loadSpriteSheet(bloodDrop, 32)

  pDropImg = love.graphics.newImage("art/drops.png")
  pDropQuad = loadSpriteSheet(pDropImg, 32)

  prep = love.graphics.newImage("char/prep.png")
  prepQuad = loadSpriteSheet(prep, 32)
  prepOverlay = love.graphics.newImage("char/prepOverlay.png")
  prepOverlayQuad = loadSpriteSheet(prepOverlay, 32)

  dissapear = love.graphics.newImage("char/dissapear.png")
  dissapearQuad = loadSpriteSheet(dissapear, 32)
  dissapearOverlay = love.graphics.newImage("char/dissapearOverlay.png")
  dissapearOverlayQuad = loadSpriteSheet(dissapearOverlay, 32)

  switch = love.graphics.newImage("char/switch.png")
  switchQuad = loadSpriteSheet(switch, 32)
  switchOverlay = love.graphics.newImage("char/switchOverlay.png")
  switchOverlayQuad = loadSpriteSheet(switchOverlay, 32)

  unsheathSword = love.graphics.newImage("char/unsheathSword.png")
  unsheathSwordQuad = loadSpriteSheet(unsheathSword, 32)
  unsheathSwordOverlay = love.graphics.newImage("char/unsheathSwordOverlay.png")
  unsheathSwordOverlayQuad = loadSpriteSheet(unsheathSwordOverlay, 32)

  grabShield = love.graphics.newImage("char/grabShield.png")
  grabShieldQuad = loadSpriteSheet(grabShield, 32)
  grabShieldOverlay = love.graphics.newImage("char/grabShieldOverlay.png")
  grabShieldOverlayQuad = loadSpriteSheet(grabShieldOverlay, 32)

  bowRun = love.graphics.newImage("char/bowRun.png")
  bowRunQuad = loadSpriteSheet(bowRun, 32)
  bowRunOverlay = love.graphics.newImage("char/bowRunOverlay.png")
  bowRunOverlayQuad = loadSpriteSheet(bowRunOverlay, 32)

  bowStill = love.graphics.newImage("char/bowStill.png")
  bowStillQuad = {love.graphics.newQuad(0, 0, 32, 32, bowStill:getDimensions())}
  bowStillOverlay = love.graphics.newImage("char/bowStillOverlay.png")
  bowStillOverlayQuad = {love.graphics.newQuad(0, 0, 32, 32, bowStillOverlay:getDimensions())}

  dead = love.graphics.newImage("char/dead.png")
  deadQuad = loadSpriteSheet(dead, 32)
  deadOverlay = love.graphics.newImage("char/deadOverlay.png")
  deadOverlayQuad = loadSpriteSheet(deadOverlay, 32)

  shieldUp = love.graphics.newImage("char/shieldUp.png")
  shieldUpQuad = loadSpriteSheet(shieldUp, 32)
  shieldUpOverlay = love.graphics.newImage("char/shieldUpOverlay.png")
  shieldUpOverlayQuad = loadSpriteSheet(shieldUpOverlay, 32)

  shieldUpRun = love.graphics.newImage("char/shieldUpRun.png")
  shieldUpRunQuad = loadSpriteSheet(shieldUpRun, 32)
  shieldUpRunOverlay = love.graphics.newImage("char/shieldUpRunOverlay.png")
  shieldUpRunOverlayQuad = loadSpriteSheet(shieldUpRunOverlay, 32)

  swordAttack = love.graphics.newImage("char/swordAttack.png")
  swordAttackQuad = loadSpriteSheet(swordAttack, 32, 64)
  swordAttackOverlay = love.graphics.newImage("char/swordAttackOverlay.png")
  swordAttackOverlayQuad = loadSpriteSheet(swordAttackOverlay, 32, 64)

  run = love.graphics.newImage("char/runArms.png")
  runQuad = loadSpriteSheet(run, 32)

  runSword = love.graphics.newImage("char/runSword.png")
  runSwordQuad = loadSpriteSheet(runSword, 32)
  runSwordOverlay = love.graphics.newImage("char/runSwordOverlay.png")
  runSwordOverlayQuad = loadSpriteSheet(runSwordOverlay, 32)

  runShield = love.graphics.newImage("char/runShield.png")
  runShieldQuad = loadSpriteSheet(runShield, 32)
  runShieldOverlay = love.graphics.newImage("char/runShieldOverlay.png")
  runShieldOverlayQuad = loadSpriteSheet(runShieldOverlay, 32)

  limp = love.graphics.newImage("char/limp v.2.png")
  limpQuad = loadSpriteSheet(limp, 32)
  limpOverlay = love.graphics.newImage("char/limpOverlay.png")
  limpOverlayQuad = loadSpriteSheet(limpOverlay, 32)

  coinImg = love.graphics.newImage("menu/coin.png")
  coinQuad = loadSpriteSheet(coinImg, 32)

  coinShadeImg = love.graphics.newImage("menu/shadow.png")
  coinShadeQuad = loadSpriteSheet(coinShadeImg, 32)

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

  valueImg = love.graphics.newImage("gui/values.png")
  arrowLeft = love.graphics.newQuad(0, 0, 8, 16, valueImg:getDimensions())
  arrowRight = love.graphics.newQuad(8, 0, 8, 16, valueImg:getDimensions())

  dropDownImg = love.graphics.newImage("gui/dropdown.png")
  dropDownSide1 = love.graphics.newQuad(0, 0, 15, 16, dropDownImg:getDimensions())
  dropDownMiddle1 = love.graphics.newQuad(15, 0, 2, 16, dropDownImg:getDimensions())
  dropDownSide2 = love.graphics.newQuad(17, 0, 15, 16, dropDownImg:getDimensions())
  dropDownSide3 = love.graphics.newQuad(0, 16, 15, 16, dropDownImg:getDimensions())
  dropDownMiddle2 = love.graphics.newQuad(15, 16, 2, 16, dropDownImg:getDimensions())
  dropDownSide4 = love.graphics.newQuad(17, 16, 15, 16, dropDownImg:getDimensions())
  dropDownSide5 = love.graphics.newQuad(0, 32, 15, 16, dropDownImg:getDimensions())
  dropDownMiddle3 = love.graphics.newQuad(15, 32, 2, 16, dropDownImg:getDimensions())
  dropDownSide6 = love.graphics.newQuad(17, 32, 15, 16, dropDownImg:getDimensions())
  dropDownSide7 = love.graphics.newQuad(0, 48, 15, 16, dropDownImg:getDimensions())
  dropDownMiddle4 = love.graphics.newQuad(15, 48, 2, 16, dropDownImg:getDimensions())
  dropDownSide8 = love.graphics.newQuad(17, 48, 15, 16, dropDownImg:getDimensions())


  textboxImg = love.graphics.newImage("gui/textbox.png")
  textboxSide1 = love.graphics.newQuad(0, 0, 10, 16, textboxImg:getDimensions())
  textboxSide2 = love.graphics.newQuad(10, 0, 10, 16, textboxImg:getDimensions())

  logosImg = love.graphics.newImage("gui/logos.png")
  offense = love.graphics.newQuad(0, 0, 16, 16, logosImg:getDimensions())
  defense = love.graphics.newQuad(16, 0, 16, 16, logosImg:getDimensions())

  playerButtonImg = love.graphics.newImage("gui/playerbutton.png")
  playerButton = {}
  playerButtonOverlay = {}
  bannerButton = {}
  checkmark = {}
  deny = {}
  for i = 0, 21 do
    playerButton[#playerButton + 1] = love.graphics.newQuad(0, i * 32, 82, 16, playerButtonImg:getDimensions())
    playerButtonOverlay[#playerButtonOverlay + 1] = love.graphics.newQuad(82, i * 32, 82, 16, playerButtonImg:getDimensions())
    bannerButton[#bannerButton + 1] = love.graphics.newQuad(0, i * 32 + 16, 16, 16, playerButtonImg:getDimensions())
    checkmark[#checkmark + 1] = love.graphics.newQuad(32, i * 32 + 16, 16, 16, playerButtonImg:getDimensions())
    deny[#deny + 1] = love.graphics.newQuad(16, i * 32 + 16, 16, 16, playerButtonImg:getDimensions())
  end

  fieldImg = love.graphics.newImage("field.png")
end

function loadSpriteSheet(image, size, size2)
  if size2 == nil then
    size2 = size
  end
  table = {}
  for h = 0, (image:getHeight() / size) - 1 do
    for w = 0, (image:getWidth() / size2) - 1 do
      table[#table + 1] = love.graphics.newQuad(w * size2, h * size, size2, size, image:getDimensions())
    end
  end
  return table
end
