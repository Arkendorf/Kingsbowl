require("middleclass")
require("middleclass-commons")
require("LUBE")
require("Binary")
require("sort")

require("graphics")

require("menu.mainmenu")
require("menu.servermenu")
require("menu.clientmenu")
require("menu.pausemenu")

require("client")
require("server")

function love.load()
  math.randomseed(os.time())
  graphics_load()
  mainmenu_load()
  pausemenu_load()
  scaleFactor = 2
  scale = {x = love.graphics.getWidth() / 800 * scaleFactor, y = love.graphics.getHeight() / 600 * scaleFactor}
  offset = {x = (love.graphics.getWidth() - 400  * scaleFactor) / 2, y = (love.graphics.getHeight() - 300  * scaleFactor) / 2}
  gamestate = "menu"
  totalDt = 0
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)
  pause = false
  mainScreen = love.graphics.newCanvas(400, 300)
end

function love.update(dt)
  if gamestate == "menu" then
    mainmenu_update(dt)
  elseif gamestate == "servermenu" then
    servermenu_update(dt)
  elseif gamestate == "clientmenu" then
    clientmenu_update(dt)
  elseif gamestate == "server" then
    server_update(dt)
  elseif gamestate == "client" then
    client_update(dt)
  end
  if pause == true then
    pausemenu_update(dt)
  end
  totalDt = totalDt + dt
end

function love.draw()
  love.graphics.setCanvas(mainScreen)
  love.graphics.clear()

  if pause == false then
    if gamestate == "menu" then
      mainmenu_draw()
    elseif gamestate == "servermenu" then
      servermenu_draw()
    elseif gamestate == "clientmenu" then
      clientmenu_draw()
    elseif gamestate == "server" then
      server_draw()
    elseif gamestate == "client" then
      client_draw()
    end
  else
    pausemenu_draw()
  end

  love.graphics.setCanvas()
  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)
  love.graphics.scale(scale.x, scale.y)

  love.graphics.draw(mainScreen)

  love.graphics.pop()
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
  elseif gamestate == "server" then
    server_mousepressed(x, y, button)
  elseif gamestate == "client" then
    client_mousepressed(x, y, button)
  end
end

function love.keypressed(key)
  if gamestate == "servermenu" then
    servermenu_keypressed(key)
  elseif gamestate == "clientmenu" then
    clientmenu_keypressed(key)
  end
  if key == "escape" then
    if pause == true then
      pause = false
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
  if gamestate == "clientmenu" or gamestate == "client" then
    client_quit()
  elseif gamestate == "servermenu" or gamestate == "server" then
    server_quit()
  end
end

function adjust(x, y)
  return (x - offset.x) / scale.x, (y - offset.y) / scale.y
end

function onConnect(clientid)
  if gamestate == "servermenu" then
    servermenu_onConnect(clientid)
  elseif gamestate == "server" then
    server_onConnect(clientid)
  end
end

function onServerReceive(data, clientid)
  if gamestate == "servermenu" then
    servermenu_onReceive(data, clientid)
  elseif gamestate == "server" then
    server_onReceive(data, clientid)
  end
end

function onDisconnect(clientid)
  if gamestate == "servermenu" then
    servermenu_onDisconnect(clientid)
  elseif gamestate == "server" then
    server_onDisconnect(clientid)
  end
end

function onClientReceive(data)
  if gamestate == "clientmenu" then
    clientmenu_onReceive(data)
  elseif gamestate == "client" then
    client_onReceive(data)
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
    return {grabShield, grabShieldQuad[math.ceil(range(frame, 1, 14))], grabShieldOverlay, grabShieldOverlayQuad[math.ceil(range(frame, 1, 14))]}
  elseif image == "runSword" then
    return {runSword, runSwordQuad[math.ceil(range(frame, 1, 8))], runSwordOverlay, runSwordOverlayQuad[math.ceil(range(frame, 1, 8))]}
  elseif image == "runShield" then
    return {runShield, runShieldQuad[math.ceil(range(frame, 1, 8))], runShieldOverlay, runShieldOverlayQuad[math.ceil(range(frame, 1, 8))]}
  end
end
