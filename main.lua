require("middleclass")
require("middleclass-commons")
require("LUBE")
require("Binary")

require("graphics")

require("menu.mainmenu")
require("menu.servermenu")
require("menu.clientmenu")

function love.load()
  graphics_load()
  mainmenu_load()
  scale = {x = love.graphics.getWidth() / 400, y = love.graphics.getHeight() / 300}
  gamestate = "menu"
  totalDt = 0
end

function love.update(dt)
  if gamestate == "menu" then
    mainmenu_update(dt)
  elseif gamestate == "servermenu" then
    servermenu_update(dt)
  elseif gamestate == "clientmenu" then
    clientmenu_update(dt)
  end
  totalDt = totalDt + dt
end

function love.draw()
  love.graphics.push()
  love.graphics.scale(scale.x, scale.y)

  if gamestate == "menu" then
    mainmenu_draw()
  elseif gamestate == "servermenu" then
    servermenu_draw()
  elseif gamestate == "clientmenu" then
    clientmenu_draw()
  end

  love.graphics.pop()
end

function love.mousepressed(x, y, button)
  x = x / scale.x
  y = y / scale.y
  if gamestate == "menu" then
    mainmenu_mousepressed(x, y, button)
  elseif gamestate == "servermenu" then
    servermenu_mousepressed(x, y, button)
  elseif gamestate == "clientmenu" then
    clientmenu_mousepressed(x, y, button)
  end
end

function love.keypressed(key)
  if gamestate == "servermenu" then
    servermenu_keypressed(key)
  elseif gamestate == "clientmenu" then
    clientmenu_keypressed(key)
  end
end

function love.textinput(text)
  if gamestate == "servermenu" then
    servermenu_textinput(text)
  elseif gamestate == "clientmenu" then
    clientmenu_textinput(text)
  end
end

function onConnect(clientid)
  if gamestate == "servermenu" then
    playerQueue[#playerQueue + 1] = {id = clientid, team = 1}
  end
end

function onServerReceive(data, clientid)
  data = bin:unpack(data)
  if data.msg == "name" then
    for p = 1, #playerQueue do
      if playerQueue[p].id == clientid then
        playerQueue[p].name = data.name
        break
      end
    end
  end
end
