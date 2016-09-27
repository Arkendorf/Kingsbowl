function clientmenu_load()
  ip = ""
  proceed = false
  nameSent = false
  success = false
  accepted = false
  team1 = {r = 255, g = 0, b = 0, name = "Team 1", playerNum = 0}
  team2 = {r = 0, g = 0, b = 255, name = "Team 2", playerNum = 0}
  players = {{name = playerName, id = "host", team = 1, delete = false, image = "prep", frame = 1}}
  target = nil

  connectButton = loadButton("Connect", 50)
  errorMsg = ""
end

function clientmenu_update(dt)
  if proceed == false then
    ipBoxLength = range(getPixelWidth(ip) + 6, 94, math.huge)
  else
    client:update(dt)

    if success == false then
      proceed = false
      errorMsg = "Unable to connect to server. Check IP"
      textBox = ""
      success = nil
    elseif success == true and nameSent == false then
      client:send(bin:pack({msg = "name", name = playerName}))
      nameSent = true
    end

    -- real stuff
    x = love.mouse.getX() / scale.x
    y = love.mouse.getY() / scale.y

    n1 = 0
    n2 = 0
    result = false
    for p = 1, #players do
      if players[p].team == 1 then
        n1 = n1 + 1
        if x > 70 + n1 * 10 and x < 70 + n1 * 10 + 16 and y > 150 and y < 182 then
          result = true
          target = p
        end
      else
        n2 = n2 + 1
        if x < 330 - n2 * 10 and x > 330 - n2 * 10 - 16 and y > 150 and y < 182 then
          result = true
          target = p
        end
      end
    end
    if result == false then
      target = nil
    end



  end
end

function clientmenu_draw()
  if proceed == false then
    love.graphics.print("Enter IP:", 181, 150)

    love.graphics.print(ip, 200 - getPixelWidth(ip) / 2, 168)
    love.graphics.draw(connectButton, 175, 186)

    love.graphics.setColor(255, 55, 55)
    love.graphics.print(errorMsg, 200 - getPixelWidth(errorMsg) / 2, 208)
    love.graphics.setColor(255, 255, 255)

    if textBox == "ip" then
      love.graphics.rectangle("line", 200 - ipBoxLength / 2, 164, ipBoxLength, 16)
    else
      love.graphics.draw(textboxImg, textboxSide1, 200 - ipBoxLength / 2, 164)
      love.graphics.draw(textboxImg, textboxSide2, 190 + ipBoxLength / 2, 164)
    end
  elseif accepted == false then
    love.graphics.print("Waiting for response", 159, 150)
  else
    love.graphics.draw(window, 75, 50)
    -- team1
    love.graphics.setColor(team1.r, team1.g, team1.b)
    love.graphics.draw(bannerImg, bannerColor, 75, 50)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(bannerImg, banner, 75, 50)
    love.graphics.print(team1.name, 112 - getPixelWidth(team1.name) / 2, 58)

    playersDrawn = 1
    for p = 1, #players do
      if players[p].team == 1 then
        char = drawChar(players[p].image, players[p].frame)
        love.graphics.draw(char[1], char[2], 64 + playersDrawn * 10, 150)
        love.graphics.setColor(team1.r, team1.g, team1.b)
        love.graphics.draw(char[3], char[4], 64 + playersDrawn * 10, 150)
        love.graphics.setColor(255, 255, 255)
        playersDrawn = playersDrawn + 1
      end
    end

    --team2
    love.graphics.setColor(team2.r, team2.g, team2.b)
    love.graphics.draw(bannerImg, bannerColor, 325, 50, 0, -1, 1)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(bannerImg, banner, 325, 50, 0, -1, 1)
    love.graphics.print(team2.name, 287 - getPixelWidth(team2.name) / 2, 58)

    playersDrawn = 1
    for p = 1, #players do
      if players[p].team == 2 then
        char = drawChar(players[p].image, players[p].frame)
        love.graphics.draw(char[1], char[2], 336 + playersDrawn * -10, 150, 0, -1, 1)
        love.graphics.setColor(team2.r, team2.g, team2.b)
        love.graphics.draw(char[3], char[4], 336 + playersDrawn * -10, 150, 0, -1, 1)
        love.graphics.setColor(255, 255, 255)
        playersDrawn = playersDrawn + 1
      end
    end

    if target ~= nil then
      if players[target].team == 1 then
        love.graphics.print(tostring(players[target].name), 112 - getPixelWidth(tostring(players[target].name)) / 2, 125)
        love.graphics.print(tostring(players[target].id), 112 - getPixelWidth(tostring(players[target].id)), 200)
      else
        love.graphics.print(tostring(players[target].name), 287 - getPixelWidth(tostring(players[target].name)) / 2, 125)
        love.graphics.print(tostring(players[target].id), 287 - getPixelWidth(tostring(players[target].id)), 200)
      end
    end
  end
end

function clientmenu_textinput(text)
  if proceed == false then
    if textBox == "ip" then
      ip = ip .. text
    end
  end
end


function clientmenu_keypressed(key)
  if proceed == false then
    if key == "backspace" then
      if textBox == "ip" then
        ip = string.sub(ip, 1, -2)
      end
    elseif key == "return" then
      connectToServer()
    end
  end
end

function clientmenu_mousepressed(x, y, button)
  if proceed == false then
    if button == 1 then
      if x >= 200 - ipBoxLength / 2 and x <= 200 + ipBoxLength / 2 and y >= 164 and y <= 180 then
        textBox = "ip"
        errorMsg = ""
      elseif x >= 175 and x <= 225 and y >= 186 and y <= 202 and proceed == false then
        connectToServer()
      else
        textBox = ""
      end
    end
  end
end

function interpretIp(ip)
  if ip == "" then
    ip = " "
  end
  if string.find(":", ip) ~= nil then
    start, final = string.find(":", ip)
    return string.sub(ip, 1, start - 1), string.sub(ip, start + 1, -1)
  else
    return ip, 25565
  end
end

function connectToServer()
  errorMsg = ""
  proceed = true
  client = lube.udpClient()
  success, err = client:connect(interpretIp(ip))
end

function client_quit()
  client:disconnect()
end
