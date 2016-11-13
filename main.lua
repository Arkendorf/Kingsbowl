require("middleclass")
require("middleclass-commons")
require("LUBE")
require("Binary")

require("graphics")

require("menu.mainmenu")
require("menu.servermenu")
require("menu.clientmenu")
require("menu.pausemenu")

function love.load()
  math.randomseed(os.time())
  graphics_load()
  mainmenu_load()
  pausemenu_load()
  scaleFactor = 2
  adjustScreen()
  totalDt = 0
  pause = false
  gamestate = "menu"
end

function love.update(dt)
  if gamestate == "menu" then
    mainmenu_update(dt)
  elseif gamestate == "servermenu" then
    servermenu_update(dt)
  elseif gamestate == "clientmenu" then
    clientmenu_update(dt)
  end
  if pause == true then
    pausemenu_update(dt)
  end
  totalDt = totalDt + dt
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)
  love.graphics.scale(scale.x, scale.y)

  if pause == false then
    if gamestate == "menu" then
      mainmenu_draw()
    elseif gamestate == "servermenu" then
      servermenu_draw()
    elseif gamestate == "clientmenu" then
      clientmenu_draw()
    end
  else
    pausemenu_draw()
  end

  love.graphics.pop()

  -- fullscreen borders
  if love.window.getFullscreen() == true then
    love.graphics.rectangle("fill", 0, 0, offset.x, screenH)
    love.graphics.rectangle("fill", screenW - offset.x, 0, offset.x, screenH)
    love.graphics.rectangle("fill", 0, 0, screenW, offset.y)
    love.graphics.rectangle("fill", 0, screenH - offset.y, screenW, offset.y)
  end
end

function love.mousepressed(x, y, button)
  x, y = adjust(x, y)
  if pause == true then
    pausemenu_mousepressed(x, y, button)
  elseif gamestate == "menu" then
    mainmenu_mousepressed(x, y, button)
  elseif gamestate == "servermenu" then
    servermenu_mousepressed(x, y, button)
  elseif gamestate == "clientmenu" then
    clientmenu_mousepressed(x, y, button)
  end
end

function love.keypressed(key)
  if pause == false then
    if gamestate == "servermenu" then
      servermenu_keypressed(key)
    elseif gamestate == "clientmenu" then
      clientmenu_keypressed(key)
    end
  end
  if key == "escape" then
    if pause == true then
      pause = false
      screentype.state = false
      refresh = true
    else
      pause = true
    end
  end
end

function love.textinput(text)
  if gamestate == "servermenu" then
    servermenu_textinput(text)
  elseif gamestate == "clientmenu" then
    clientmenu_textinput(text)
  end
end

function love.quit()
  if gamestate == "clientmenu" then
    client_quit()
  elseif gamestate == "servermenu" then
    server_quit()
  end
end

function adjust(x, y)
  return (x - offset.x) / scale.x, (y - offset.y) / scale.y
end

function onConnect(clientid)
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
end

function onServerReceive(data, clientid)
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

function onDisconnect(clientid)
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

function onClientReceive(data)
  data = bin:unpack(data)
  if data["1"] == "disconnect" then
    client:disconnect()
    clientmenu_load()
    errorMsg = "Kicked by server"
  elseif data["1"] == "join" then
    accepted = true
  elseif data["1"] == "teams" then
    team1 = {name = data["2"], r = data["3"], g = data["4"], b = data["5"]}
    team2 = {name = data["6"], r = data["7"], g = data["8"], b = data["9"]}
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
  end
end

function drawChar(image, frame)
  if image == "prep" then
    return {prep, prepQuad[math.ceil(range(frame, 1, 6))], prepOverlay, prepOverlayQuad[math.ceil(range(frame, 1, 6))]}
  elseif image == "dissapear" then
    return {dissapear, dissapearQuad[math.ceil(range(frame, 1, 18))], dissapearOverlay, dissapearOverlayQuad[math.ceil(range(frame, 1, 18))]}
  elseif image == "switch1" or image == "switch2" then
    return {switch, switchQuad[math.ceil(range(frame, 1, 22))], switchOverlay, switchOverlayQuad[math.ceil(range(frame, 1, 22))]}
  elseif image == "unsheathSword" then
    return {unsheathSword, unsheathSwordQuad[math.ceil(range(frame, 1, 14))], unsheathSwordOverlay, unsheathSwordOverlayQuad[math.ceil(range(frame, 1, 14))]}
  elseif image == "grabShield" then
    return {grabShield, grabShieldQuad[math.ceil(range(frame, 1, 14))], switchOverlay, switchOverlayQuad[math.ceil(range(frame, 1, 22))]}
  end
end
