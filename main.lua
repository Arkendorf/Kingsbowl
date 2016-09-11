require("middleclass")
require("middleclass-commons")
require("LUBE")
require("Binary")

require("graphics")

require("menu.mainmenu")
require("menu.servermenu")

function love.load()
  graphics_load()
  scale = {x = love.graphics.getWidth() / 400, y = love.graphics.getHeight() / 300}
  gamestate = "menu"
  mainmenu_load()
  totalDt = 0
end

function love.update(dt)
  if gamestate == "menu" then
    mainmenu_update(dt)
  elseif gamestate == "servermenu" then
    servermenu_update(dt)
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
  end

end

function onConnect(clientid)
  if gamestate == "servermenu" then
    team1.playerNum = team1.playerNum + 1
    players[#players + 1] = {id = clientid, team = 1}
  end
end