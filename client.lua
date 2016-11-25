function client_load()
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
    oldPos = {x = 0, y = 0}
  end

  camera = {x = 0, y = 400}
  avatar = {num = 0, xV = 0, yV = 0}
end

function client_update(dt)
  client:update(dt)
  -- get mouse position and limit it
  mX, mY = adjust(love.mouse.getPosition())
  if mX > 400 then mX = 400 end
  if mX < 0 then mX = 0 end
  if mY > 300 then mY = 300 end
  if mY < 0 then mY = 0 end

  -- find which player is the "avatar"
  for p = 1, #players do
    if players[p].id == identifier then
      avatar.num = p
      break
    end
  end

  -- move player
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
  -- confine player to field
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

  -- send coords if change is detected
  if players[avatar.num].x ~= oldPos.x or players[avatar.num].y ~= oldPos.y then
    client:send(bin:pack{"coords", players[avatar.num].x, players[avatar.num].y})
    oldPos.x, oldPos.y = players[avatar.num].x, players[avatar.num].y
  end

  -- set camera position
  if math.abs((players[avatar.num].x +  warpX(mX - 200, players[avatar.num].y)) - camera.x) > 10 then
    camera.x = camera.x + (warpX((players[avatar.num].x +  warpX(mX - 200, players[avatar.num].y)), (players[avatar.num].y + mY - 150)) - warpX(camera.x, camera.y)) * 0.5
  else
    camera.x = (players[avatar.num].x +  warpX(mX - 200, players[avatar.num].y))
  end
  if math.abs((players[avatar.num].y + mY - 150) - camera.y) > 10 then
    camera.y = camera.y + (warpY((players[avatar.num].y + mY - 150)) - warpY(camera.y)) * 0.5
  else
    camera.y = (players[avatar.num].y + mY - 150)
  end
end

function client_draw()
  love.graphics.push()
  love.graphics.translate(warpX(-1 * camera.x, camera.y) + 200, warpY(-1 * camera.y) + 150)
  love.graphics.draw(fieldImg, -1000, -100)

  -- draw players
  for p = 1, #players do
    char = drawChar(players[p].image, players[p].frame)
    love.graphics.draw(charShadow, warpX(players[p].x, players[p].y), warpY(players[p].y) + 16, 0, 1, 1, 16, 16)
    love.graphics.draw(char[1], char[2], warpX(players[p].x, players[p].y), warpY(players[p].y), 0, players[p].direction, 1, 16, 16)
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
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(tostring(identifier))
  love.graphics.setColor(255, 255, 255)
end

function client_onReceive(data)
  data = bin:unpack(data)
  if data["1"] == "coords" then
    for p = 1, #players do
      if players[p].id == data["2"] then
        if data["3"] - players[p].x > 0 and players[p].direction == -1 then
          players[p].direction = 1
        elseif data["3"] - players[p].x < 0 and players[p].direction == 1 then
          players[p].direction = -1
        end
        players[p].x = data["3"]
        players[p].y = data["4"]
        break
      end
    end
  end
end
