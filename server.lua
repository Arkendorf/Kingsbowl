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

  camera = {x = 200, y = -50}
  avatar = {num = 0, xV = 0, yV = 0}
  oldPos = {x = 0, y = 0}

  qb = 2
  targetPos = {}
  gameDt = 0
  otherTeamDelay = 0.5

  down = {num = 1, dt = 0}
  arrow = {}
  objects = {}
  particles = {}
  arrowShot = false
end

function server_update(dt)
  server:update(dt)
  -- get mouse position and limit it
  mX, mY = adjust(love.mouse.getPosition())
  if mX > 400 then mX = 400 end
  if mX < 0 then mX = 0 end
  if mY > 300 then mY = 300 end
  if mY < 0 then mY = 0 end

  -- find which player is the "avatar"
  for p = 1, #players do
    if players[p].id == 1 then
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
    avatar.xV = 0
  elseif players[avatar.num].x < -900 then
    players[avatar.num].x = -900
    avatar.xV = 0
  end
  if players[avatar.num].y > 800 then
    players[avatar.num].y = 800
    avatar.yV = 0
  elseif players[avatar.num].y < 0 then
    players[avatar.num].y = 0
    avatar.yV = 0
  end

  --animate avatar
  animatePlayer(avatar.num, avatar.xV, avatar.yV)

  avatar.xV = avatar.xV * 0.4
  avatar.yV = avatar.yV * 0.4

  -- send coords if change is detected
  if players[avatar.num].x ~= oldPos.x or players[avatar.num].y ~= oldPos.y then
    server:send(bin:pack({"coords", 1, players[avatar.num].x, players[avatar.num].y}))
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
    server:send(bin:pack({"target", qbTargetX, qbTargetY, gameDt}))
    targetPos[#targetPos + 1] = {qbTargetX, qbTargetY, gameDt}
    if #targetPos > 200 then
      targetPos[1] = nil
    end
    targetPos = removeNil(targetPos)
  end

  if arrow.currentX ~= nil and arrow.currentY ~= nil then
    arrow.oldX = arrow.currentX
    arrow.oldY = arrow.currentY
    arrow.oldZ = arrow.z
    local distance = math.sqrt((arrow.targetX - arrow.currentX) * (arrow.targetX - arrow.currentX) + (arrow.targetY - arrow.currentY) * (arrow.targetY - arrow.currentY))
    if distance >= 5 then
      arrow.r = arrow.r + 5
      arrow.currentX = arrow.startX + arrow.r * math.cos(arrow.theta)
      arrow.currentY = arrow.startY + arrow.r * math.sin(arrow.theta)
      if arrow.theta > 180 then
        arrow.z = (((arrow.distance / 2 - arrow.r) * (arrow.distance / 2 - arrow.r)) * -1 + ((arrow.distance / 2) * (arrow.distance / 2))) / 200
      else
        arrow.z = (((arrow.distance / 2 - arrow.r) * (arrow.distance / 2 - arrow.r)) - ((arrow.distance / 2) * (arrow.distance / 2))) / 200
      end
      arrow.angle = math.atan2((arrow.currentY + arrow.z) - (arrow.oldY + arrow.oldZ), arrow.currentX - arrow.oldX)
    else
      objects[#objects + 1] = {type = "arrow", x = arrow.targetX, y = arrow.targetY, dt = 0}
      arrow = {}
    end
  end

  --objects
  for i = 1, #objects do
    if objects[i].type == "arrow" then
      objects[i].dt = objects[i].dt + dt
      if objects[i].dt > 127.5 then
        objects[i] = nil
      end
    end
  end
  objects = removeNil(objects)

  gameDt = gameDt + dt
  --temporary downDt
  down.dt = gameDt
end

function server_draw()
  love.graphics.push()
  love.graphics.translate(camera.x, camera.y)
  love.graphics.draw(fieldImg, -1000, -100)

  --draw objects
  for i = 1, #objects do
    if objects[i].type == "arrow" then
      love.graphics.setColor(255, 255, 255, 255 - (objects[i].dt * 2))
      love.graphics.draw(arrowWobble, arrowWobbleQuad[range(math.floor(objects[i].dt * 50), 1, 11)], warpX(objects[i].x, objects[i].y), warpY(objects[i].y), 0, 1, 1, 16, 32)
      love.graphics.setColor(255, 255, 255, 255)
    end
  end

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
            love.graphics.draw(arrowTarget, warpX(targetPos[i][1], targetPos[i][2]), warpY(targetPos[i][2]), 0, range(down.dt - otherTeamDelay, 0, 1), range(down.dt - otherTeamDelay, 0, 1), 16, 8)
            break
          end
        else
          break
        end
      end
    end
  end
  love.graphics.setColor(255, 255, 255)

  -- draw arrow
  if arrow.currentX ~= nil and arrow.currentY ~= nil then
    love.graphics.draw(arrowImg, warpX(arrow.currentX, arrow.currentY), warpY(arrow.currentY) + arrow.z, arrow.angle, 1, 1, 16, 16)
  end

  love.graphics.pop()
end

function server_mousepressed(x, y, button)
  if button == 1 then
    if qb == avatar.num and arrow.currentX == nil and arrow.currentY == nil and arrowShot == false then
      arrowTargetX, arrowTargetY = (players[avatar.num].x + math.floor(x) - 200), (players[avatar.num].y + math.floor(y) - 150)
      server:send(bin:pack({"arrow", arrowTargetX, arrowTargetY}))
      arrow = {oldX = players[avatar.num].x, oldY = players[avatar.num].y, startX = players[avatar.num].x, startY = players[avatar.num].y, currentX = players[avatar.num].x, currentY = players[avatar.num].y, theta = math.atan2(arrowTargetY - players[avatar.num].y, arrowTargetX - players[avatar.num].x), r = 0, targetX = arrowTargetX, targetY = arrowTargetY, z = 0, angle = 0}
      arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
      arrowShot = true
    end
  end
end

function server_onConnect(clientid)
  server:send(bin:pack({"late"}))
end

function server_onDisconnect(clientid)
end

function server_onReceive(data, clientid)
  data = bin:unpack(data)
  if data["1"] == "coords" then
    server:send(bin:pack({"coords", data["2"], data["3"], data["4"]}))
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
        animatePlayer(p, tempXV, tempYV)
        break
      end
    end
  elseif data["1"] == "target" then
    server:send(bin:pack(data))
    targetPos[#targetPos + 1] = {data["2"], data["3"], data["4"]}
    if #targetPos > 200 then
      targetPos[1] = nil
    end
    targetPos = removeNil(targetPos)
  elseif data["1"] == "arrow" then
    server:send(bin:pack(data))
    arrow = {oldX = players[qb].x, oldY = players[qb].y, startX = players[qb].x, startY = players[qb].y, currentX = players[qb].x, currentY = players[qb].y, theta = math.atan2(data["3"] - players[qb].y, data["2"] - players[qb].x), r = 0, targetX = data["2"], targetY = data["3"], z = 0, angle = 0}
    arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
    arrowShot = true
  elseif data["1"] == "disconnect" then
    for p = 1, #players do
      if players[p].id == data["2"] then

        break
      end
    end
  end
end

-- adjust coordinates to fit perspective
function warpX(x, y)
  return math.floor(x * (y / 1600 + 0.5))
end

function warpY(y)
  return math.floor(y / 2)
end

function animatePlayer(p, xV, yV)
  local teamPos = team[players[p].team].position
  if math.abs(xV) > 0.1 or math.abs(yV) > 0.1 then
    if teamPos == "offense" then
      players[p].image = "runShield"
    elseif teamPos == "defense" then
      players[p].image = "runSword"
    end
    if math.abs(xV) > math.abs(yV) then
      players[p].frame = loop(players[p].frame + math.abs(xV) / 2, 8)
    else
      players[p].frame = loop(players[p].frame + math.abs(yV) / 2, 8)
    end
  else
    if teamPos == "offense" then
      players[p].image = "grabShield"
    elseif teamPos == "defense" then
      players[p].image = "unsheathSword"
    end
    players[p].frame = 14
  end
end
