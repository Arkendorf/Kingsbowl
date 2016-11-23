function servermenu_load()
  team1 = {name = "Team 1", r = 250, g = 0, b = 0, playerNum = 0}
  team2 = {name = "Team 2", r = 0, g = 0, b = 255, playerNum = 0}
  sentTeam1 = {name = "Team 1", r = 250, g = 0, b = 0}
  sentTeam2 = {name = "Team 2", r = 0, g = 0, b = 255}
  slider = {type = ""}
  textBox = ""
  target = nil
  players = {{name = playerName, id = "host", team = 1, delete = false, image = "prep", frame = 1}}
  playerQueue = {false, false, false}
  queue = {}
  port = ""
  proceed = false
  servermenu_canvas()
  playerButtonMax = 40
  newPlayer = false
  coin = {dt = 0, v = 0, y = 0, frame = 1, result = 1, landed = false}
  start = false
end

function servermenu_canvas()
  startButton = loadButton("Start", 50)
  settingsMenu = love.graphics.newCanvas(250, 225)
end

function servermenu_update(dt)
  if proceed == false then
    portBoxLength = range(getPixelWidth(port) + 6, 94, math.huge)
  else
    server:update(dt)

    if team1.name ~= sentTeam1.name or team1.r + team1.g + team1.b ~= sentTeam1.r + sentTeam1.g + sentTeam1.b or team2.name ~= sentTeam2.name or team2.r + team2.g + team2.b ~= sentTeam2.r + sentTeam2.g + sentTeam2.b or newPlayer == true then
      server:send(bin:pack({"teams", team1.name, team1.r, team1.g, team1.b, team2.name, team2.r, team2.g, team2.b}))
      sentTeam1.name, sentTeam1.r, sentTeam1.g, sentTeam1.b = team1.name, team1.r, team1.g, team1.b
      sentTeam2.name, sentTeam2.r, sentTeam2.g, sentTeam2.b = team2.name, team2.r, team2.g, team2.b
    end
    if newPlayer == true then
      for p = 1, #players do
        server:send(bin:pack({"player", players[p].name, players[p].id, players[p].team, players[p].image, players[p].frame, players[p].delete}))
      end
    end
    newPlayer = false

    x, y = adjust(love.mouse.getPosition())

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

    -- loads join requests
    for p = 1, 3 do
      if playerQueue[p] ~= false then
        if playerQueue[p].delete == true then
          if playerQueue[p].dt > 1 then
            playerQueue[p].dt = playerQueue[p].dt - dt * 30 -- animation frame
          else
            playerQueue[p] = false
          end
        else
          if playerQueue[p].dt ~= nil then
            playerQueue[p].dt = playerQueue[p].dt + dt * 30 -- animation frame
          else
            playerQueue[p].dt = 1
          end
        end
        if playerQueue[p] ~= false then
          if playerQueue[p].name ~= nil then
            queue[p] = loadPlayerButton(playerQueue[p].name, range(math.ceil(playerQueue[p].dt), 1, playerButtonMax))
          else
            queue[p] = loadPlayerButton(playerQueue[p].id, range(math.ceil(playerQueue[p].dt), 1, playerButtonMax))
          end
        end
      else
        if #playerQueue > 3 then
          playerQueue[p] = playerQueue[4]
          playerQueue[4] = nil
        end
      end
    end

    -- animate players / change state
    for p = 1, #players do
      if players[p].delete == true then
        if players[p].image ~= "dissapear" then
          players[p].image = "dissapear"
          players[p].frame = 1
          server:send(bin:pack({"player", players[p].name, players[p].id, players[p].team, players[p].image, players[p].frame, players[p].delete}))
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
          animation = {{"unsheathSword", "grabShield"}, { "grabShield", "unsheathSword"}}
          players[p].image = animation[coin.result][players[p].team]
          players[p].frame = 1
        end
      end
    end
    players = removeNil(players)

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
    if coin.dt > 4 then
      server:send(bin:pack({"begin"}))
      server_load()
      gamestate = "server"
    end
  end
end


function servermenu_draw()
  if proceed == false then
    love.graphics.print("Enter port:", 180, 150)
    love.graphics.print(port, 200 - math.floor(getPixelWidth(port) / 2), 168)
    love.graphics.draw(startButton, 175, 186)

    if textBox == "port" then
      love.graphics.rectangle("line", 200 - portBoxLength / 2, 164, portBoxLength, 16)
    else
      love.graphics.draw(textboxImg, textboxSide1, 200 - portBoxLength / 2, 164)
      love.graphics.draw(textboxImg, textboxSide2, 190 + portBoxLength / 2, 164)
    end
  else
    love.graphics.setCanvas(settingsMenu)
    love.graphics.clear()

    love.graphics.draw(window, 0, 0)
    -- team1
    love.graphics.setColor(team1.r, team1.g, team1.b)
    love.graphics.draw(bannerImg, bannerColor, 0, 0)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(sliderImg, bar, 12, 24)
    love.graphics.draw(sliderImg, bar, 12, 32)
    love.graphics.draw(sliderImg, bar, 12, 40)
    love.graphics.draw(sliderImg, knob, 12 + math.floor(team1.r / 5.10), 22)
    love.graphics.draw(sliderImg, knob, 12 + math.floor(team1.g / 5.10), 30)
    love.graphics.draw(sliderImg, knob, 12 + math.floor(team1.b / 5.10), 38)
    love.graphics.draw(bannerImg, banner, 0, 0)
    love.graphics.print(team1.name, 37 - math.floor(getPixelWidth(team1.name) / 2), 8)

    --team2
    love.graphics.setColor(team2.r, team2.g, team2.b)
    love.graphics.draw(bannerImg, bannerColor, 250, 0, 0, -1, 1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(sliderImg, bar, 187, 24)
    love.graphics.draw(sliderImg, bar, 187, 32)
    love.graphics.draw(sliderImg, bar, 187, 40)
    love.graphics.draw(sliderImg, knob, 187 + math.floor(team2.r / 5.10), 22)
    love.graphics.draw(sliderImg, knob, 187 + math.floor(team2.g / 5.10), 30)
    love.graphics.draw(sliderImg, knob, 187 + math.floor(team2.b / 5.10), 38)
    love.graphics.draw(bannerImg, banner, 250, 0, 0, -1, 1)
    love.graphics.print(team2.name, 212 - math.floor(getPixelWidth(team2.name) / 2), 8)

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
        if team2.playerNum < 6 then
          love.graphics.print("click to swap", 10, 150)
        else
          love.graphics.print("team full", 19, 150)
        end
      else
        love.graphics.print(tostring(players[target].name), 212 - math.floor(getPixelWidth(tostring(players[target].name)) / 2), 75)
        if team1.playerNum < 6 then
          love.graphics.print("click to swap", 186, 150)
        else
          love.graphics.print("team full", 195, 150)
        end
      end
    end

    -- if player is typing, show where
    if textBox == "team1" then
      love.graphics.rectangle("line", 4, 5, 68, 16)
    elseif textBox == "team2" then
      love.graphics.rectangle("line", 179, 5, 68, 16)
    end

    -- draw join requests
    for p = 1, 3 do
      if playerQueue[p] ~= false then
        love.graphics.draw(queue[p], -43 + 84 * p - queue[p]:getWidth() / 2, 179)
      end
    end

    --beginning stuff
    love.graphics.draw(startButton, 100, 147)
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
        love.graphics.draw(char[1], char[2], 64 + (playerNum[1] - playerNum[3]) * 10, 150)
        love.graphics.setColor(team1.r, team1.g, team1.b)
        love.graphics.draw(char[3], char[4], 64 + (playerNum[1] - playerNum[3]) * 10, 150)
        love.graphics.setColor(255, 255, 255)
        playerNum[3] = playerNum[3] + 1
      else
        char = drawChar(players[p].image, players[p].frame)
        love.graphics.draw(char[1], char[2], 336 + (playerNum[2] - playerNum[4]) * -10, 150, 0, -1, 1)
        love.graphics.setColor(team2.r, team2.g, team2.b)
        love.graphics.draw(char[3], char[4], 336 + (playerNum[2] - playerNum[4]) * -10, 150, 0, -1, 1)
        love.graphics.setColor(255, 255, 255)
        playerNum[4] = playerNum[4] + 1
      end
    end

    settingsScale = range((4 - coin.dt), 0, 1)
    love.graphics.draw(settingsMenu, 200, 162, 0, settingsScale, settingsScale, 125, 112)
  end
end

function servermenu_mousepressed(x, y, button)
  if proceed == false then
    if button == 1 then
      if x >= 200 - portBoxLength / 2 and x <= 200 + portBoxLength / 2 and y >= 164 and y <= 180 then
        textBox = "port"
      elseif x >= 175 and x <= 225 and y >= 186 and y <= 202 and proceed == false then
        proceed = true
        server = lube.udpServer()
        if port == "" or tonumber(port) == nil then
          server:listen(25565)
        else
          server:listen(tonumber(port))
        end
      else
        textBox = ""
      end
    end
  else
    if button == 1 and start == false then
      if x >= 175 and x <= 225 and y >= 197 and y <= 213 and team1.playerNum > 0 and team2.playerNum > 0 then
        start = true
        coin.v = -5
        coin.result = math.floor(math.random(1, 2) + 0.5)
        server:send(bin:pack({"coin", coin.result}))
      elseif x >= 87 + team1.r / 5.10 and x <= 87 + team1.r / 5.10 + 2 and y >= 72 and y <= 72 + 6 then
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
        if players[target].image == "prep" then
          players[target].image = "switch1"
          players[target].frame = 1
          server:send(bin:pack({"player", players[target].name, players[target].id, players[target].team, players[target].image, players[target].frame, players[target].delete}))
        end

      elseif #queue > 0 then
        for p = 1, 3 do
          if playerQueue[p] ~= false then
            if playerQueue[p].delete == false then
              if x > -5 + 84 * p and x < 11 + 84 * p and y > 245 and y < 245 + 16 then
                server:send(bin:pack({"disconnect"}), playerQueue[p].id)
              elseif x > 37 + 84 * p and x < 53 + 84 * p and y > 245 and y < 245 + 16 and team1.playerNum < 6 then
                server:send(bin:pack({"join"}), playerQueue[p].id)
                players[#players + 1] = {id = playerQueue[p].id, name = playerQueue[p].name, team = 1, delete = false, image = "dissapear", frame = 18}
                playerQueue[p].delete = true
                playerQueue[p].dt = playerButtonMax
                newPlayer = true

              elseif x > 53 + 84 * p and x < 69 + 84 * p and y > 245 and y < 245 + 16 and team2.playerNum < 6 then
                server:send(bin:pack({"join"}), playerQueue[p].id)
                players[#players + 1] = {id = playerQueue[p].id, name = playerQueue[p].name, team = 2, delete = false, image = "dissapear", frame = 18}
                playerQueue[p].delete = true
                playerQueue[p].dt = playerButtonMax
                newPlayer = true

              end
            end
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
    elseif button == 2 then
      if target ~= nil then
        if players[target].id ~= "host" then
          server:send(bin:pack({"disconnect"}), players[target].id)
        end
      end
    end
  end
end

function servermenu_textinput(text)
  if proceed == false then
    if textBox == "port" then
      port = port .. text
    end
  else
    if textBox == "team1" and getPixelWidth(team1.name .. text) < 67 then
      team1.name = team1.name .. text
    elseif textBox == "team2" and getPixelWidth(team2.name .. text) < 67 then
      team2.name = team2.name .. text
    end
  end
end

function servermenu_keypressed(key)
  if proceed == false then
    if key == "backspace" then
      if textBox == "port" then
        port = string.sub(port, 1, -2)
      end
    elseif key == "return" then
      proceed = true
      server = lube.udpServer()
      if port == "" or tonumber(port) == nil then
        server:listen(25565)
      else
        server:listen(tonumber(port))
      end
    end
  else
    if key == "backspace" then
      if textBox == "team1" then
        team1.name = string.sub(team1.name, 1, -2)
      elseif textBox == "team2" then
        team2.name = string.sub(team2.name, 1, -2)
      end
    end
  end
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

function loadPlayerButton (name, frame)
  scrollFrame = frame
  if frame == 1 then
    button = love.graphics.newCanvas(2, 32)
  elseif frame == 2 then
    button = love.graphics.newCanvas(4, 32)
  elseif frame >= 22 then
    button = love.graphics.newCanvas(82, 32)
    scrollFrame = 22
  else
    button = love.graphics.newCanvas(frame * 4 - 4, 32)
  end
  love.graphics.setCanvas(button)
  love.graphics.clear()
  love.graphics.draw(playerButtonImg, playerButton[scrollFrame], button:getWidth() / 2 - 41, 0)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(name, math.floor(button:getWidth() / 2 - getPixelWidth(name) / 2), 5)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(playerButtonImg, playerButtonOverlay[scrollFrame], button:getWidth() / 2 - 41, 0)
  if frame > 22 then
    love.graphics.setColor(guiColor.r, guiColor.g, guiColor.b)
    love.graphics.draw(playerButtonImg, bannerButton[frame - 22], 4, 16)

    love.graphics.setColor(team1.r, team1.g, team1.b)
    love.graphics.draw(playerButtonImg, bannerButton[frame - 22], 46, 16)

    love.graphics.setColor(team2.r, team2.g, team2.b)
    love.graphics.draw(playerButtonImg, bannerButton[frame - 22], 62, 16)

    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(playerButtonImg, deny[frame - 22], 4, 16)
    love.graphics.draw(playerButtonImg, checkmark[frame - 22], 46, 16)
    love.graphics.draw(playerButtonImg, checkmark[frame - 22], 62, 16)

  end
  love.graphics.setCanvas()
  return button

end

function server_quit()
  server:send(bin:pack({"disconnect"}))
end

function servermenu_onConnect(clientid)
  playerAdded = false
  for p = 1, #playerQueue do
    if playerQueue[p] == false then
      playerQueue[p] = {id = clientid, team = 1, delete = false}
      playerAdded = true
      break
    end
  end
  if playerAdded == false then
    playerQueue[#playerQueue + 1] = {id = clientid, team = 1, delete = false}
  end
  server:send(bin:pack({"id", clientid}))
end

function servermenu_onDisconnect(clientid)
  removed = false
  for p = 1, #players do
    if players[p].id == clientid then
      players[p].delete = true
      removed = true
      break
    end
  end
  if removed == false then
    for p = 1, #playerQueue do
      if playerQueue[p].id == clientid then
        playerQueue[p].delete = true
        playerQueue[p].dt = playerButtonMax
        break
      end
    end
  end
end

function servermenu_onReceive(data, clientid)
  data = bin:unpack(data)
  if data["1"] == "name" then
    for p = 1, #playerQueue do
      if playerQueue[p].id == clientid then
        playerQueue[p].name = data["2"]
        break
      end
    end
  end
end
