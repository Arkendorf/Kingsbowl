function mainmenu_load()
  tutButton = loadButton("Tutorial", 50, 55, 55, 255)
  hostButton = loadButton("Host", 50)
  joinButton = loadButton("Join", 50)
end

function mainmenu_update()
end

function mainmenu_draw()
  love.graphics.draw(tutButton, 175, 150)
  love.graphics.draw(hostButton, 175, 168)
  love.graphics.draw(joinButton, 175, 186)
end

function mainmenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 175 and x <= 175 + 50 and y >= 150 and y <= 150 + 16 then
      gamestate = "tutorial"
    elseif x >= 175 and x <= 175 + 50 and y >= 168 and y <= 168 + 16 then
      servermenu_load()
      gamestate = "servermenu"
    elseif x >= 175 and x <= 175 + 50 and y >= 186 and y <= 186 + 16 then
      clientmenu_load()
      gamestate = "clientmenu"
    end
  end
end

function getPixelWidth(string)
  l = -1
  for i = 1, string.len(string) do
    if string.find(".i", string.sub(string, i, i)) ~= nil then
      l = l + 2
    elseif string.find("W" , string.sub(string, i, i)) ~= nil then
      l = l + 8
    elseif string.find(" ABCDEFGHJKLMNOPQRSTUVWXYZmw023456789?" , string.sub(string, i, i)) ~= nil then
      l = l + 6
    elseif string.find("ak" , string.sub(string, i, i)) ~= nil then
      l = l + 5
    elseif string.find("Ibcdefghnopqrsuvxyz" , string.sub(string, i, i)) ~= nil then
      l = l + 4
    elseif string.find("jlt1!" , string.sub(string, i, i)) ~= nil then
      l = l + 3
    end
  end
  return l
end

function loadButton(string, w, r, g, b)
  button = love.graphics.newCanvas(w, 16)
  love.graphics.setCanvas(button)
  love.graphics.clear()
  if r ~= nil and g ~= nil and b ~= nil then
    love.graphics.setColor(r, g, b)
  else
    love.graphics.setColor(125, 125, 125)
  end
  love.graphics.draw(buttonImg, buttonColorSide, 0, 0)
  love.graphics.draw(buttonImg, buttonColorMiddle, 3, 0, 0, w / 26, 1)
  love.graphics.draw(buttonImg, buttonColorSide, w, 0, 0, -1, 1)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(buttonImg, buttonSide, 0, 0)
  love.graphics.draw(buttonImg, buttonMiddle, 3, 0, 0, w / 26, 1)
  love.graphics.draw(buttonImg, buttonSide, w, 0, 0, -1, 1)
  love.graphics.print(string, math.ceil(w / 2 - getPixelWidth(string) / 2), 3)
  love.graphics.setCanvas()
  return button
end
