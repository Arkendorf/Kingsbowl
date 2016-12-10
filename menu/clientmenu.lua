function clientmenu_load()
  ip = "127.0.0.1"
  proceed = false
  nameSent = false
  success = nil
  accepted = false
  team = {{r = 255, g = 0, b = 0, name = "Team 1"}, {r = 0, g = 0, b = 255, name = "Team 2"}}
  players = {{name = playerName, id = "host", team = 1, image = "prep", frame = 1}}
  target = nil

  errorMsg = ""
  clientmenu_canvas()

  coin = {dt = 0, v = 0, y = 0, frame = 1, result = 1, landed = false}
  start = false
  identifier = ""
  initialPositions = false
end

function clientmenu_canvas()
  connectButton = loadButton("Connect", 50)
  settingsMenu = love.graphics.newCanvas(250, 225)
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
    x, y = adjust(love.mouse.getPosition())

    -- find targeted player

    n1 = 0
    n2 = 0
    result = false
    for p = #players, 1, -1 do
      if players[p].team == 1 then
        n1 = n1 + 1
        if x > 60 + n1 * 10 and x < 60 + n1 * 10 + 16 and y > 150 and y < 182 then
          result = true
          target = p
        end
      else
        n2 = n2 + 1
        if x < 340 - n2 * 10 and x > 340 - n2 * 10 - 16 and y > 150 and y < 182 then
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
      elseif players[p].image == "unsheathSword" or players[p].image == "grabShield" then
        if players[p].frame < 13 then
          players[p].frame = players[p].frame + dt * 12
        else
          players[p].frame = 14
        end
      else
        players[p].frame = players[p].frame + dt * 12
        players[p].frame = loop(players[p].frame, 6)
        if players[p].image == "prep" and coin.landed == true and players[p].frame < 2 then
          if coin.result == 1 then
            if players[p].team == 1 then
              players[p].image = "unsheathSword"
            else
              players[p].image = "grabShield"
            end
          else
            if players[p].team == 1 then
              players[p].image = "grabShield"
            else
              players[p].image = "unsheathSword"
            end
          end
          players[p].frame = 1
        end
      end
    end

    --coinflip stuff
    if start == true then
      target = nil
      if coin.landed == false then
        if coin.result == 1 then
          coin.frame = coin.frame + 0.24 * dt * 50
        else
          coin.frame = coin.frame + 0.36 * dt * 50
        end
        coin.y = coin.y + coin.v
        coin.v = coin.v + 0.2 * dt * 50
        if coin.y >= 0 then
          coin.v = 0
          coin.y = 0
          coin.landed = true
        end
      else
        coin.dt = coin.dt + dt
      end
    end

    -- initial positions
    if coin.landed == true and initialPositions == false then
      if coin.result == 1 then
        team[1].position = "defense"
        team[2].position = "offense"
      else
        team[1].position = "offense"
        team[2].position = "defense"
      end
      initialPositions = true
    end
  end
end


function clientmenu_draw()
  if proceed == false then
    love.graphics.print("Enter IP:", 181, 150)

    love.graphics.print(ip, 200 - math.floor(getPixelWidth(ip) / 2), 168)
    love.graphics.draw(connectButton, 175, 186)

    love.graphics.setColor(255, 55, 55)
    love.graphics.print(errorMsg, 200 - math.floor(getPixelWidth(errorMsg) / 2), 208)
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
    love.graphics.setCanvas(settingsMenu)
    love.graphics.clear()

    love.graphics.draw(window, 0, 0)
    -- team1
    love.graphics.setColor(team[1].r, team[1].g, team[1].b)
    love.graphics.draw(bannerImg, bannerColor, 0, 0)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(bannerImg, banner, 0, 0)
    love.graphics.print(team[1].name, 37 - math.floor(getPixelWidth(team[1].name) / 2), 8)

    --team2
    love.graphics.setColor(team[2].r, team[2].g, team[2].b)
    love.graphics.draw(bannerImg, bannerColor, 250, 0, 0, -1, 1)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(bannerImg, banner, 250, 0, 0, -1, 1)
    love.graphics.print(team[2].name, 212 - math.floor(getPixelWidth(team[2].name) / 2), 8)

    -- draw defense/offense logos
    if start == true and coin.landed == true then
      logoScale = range(coin.dt * 2, 0, 1)
      if coin.result == 1 then
        love.graphics.draw(logosImg, defense, 37, 80, 0, logoScale, logoScale, 8, 8)
        love.graphics.draw(logosImg, offense, 213, 80, 0, logoScale, logoScale, 8, 8)
      else
        love.graphics.draw(logosImg, offense, 37, 80, 0, logoScale, logoScale, 8, 8)
        love.graphics.draw(logosImg, defense, 213, 80, 0, logoScale, logoScale, 8, 8)
      end
    end

    -- if a player is targeted, reflect that
    if target ~= nil then
      if players[target].team == 1 then
        love.graphics.print(tostring(players[target].name), 37 - math.floor(getPixelWidth(tostring(players[target].name)) / 2), 75)
        love.graphics.print(tostring(players[target].id), 37 - math.floor(getPixelWidth(tostring(players[target].id)) / 2), 150)
      else
        love.graphics.print(tostring(players[target].name), 212 - math.floor(getPixelWidth(tostring(players[target].name)) / 2), 75)
        love.graphics.print(tostring(players[target].id), 212 - math.floor(getPixelWidth(tostring(players[target].id)) / 2), 150)
      end
    end

    --beginning stuff
    love.graphics.draw(coinShadeImg, coinShadeQuad[range(math.abs(math.floor(coin.y / 10)), 1, 7)], 109, 116)
    love.graphics.draw(coinImg, coinQuad[loop(math.floor(coin.frame), 12)], 109, 100 + coin.y)

    love.graphics.setCanvas(mainScreen)

    love.graphics.draw(fieldImg, 200, 150, 0, 1, 1, 1000, 300)

    --players
    playerNum = {0, 0}
    for p = 1, #players do
      if players[p].team == 1 then
        playerNum[1] = playerNum[1] + 1
      else
        playerNum[2] = playerNum[2] + 1
      end
    end
    playerNum[3] = 1
    playerNum[4] = 1
    for p = 1, #players do
      if players[p].team == 1 then
        char = drawChar(players[p].image, players[p].frame)
        love.graphics.draw(charShadow, 64 + (playerNum[1] - playerNum[3]) * 10, 166)
        love.graphics.draw(char[1], char[2], 64 + (playerNum[1] - playerNum[3]) * 10, 150)
        love.graphics.setColor(team[1].r, team[1].g, team[1].b)
        love.graphics.draw(char[3], char[4], 64 + (playerNum[1] - playerNum[3]) * 10, 150)
        love.graphics.setColor(255, 255, 255)
        playerNum[3] = playerNum[3] + 1
      else
        char = drawChar(players[p].image, players[p].frame)
        love.graphics.draw(charShadow, 336 + (playerNum[2] - playerNum[4]) * -10, 166, 0, -1, 1)
        love.graphics.draw(char[1], char[2], 336 + (playerNum[2] - playerNum[4]) * -10, 150, 0, -1, 1)
        love.graphics.setColor(team[2].r, team[2].g, team[2].b)
        love.graphics.draw(char[3], char[4], 336 + (playerNum[2] - playerNum[4]) * -10, 150, 0, -1, 1)
        love.graphics.setColor(255, 255, 255)
        playerNum[4] = playerNum[4] + 1
      end
    end

    settingsScale = range((4 - coin.dt), 0, 1)
    love.graphics.draw(settingsMenu, 200, 162, 0, settingsScale, settingsScale, 125, 112)
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

function clientmenu_onReceive(data)
  data = bin:unpack(data)
  if data["1"] == "disconnect" then
    client:disconnect()
    clientmenu_load()
    errorMsg = "Kicked by server"
  elseif data["1"] == "join" then
    accepted = true
  elseif data["1"] == "teams" then
    team[1] = {name = data["2"], r = data["3"], g = data["4"], b = data["5"]}
    team[2] = {name = data["6"], r = data["7"], g = data["8"], b = data["9"]}
  elseif data["1"] == "player" then
    playerFound = false
    for p = 1, #players do
      if players[p].id == data["3"] then
        players[p] = {name = data["2"], id = data["3"], team = data["4"], image = data["5"], frame = data["6"], delete = data["7"]}
        playerFound = true
        break
      end
    end
    if playerFound == false then
      players[#players + 1] = {name = data["2"], id = data["3"], team = data["4"], image = data["5"], frame = data["6"], delete = data["7"]}
    end
  elseif data["1"] == "coin" then
    start = true
    coin.result = data["2"]
    coin.v = -5
  elseif data["1"] == "begin" then
    client_load()
    gamestate = "client"
  elseif data["1"] == "id" then
    identifier = data["2"]
  end
end
