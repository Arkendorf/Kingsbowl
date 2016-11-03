function clientmenu_load()
  ip = "127.0.0.1"
  proceed = false
  nameSent = false
  success = nil
  accepted = false
  team1 = {r = 255, g = 0, b = 0, name = "Team 1"}
  team2 = {r = 0, g = 0, b = 255, name = "Team 2"}
  players = {{name = playerName, id = "host", team = 1, image = "prep", frame = 1}}
  target = nil

  connectButton = loadButton("Connect", 50)
  errorMsg = ""

  coin = {dt = 0, v = 0, y = 0, frame = 1, result = 1, landed = false}
  start = false
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
      client:send(bin:pack({"name", playerName}))
      nameSent = true
    end

    -- real stuff
    x = love.mouse.getX() / scale.x
    y = love.mouse.getY() / scale.y

    -- find targeted player

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

    for p = 1, #players do
      if players[p].delete == true then
        if players[p].image ~= "dissapear" then
          players[p].image = "dissapear"
          players[p].frame = 1
        else
          players[p].frame = players[p].frame + dt * 30
          if players[p].frame > 18 then
            -- delete player
            players[p] = nil
            target = nil
          end
        end
      elseif players[p].image == "dissapear" then
        if players[p].frame > 0 then
          players[p].frame = players[p].frame - dt * 30
        else
          players[p].image = "prep"
          players[p].frame = 1
        end
      elseif players[p].image == "switch1" then
        if players[p].frame > 22 then
          if players[p].team == 1 then
            players[p].team = 2
          else
            players[p].team = 1
          end
          players[p].image = "switch2"
          players[p].frame = 22
        else
          players[p].frame = players[p].frame + dt * 30
        end
        target = nil
      elseif players[p].image == "switch2" then
        if players[p].frame > 0 then
          players[p].frame = players[p].frame - dt * 30
        else
          players[p].image = "prep"
          players[p].frame = 1
        end
        target = nil
      else
        players[p].frame = players[p].frame + dt * 12
        players[p].frame = loop(players[p].frame, 6)
      end
    end
    --coinflip stuff
    if start == true then
      target = nil
      if coin.landed == false then
        if coin.result == 0 then
          coin.frame = coin.frame + 0.24 * dt * 50
        else
          coin.frame = coin.frame + 0.36 * dt * 50
        end
      end
      if coin.landed == false then
        coin.y = coin.y + coin.v
        coin.v = coin.v + 0.2 * dt * 50
        if coin.y >= 0 then
          coin.v = 0
          coin.y = 0
          coin.landed = true
        end
      end
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

    -- draw defense/offense logos
    if start == true and coin.landed == true then
      if coin.result == 0 then
        love.graphics.draw(logosImg, defense, 104, 122)
        love.graphics.draw(logosImg, offense, 280, 122)
      else
        love.graphics.draw(logosImg, offense, 104, 122)
        love.graphics.draw(logosImg, defense, 280, 122)
      end
    end

    -- if a player is targeted, reflect that
    if target ~= nil then
      if players[target].team == 1 then
        love.graphics.print(tostring(players[target].name), 112 - getPixelWidth(tostring(players[target].name)) / 2, 125)
        love.graphics.print(tostring(players[target].id), 112 - getPixelWidth(tostring(players[target].id)) / 2, 200)
      else
        love.graphics.print(tostring(players[target].name), 287 - getPixelWidth(tostring(players[target].name)) / 2, 125)
        love.graphics.print(tostring(players[target].id), 287 - getPixelWidth(tostring(players[target].id)) / 2, 200)
      end
    end

    --beginning stuff
    love.graphics.draw(coinShadeImg, coinShadeQuad[range(math.abs(math.floor(coin.y / 10)), 1, 7)], 184, 166)
    love.graphics.draw(coinImg, coinQuad[loop(math.floor(coin.frame), 12)], 184, 150 + coin.y)
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
