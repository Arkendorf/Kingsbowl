function server_load()
  -- initial positions
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
      players[p].x = (-125 + (playerNum[1] - playerNum[3]) * 10) * 1.25
      players[p].y = 433
      players[p].direction = 1
      playerNum[3] = playerNum[3] + 1
    else
      players[p].x = (125 + (playerNum[2] - playerNum[4]) * -10) * 1.25
      players[p].y = 433
      players[p].direction = -1
      playerNum[4] = playerNum[4] + 1
    end
  end

  camera = {x = 0, y = 400}
  avatar = {num = 0, xV = 0, yV = 0}
end

function server_update(dt)
  mX, mY = adjust(love.mouse.getPosition())
  if mX > 400 then mX = 400 end
  if mX < 0 then mX = 0 end
  if mY > 300 then mY = 300 end
  if mY < 0 then mY = 0 end


  for p = 1, #players do
    if players[p].id == "host" then
      avatar.num = p
      break
    end
  end
  if love.keyboard.isDown("d") then
    avatar.xV = avatar.xV + 1
  end
  if love.keyboard.isDown("a") then
    avatar.xV = avatar.xV - 1
  end
  if love.keyboard.isDown("w") then
    avatar.yV = avatar.yV - 1
  end
  if love.keyboard.isDown("s") then
    avatar.yV = avatar.yV + 1
  end
  players[avatar.num].x = players[avatar.num].x + avatar.xV
  players[avatar.num].y = players[avatar.num].y + avatar.yV
  if avatar.xV > 0 and players[avatar.num].direction == -1 then
    players[avatar.num].direction = 1
  elseif avatar.xV < 0 and players[avatar.num].direction == 1 then
    players[avatar.num].direction = -1
  end
  if players[avatar.num].x > 900 then
    players[avatar.num].x = 900
  elseif players[avatar.num].x < -900 then
    players[avatar.num].x = -900
  end
  if players[avatar.num].y > 800 then
    players[avatar.num].y = 800
  elseif players[avatar.num].y < 0 then
    players[avatar.num].y = 0
  end

  avatar.xV = avatar.xV * 0.4
  avatar.yV = avatar.yV * 0.4

  if math.abs((players[avatar.num].x + mX - 200) - camera.x) > 10 then
    camera.x = camera.x + (warpX((players[avatar.num].x + mX - 200), (players[avatar.num].y + mY - 150)) - warpX(camera.x, camera.y)) * 0.5
  else
    camera.x = (players[avatar.num].x + mX - 200)
  end
  if math.abs((players[avatar.num].y + mY - 150) - camera.y) > 10 then
    camera.y = camera.y + (warpY((players[avatar.num].y + mY - 150)) - warpY(camera.y)) * 0.5
  else
    camera.y = (players[avatar.num].y + mY - 150)
  end
end

function server_draw()
  love.graphics.push()
  love.graphics.translate(warpX(-1 * camera.x, camera.y) + 200, warpY(-1 * camera.y) + 150)
  love.graphics.draw(fieldImg, -900, 0)

  for p = 1, #players do
    char = drawChar(players[p].image, players[p].frame)
    love.graphics.draw(char[1], char[2],warpX(players[p].x, players[p].y), warpY(players[p].y), 0, players[p].direction, 1, 16, 16)
    if players[p].team == 1 then
      love.graphics.setColor(team1.r, team1.g, team1.b)
    else
      love.graphics.setColor(team2.r, team2.g, team2.b)
    end
    love.graphics.draw(char[3], char[4], warpX(players[p].x, players[p].y), warpY(players[p].y), 0, players[p].direction, 1, 16, 16)
    love.graphics.print(players[p].name, warpX(players[p].x, players[p].y) - getPixelWidth(players[p].name) / 2, warpY(players[p].y) - 32)
    love.graphics.setColor(255, 255, 255)
  end

  love.graphics.pop()
  love.graphics.setColor(0, 0,0)
  love.graphics.print(tostring(camera.x))
  love.graphics.print(tostring(camera.y), 0, 16)
  love.graphics.setColor(255, 255, 255)
end

function server_onConnect(clientid)
end

function server_onDisconnect(clientid)
end

function server_onReceive(data, clientid)
end

function warpX(x, y)
  return x * (y / 1600 + 0.5)
end

function warpY(y)
  return y / 2
end
