function servermenu_load()
  team1 = {name = "team 1", r = 125, g = 125, b = 125, playerNum = 6}
  slider = {type = ""}
  frame = 1
end

function servermenu_update(dt)
  updateSlider(slider)
  frame = frame + dt * 12
  frame = loop(frame, 6)
end

function servermenu_draw()
  love.graphics.rectangle("line", 150, 100, 500, 350)
  -- team1
  love.graphics.setColor(team1.r, team1.g, team1.b)
  love.graphics.rectangle("fill", 150, 100, 150, 125)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(team1.name, 225 - getPixelWidth(team1.name) / 2, 125)
  love.graphics.rectangle("fill", 175, 160, 100, 4)
  love.graphics.rectangle("fill", 175, 175, 100, 4)
  love.graphics.rectangle("fill", 175, 190, 100, 4)

  love.graphics.rectangle("fill", 175 + team1.r / 2.55, 156, 4, 12)
  love.graphics.rectangle("fill", 175 + team1.g / 2.55, 171, 4, 12)
  love.graphics.rectangle("fill", 175 + team1.b / 2.55, 186, 4, 12)

  for i = 1, team1.playerNum do
    love.graphics.draw(prep, prepQuad[math.ceil(frame)], 130 + i * 20, 300, 0, 2, 2)
  end
end

function servermenu_mousepressed(x, y, button)
  if x >= 175 + team1.r / 2.55 and x <= 175 + team1.r / 2.55 + 4 and y >= 156 and y <= 156 + 4 then
    slider = {type = "r1", xPos = x, yPos = y, old = team1.r}
  elseif x >= 175 + team1.g / 2.55 and x <= 175 + team1.g / 2.55 + 4 and y >= 171 and y <= 171 + 4 then
    slider = {type = "g1", xPos = x, yPos = y, old = team1.g}
  elseif x >= 175 + team1.b / 2.55 and x <= 175 + team1.b / 2.55 + 4 and y >= 186 and y <= 186 + 4 then
    slider = {type = "b1", xPos = x, yPos = y, old = team1.b}
  end
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

function loop(num, max)
  if num > max then
    return num - max
  elseif num < 0 then
    return max
  else
    return num
  end
end

function getPixelWidth(string)
  l = -1
  for i = 1, string.len(string) do
    if string.find(" abcdeghjmnopqrsuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ023456789?-+&#+" , string.sub(string, i, i)) ~= nil then
      l = l + 6
    elseif string.find("fk" , string.sub(string, i, i)) ~= nil then
      l = l + 5
    elseif string.find("tI1/()%[]\"" , string.sub(string, i, i)) ~= nil then
      l = l + 4
    elseif string.find("l`*" , string.sub(string, i, i)) ~= nil then
      l = l + 3
    elseif string.find("i.m!:;'", string.sub(string, i, i)) ~= nil then
      l = l + 2
    end
  end
  return l
end

function updateSlider(slider)
  if love.mouse.isDown(1) == true then
    if slider.type == "r1" then
      team1.r = range((love.mouse.getX() - slider.xPos) * 2.55 + slider.old, 0, 255)
    elseif slider.type == "g1" then
      team1.g = range((love.mouse.getX() - slider.xPos) * 2.55 + slider.old, 0, 255)
    elseif slider.type == "b1" then
      team1.b = range((love.mouse.getX() - slider.xPos) * 2.55 + slider.old, 0, 255)
    end
  else
    slider.type = ""
  end
end
