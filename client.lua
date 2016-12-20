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

  camera = {x = 200, y = -50}
  avatar = {num = 0, xV = 0, yV = 0}

  qb = 1
  targetPos = {}
  gameDt = 0
  otherTeamDelay = 2

  down = {num = 1, dt = 0}
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
    avatar.xV = avatar.xV + dt * 30
  end
  if love.keyboard.isDown("a") then
    avatar.xV = avatar.xV - dt * 30
  end
  if love.keyboard.isDown("w") then
    avatar.yV = avatar.yV - dt * 30
  end
  if love.keyboard.isDown("s") then
    avatar.yV = avatar.yV + dt * 30
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

  --animate avatar
  animatePlayer(avatar.num, avatar.xV, avatar.yV)

  avatar.xV = avatar.xV * 0.4
  avatar.yV = avatar.yV * 0.4

  -- send coords if change is detected
  if players[avatar.num].x ~= oldPos.x or players[avatar.num].y ~= oldPos.y then
    client:send(bin:pack({"coords", players[avatar.num].x, players[avatar.num].y}))
    oldPos.x, oldPos.y = players[avatar.num].x, players[avatar.num].y

  end

  -- set camera position
  if math.abs((-1 * warpX(players[avatar.num].x, players[avatar.num].y) - math.floor(mX) + 400) - camera.x) > 1 then
    camera.x = camera.x + ((-1 * warpX(players[avatar.num].x, players[avatar.num].y) - math.floor(mX) + 400) - camera.x) * 0.4
  else
    camera.x = -1 * warpX(players[avatar.num].x, players[avatar.num].y) - math.floor(mX) + 400
  end
  if math.abs((warpY(-1 * players[avatar.num].y) - math.floor(mY) + 300) - camera.y) > 1 then
    camera.y = camera.y + ((warpY(-1 * players[avatar.num].y) - math.floor(mY) + 300) - camera.y) * 0.4
  else
    camera.y = warpY(-1 * players[avatar.num].y) - math.floor(mY) + 300
  end

  --quarterback's target
  if avatar.num == qb then
    qbTargetX, qbTargetY = (players[avatar.num].x + math.floor(mX) - 200), (players[avatar.num].y + math.floor(mY) - 150)
    client:send(bin:pack({"target", qbTargetX, qbTargetY, gameDt}))
    targetPos[#targetPos + 1] = {qbTargetX, qbTargetY, gameDt}
    if #targetPos > 200 then
      targetPos[1] = nil
    end
    targetPos = removeNil(targetPos)
  end

  gameDt = gameDt + dt
  --temporary downDt
  down.dt = gameDt
end

function client_draw()
  love.graphics.push()
  love.graphics.translate(camera.x, camera.y)
  love.graphics.draw(fieldImg, -1000, -100)

  -- draw players
  for p = 1, #players do
    char = drawChar(players[p].image, players[p].frame)
    love.graphics.draw(charShadow, warpX(players[p].x, players[p].y), warpY(players[p].y) + 16, 0, 1, 1, 16, 16)
    love.graphics.draw(char[1], char[2], warpX(players[p].x, players[p].y), warpY(players[p].y), 0, players[p].direction, 1, 16, 16)
    if players[p].team == 1 then
      love.graphics.setColor(team[1].r, team[1].g, team[1].b)
    else
      love.graphics.setColor(team[2].r, team[2].g, team[2].b)
    end
    love.graphics.draw(char[3], char[4], warpX(players[p].x, players[p].y), warpY(players[p].y), 0, players[p].direction, 1, 16, 16)
    love.graphics.print(players[p].name, warpX(players[p].x, players[p].y) - getPixelWidth(players[p].name) / 2, warpY(players[p].y) - 32)
    love.graphics.setColor(255, 255, 255)
  end

  -- draw qb targetPos
  if players[qb].team == 1 then
    love.graphics.setColor(team[1].r, team[1].g, team[1].b)
  else
    love.graphics.setColor(team[2].r, team[2].g, team[2].b)
  end
  if targetPos[#targetPos] ~= nil then
    if players[avatar.num].team == players[qb].team then
      love.graphics.draw(arrowTarget, warpX(targetPos[#targetPos][1], targetPos[#targetPos][2]), warpY(targetPos[#targetPos][2]), 0, range(down.dt, 0, 1), range(down.dt, 0, 1), 16, 8)
    else
      for i = 1, #targetPos do
        if targetPos[i + 1] ~= nil then
          if math.abs(targetPos[i][3] - (gameDt - otherTeamDelay)) < math.abs(targetPos[i + 1][3] - (gameDt - otherTeamDelay)) then
            love.graphics.draw(arrowTarget, warpX(targetPos[i][1], targetPos[i][2]), warpY(targetPos[i][2]), 0, range(down.dt - 2, 0, 1), range(down.dt - 2, 0, 1), 16, 8)
            break
          end
        else
          break
        end
      end
    end
  end
  love.graphics.setColor(255, 255, 255)

  love.graphics.pop()
end

function client_onReceive(data)
  data = bin:unpack(data)
  if data["1"] == "coords" then
    if data["2"] ~= identifier then
      for p = 1, #players do
        if players[p].id == data["2"] then
          local tempXV = data["3"] - players[p].x
          local tempYV = data["4"] - players[p].y
          players[p].x = data["3"]
          players[p].y = data["4"]
          if tempXV > 0 and players[p].direction == -1 then
            players[p].direction = 1
          elseif tempXV < 0 and players[p].direction == 1 then
            players[p].direction = -1
          end

          -- animate player
          animatePlayer(p, tempXV, tempYV)
          break
        end
      end
    end
  elseif data["1"] == "target" then
    if qb ~= avatar.num and #targetPos > 0 then
      targetPos[#targetPos + 1] = {data["2"], data["3"], data["4"]}
      if #targetPos > 200 then
        targetPos[1] = nil
      end
      targetPos = removeNil(targetPos)
    end
  end
end
