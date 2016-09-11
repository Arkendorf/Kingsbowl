function servermenu_load()
  team1 = {name = "Team 1", r = 250, g = 0, b = 0, playerNum = 0}
  team2 = {name = "Team 2", r = 0, g = 0, b = 255, playerNum = 0}
  slider = {type = ""}
  textBox = ""
  frame = 1
  target = nil
  players = {{id = "Hawktalon", team = 2}, {id = "EQuigs", team = 1}, {id = "ipusername", team = 1}, {id = "Arkendorf", team = 1}, {id = "DrJado", team = 1}, {id = "TheWizardN", team = 1}, {id = "TheDankPig", team = 1}}
  --server = lube.udpServer()
  --server:listen(25565)
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
  love.graphics.draw(bannerImg, bannerColor, 75, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bannerImg, banner, 75, 50)
  love.graphics.print(team1.name, 112 - getPixelWidth(team1.name) / 2, 58)
  love.graphics.draw(sliderImg, bar, 87, 74)
  love.graphics.draw(sliderImg, bar, 87, 82)
  love.graphics.draw(sliderImg, bar, 87, 90)

  love.graphics.draw(sliderImg, knob, 87 + math.floor(team1.r / 5.10), 72)
  love.graphics.draw(sliderImg, knob, 87 + math.floor(team1.g / 5.10), 80)
  love.graphics.draw(sliderImg, knob, 87 + math.floor(team1.b / 5.10), 88)

  for i = 1, team1.playerNum do
    love.graphics.draw(prep, prepQuad[math.ceil(frame)], 64 + i * 10, 150)
  end

  --team2
  love.graphics.setColor(team2.r, team2.g, team2.b)
  love.graphics.draw(bannerImg, bannerColor, 325, 50, 0, -1, 1)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bannerImg, banner, 325, 50, 0, -1, 1)
  love.graphics.print(team2.name, 287 - getPixelWidth(team2.name) / 2, 58)
  love.graphics.draw(sliderImg, bar, 262, 74)
  love.graphics.draw(sliderImg, bar, 262, 82)
  love.graphics.draw(sliderImg, bar, 262, 90)

  love.graphics.draw(sliderImg, knob, 262 + math.floor(team2.r / 5.10), 72)
  love.graphics.draw(sliderImg, knob, 262 + math.floor(team2.g / 5.10), 80)
  love.graphics.draw(sliderImg, knob, 262 + math.floor(team2.b / 5.10), 88)

  for i = 1, team2.playerNum do
    love.graphics.draw(prep, prepQuad[math.ceil(frame)], 336 + i * -10, 150, 0, -1, 1)
  end



  -- if a player is targeted, reflect that
  if target ~= nil then
    if players[target].team == 1 then
      love.graphics.print(tostring(players[target].id), 112 - getPixelWidth(tostring(players[target].id)) / 2, 125)
      if team2.playerNum < 6 then
        love.graphics.print("click to swap", 85, 200)
      else
        love.graphics.print("team full", 94, 200)
      end
    else
      love.graphics.print(tostring(players[target].id), 287 - getPixelWidth(tostring(players[target].id)) / 2, 125)
      if team1.playerNum < 6 then
        love.graphics.print("click to swap", 261, 200)
      else
        love.graphics.print("team full", 270, 200)
      end
    end
  end

  -- if player is typing, show where
  if textBox == "team1" then
    love.graphics.rectangle("line", 79, 54, 67, 16)
  elseif textBox == "team2" then
    love.graphics.rectangle("line", 254, 54, 67, 16)
  end
end

function servermenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 87 + team1.r / 5.10 and x <= 87 + team1.r / 5.10 + 2 and y >= 72 and y <= 72 + 6 then
      slider = {type = "r1", xPos = x, yPos = y, old = team1.r}
    elseif x >= 87 + team1.g / 5.10 and x <= 87 + team1.g / 5.10 + 2 and y >= 80 and y <= 80 + 6 then
      slider = {type = "g1", xPos = x, yPos = y, old = team1.g}
    elseif x >= 87 + team1.b / 5.10 and x <= 87 + team1.b / 5.10 + 2 and y >= 88 and y <= 88 + 6 then
      slider = {type = "b1", xPos = x, yPos = y, old = team1.b}
    elseif x >= 262 + team2.r / 5.10 and x <= 262 + team2.r / 5.10 + 2 and y >= 72 and y <= 72 + 6 then
      slider = {type = "r2", xPos = x, yPos = y, old = team2.r}
    elseif x >= 262 + team2.g / 5.10 and x <= 262 + team2.g / 5.10 + 2 and y >= 80 and y <= 80 + 6 then
      slider = {type = "g2", xPos = x, yPos = y, old = team2.g}
    elseif x >= 262 + team2.b / 5.10 and x <= 262 + team2.b / 5.10 + 2 and y >= 88 and y <= 88 + 6 then
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
    if x >= 79 and x <= 146 and y >= 54 and y <= 70 then
      textBox = "team1"
    elseif x >= 254 and x <= 321 and y >= 54 and y <= 70 then
      textBox = "team2"
    else
      textBox = ""
    end
  end
end

function servermenu_textinput(text)
  if textBox == "team1" and getPixelWidth(team1.name .. text) < 67 then
    team1.name = team1.name .. text
  elseif textBox == "team2" and getPixelWidth(team2.name .. text) < 67 then
    team2.name = team2.name .. text
  end
end

function servermenu_keypressed(key)
  if key == "backspace" then
    if textBox == "team1" then
      team1.name = string.sub(team1.name, 1, -2)
    elseif textBox == "team2" then
      team2.name = string.sub(team2.name, 1, -2)
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
