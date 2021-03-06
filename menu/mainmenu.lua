function mainmenu_load()
  playerName = "Placeholder"

  guiColor = {r = 125, g = 125, b = 125}
  mainmenu_canvas()

  love.keyboard.setKeyRepeat(true)
end

function mainmenu_canvas()
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
    love.graphics.setColor(guiColor.r, guiColor.g, guiColor.b)
  end
  love.graphics.draw(buttonImg, buttonColorSide1, 0, 0)
  love.graphics.draw(buttonImg, buttonColorMiddle, 15, 0, 0, w / 2, 1)
  love.graphics.draw(buttonImg, buttonColorSide2, w - 15, 0)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(buttonImg, buttonSide1, 0, 0)
  love.graphics.draw(buttonImg, buttonMiddle, 15, 0, 0, w / 2, 1)
  love.graphics.draw(buttonImg, buttonSide2, w - 15, 0)
  love.graphics.print(string, math.ceil(w / 2 - getPixelWidth(string) / 2), 3)
  love.graphics.setCanvas()
  return button
end

function loadDropDown(items, selected, open, w)
  DropDown = love.graphics.newCanvas(w, 16 + #items * 16)
  love.graphics.setCanvas(DropDown)
  love.graphics.clear()
  love.graphics.draw(dropDownImg, dropDownSide1, 0, 0)
  love.graphics.draw(dropDownImg, dropDownMiddle1, 15, 0, 0, w / 2, 1)
  love.graphics.draw(dropDownImg, dropDownSide2, w - 15, 0)
  love.graphics.print(items[selected], math.ceil((w - 10) / 2 - getPixelWidth(items[selected]) / 2), 3)
  if open == true then
    for i = 1, #items do
      if i == 1 then
        love.graphics.draw(dropDownImg, dropDownSide3, 0, i * 16)
        love.graphics.draw(dropDownImg, dropDownMiddle2, 15, i * 16, 0, w / 2, 1)
        love.graphics.draw(dropDownImg, dropDownSide4, w - 15, i * 16)
      elseif i == #items then
        love.graphics.draw(dropDownImg, dropDownSide7, 0, i * 16)
        love.graphics.draw(dropDownImg, dropDownMiddle4, 15, i * 16, 0, w / 2, 1)
        love.graphics.draw(dropDownImg, dropDownSide8, w - 15, i * 16)
      else
        love.graphics.draw(dropDownImg, dropDownSide5, 0, i * 16)
        love.graphics.draw(dropDownImg, dropDownMiddle3, 15, i * 16, 0, w / 2, 1)
        love.graphics.draw(dropDownImg, dropDownSide6, w - 15, i * 16)
      end
      love.graphics.print(items[i], math.ceil(w / 2 - getPixelWidth(items[i]) / 2), 3 + i * 16)
    end
  end
  love.graphics.setCanvas()
  return DropDown
end

function range(num, min, max)
  if num > max then
    return max
  elseif num < min then
    return min
  else
    return num
  end
end

function round(x)
  return x + 0.5 - (x + 0.5) % 1
end

function loop(num, max)
  if num > max then
    return num - max
  elseif num < 0 then
    return max
  else
    return num
  end
end


function removeNil(t)
  local ans = {}
  for _,v in pairs(t) do
    ans[ #ans+1 ] = v
  end
  return ans
end
