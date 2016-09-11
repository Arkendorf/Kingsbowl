function servermenu_load()
  team1 = {name = "team 1", r = 125, g = 125, b = 125, playerNum = 0}
  team2 = {name = "team 2", r = 125, g = 125, b = 125, playerNum = 0}
  slider = {type = ""}
  frame = 1
  target = nil
  players = {{id = "host", team = 1}, {id = "ip/username", team = 2}}
  server = lube.udpServer()
  server:listen(25565)
end

function servermenu_update(dt)
  x = love.mouse.getX() / scale.x
  y = love.mouse.getY() / scale.y

  team1.playerNum = 0
  team2.playerNum = 0
  for p = 1, #players do
    if players[p].team == 1 then
      team1.playerNum = team1.playerNum + 1
    else
      team2.playerNum = team2.playerNum + 1
    end
  end

  updateSlider(slider)
  frame = frame + dt * 12
  frame = loop(frame, 6)

  -- find targeted player
  for i = 1, team1.playerNum do
    if x > 70 + i * 10 and x < 70 + i * 10 + 16 and y > 150 and y < 182 then
      result = true
      n = 1
      for p = 1, #players do
        if players[p].team == 1 then
          if n == i then
            target = p
            break
          else
            n = n + 1
          end
        end
      end
    end
  end
  for i = 1, team2.playerNum do
    if x < 330 - i * 10 and x > 330 - i * 10 - 16 and y > 150 and y < 182 then
      result = true
      n = 1
      for p = 1, #players do
        if players[p].team == 2 then
          if n == i then
            target = p
            break
          else
            n = n + 1
          end
        end
      end
    end
  end
  if result == false then
    target = nil
  else
    result = false
  end
end

function servermenu_draw()
  love.graphics.rectangle("line", 75, 50, 250, 175)
  -- team1
  love.graphics.setColor(team1.r, team1.g, team1.b)
  love.graphics.rectangle("fill", 75, 50, 75, 62)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(team1.name, 112 - getPixelWidth(team1.name) / 2, 58)
  love.graphics.rectangle("fill", 87, 80, 50, 2)
  love.graphics.rectangle("fill", 87, 88, 50, 2)
  love.graphics.rectangle("fill", 87, 96, 50, 2)

  love.graphics.rectangle("fill", 87 + team1.r / 5.10, 78, 2, 6)
  love.graphics.rectangle("fill", 87 + team1.g / 5.10, 86, 2, 6)
  love.graphics.rectangle("fill", 87 + team1.b / 5.10, 94, 2, 6)

  for i = 1, team1.playerNum do
    love.graphics.draw(prep, prepQuad[math.ceil(frame)], 64 + i * 10, 150)
  end

  --team2
  love.graphics.setColor(team2.r, team2.g, team2.b)
  love.graphics.rectangle("fill", 250, 50, 75, 62)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(team2.name, 287 - getPixelWidth(team1.name) / 2, 58)
  love.graphics.rectangle("fill", 262, 80, 50, 2)
  love.graphics.rectangle("fill", 262, 88, 50, 2)
  love.graphics.rectangle("fill", 262, 96, 50, 2)

  love.graphics.rectangle("fill", 262 + team2.r / 5.10, 78, 2, 6)
  love.graphics.rectangle("fill", 262 + team2.g / 5.10, 86, 2, 6)
  love.graphics.rectangle("fill", 262 + team2.b / 5.10, 94, 2, 6)

  for i = 1, team2.playerNum do
    love.graphics.draw(prep, prepQuad[math.ceil(frame)], 336 + i * -10, 150, 0, -1, 1)
  end




  if target ~= nil then
    if players[target].team == 1 then
      love.graphics.print(tostring(players[target].id), 106 - getPixelWidth(tostring(players[target].id)) / 2, 125)
      if team1.playerNum < 6 then
        love.graphics.print("click to swap", 87, 200)
      else
        love.graphics.print("team full", 87, 200)
      end
    else
      love.graphics.print(tostring(players[target].id), 286 - getPixelWidth(tostring(players[target].id)) / 2, 125)
      if team2.playerNum < 6 then
        love.graphics.print("click to swap", 236, 200)
      else
        love.graphics.print("team full", 87, 200)
      end
    end
  end
end

function servermenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 87 + team1.r / 5.10 and x <= 87 + team1.r / 5.10 + 2 and y >= 78 and y <= 78 + 6 then
      slider = {type = "r1", xPos = x, yPos = y, old = team1.r}
    elseif x >= 87 + team1.g / 5.10 and x <= 87 + team1.g / 5.10 + 2 and y >= 86 and y <= 86 + 6 then
      slider = {type = "g1", xPos = x, yPos = y, old = team1.g}
    elseif x >= 87 + team1.b / 5.10 and x <= 87 + team1.b / 5.10 + 2 and y >= 94 and y <= 94 + 6 then
      slider = {type = "b1", xPos = x, yPos = y, old = team1.b}
    elseif x >= 262 + team2.r / 5.10 and x <= 262 + team2.r / 5.10 + 2 and y >= 78 and y <= 78 + 6 then
      slider = {type = "r2", xPos = x, yPos = y, old = team2.r}
    elseif x >= 262 + team2.g / 5.10 and x <= 262 + team2.g / 5.10 + 2 and y >= 86 and y <= 86 + 6 then
      slider = {type = "g2", xPos = x, yPos = y, old = team2.g}
    elseif x >= 262 + team2.b / 5.10 and x <= 262 + team2.b / 5.10 + 2 and y >= 94 and y <= 94 + 6 then
      slider = {type = "b2", xPos = x, yPos = y, old = team2.b}
    elseif target ~= nil then
      if players[target].team == 1 then
        if team2.playerNum < 6 then
          players[target].team = 2
        end
      else
        if team1.playerNum < 6 then
          players[target].team = 1
        end
      end
    end
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
      team1.r = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    elseif slider.type == "g1" then
      team1.g = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    elseif slider.type == "b1" then
      team1.b = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    elseif slider.type == "r2" then
      team2.r = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    elseif slider.type == "g2" then
      team2.g = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    elseif slider.type == "b2" then
      team2.b = range((x - slider.xPos) * 5.10 + slider.old, 0, 255)
    end
  else
    slider.type = ""
  end
end
