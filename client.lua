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
      players[p].y = 465
      players[p].x = (-118 + (playerNum[1] - playerNum[3]) * 10) / (players[p].y / 1600 + 0.5)
      players[p].direction = 1
      playerNum[3] = playerNum[3] + 1
    else
      players[p].y = 465
      players[p].x = (118 + (playerNum[2] - playerNum[4]) * -10) / (players[p].y / 1600 + 0.5)
      players[p].direction = -1
      playerNum[4] = playerNum[4] + 1
    end
    players[p].frame = 1
    animatePlayer(p, 0, 0)
  end

  camera = {x = 200, y = -50}
  avatar = {num = 0, xV = 0, yV = 0}
  oldPos = {x = 0, y = 0}

  if team[1].position == "offense" then
    qb = findQb(1)
  else
    qb = findQb(2)
  end
  targetPos = {}
  gameDt = 0
  otherTeamDelay = 0.5

  down = {num = 1, dt = 0}
  startNewDown = nil
  arrow = {}
  objects = {}
  particles = {}
  arrowShot = false

  --drawing functions
  drawFunction = {function(a, b, c, d, e, f, g, h, i, j, k, l, m) love.graphics.setColor(a, b, c, d) love.graphics.draw(e, f, g, h, i, j, k, l, m) end,
                  function(a, b, c, d, e, f, g, h, i, j, k, l, m) love.graphics.setColor(a, b, c, d) love.graphics.draw(e, g, h, i, j, k, l, m) end,
                  function(a, b, c, d, e, f, g, h, i, j, k, l, m) love.graphics.setColor(a, b, c, d) love.graphics.print(e, g, h) end}
end

function client_update(dt)
  if disconnected == false then
    client:update(dt)
    -- get mouse position and limit it
    mX, mY = adjust(love.mouse.getPosition())
    if mX > 400 then mX = 400 end
    if mX < 0 then mX = 0 end
    if mY > 300 then mY = 300 end
    if mY < 0 then mY = 0 end

    --deserters
    newQb = false
    for p = 1, #players do
      if players[p].delete == true then
        players[p].frame = players[p].frame + dt * 30
        if players[p].frame > 18 then
          if p == qb then
            newQb = true
            newQbTeam = players[p].team
          end
          players[p] = nil
        end
      end
    end
    players = removeNil(players)
    if newQb == true then
      findQb(newQbTeam)
    end

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
      client:send(bin:pack({"coords", identifier, players[avatar.num].x, players[avatar.num].y}))
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
        objects[#objects + 1] = {type = "arrow", x = arrow.targetX, y = arrow.targetY + 16, dt = 0}
        arrow = {}
        startNewDown = 2
      end
    end

    --new down
    if startNewDown ~= nil then
      startNewDown = startNewDown - dt
      if startNewDown <= 0 then
        down.num = down.num + 1
        down.dt = 0
        arrowShot = false

        startNewDown = nil
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
  else
    client:send(bin:pack({"left", identifier}))
    client:disconnect()
    clientmenu_load()
    gamestate = "clientmenu"
    errorMsg = "Kicked by server"
  end
end

function client_draw()
  thingsToDraw = {}

  --draw objects
  for i = 1, #objects do
    if objects[i].type == "arrow" then
      thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255 - (objects[i].dt * 2), img = arrowWobble, quad = arrowWobbleQuad[range(math.floor(objects[i].dt * 50), 1, 11)], x = warpX(objects[i].x, objects[i].y), y = warpY(objects[i].y), rot = 0, sX = 1, zY = 1, oX = 16, oY = 32}
    end
  end

  -- draw players
  for p = 1, #players do
    char = drawChar(players[p].image, players[p].frame)
    thingsToDraw[#thingsToDraw + 1] = {type = 2, r = 255, g = 255, b = 255, a = 255, img = charShadow, quad = 0, x = warpX(players[p].x, players[p].y), y = warpY(players[p].y) - 1, rot = 0, sX = 1, sY = 1, oX = 16, oY = 15}
    thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255, img = char[1], quad = char[2], x = warpX(players[p].x, players[p].y), y = warpY(players[p].y), rot = 0, sX = players[p].direction, sY = 1, oX = 16, oY = 32}
    thingsToDraw[#thingsToDraw + 1] = {type = 1, r = team[players[p].team].r, g = team[players[p].team].g, b = team[players[p].team].b, a = 255, img = char[3], quad = char[4], x = warpX(players[p].x, players[p].y), y = warpY(players[p].y) + 1, rot = 0, sX = players[p].direction, sY = 1, oX = 16, oY = 33}
    thingsToDraw[#thingsToDraw + 1] = {type = 3, r = team[players[p].team].r, g = team[players[p].team].g, b = team[players[p].team].b, a = 255, img = players[p].name, quad = 0, x = warpX(players[p].x, players[p].y) - getPixelWidth(players[p].name) / 2, y = warpY(players[p].y) - 48, rot = 0, sX = 0, sY = 0, oX = 0, oY = 0}
  end

  -- draw qb targetPos
  if targetPos[#targetPos] ~= nil then
    if players[avatar.num].team == players[qb].team then
      thingsToDraw[#thingsToDraw + 1] = {type = 2, r = team[players[qb].team].r, g = team[players[qb].team].g, b = team[players[qb].team].b, a = 255, img = arrowTarget, quad = 0, x = warpX(targetPos[#targetPos][1], targetPos[#targetPos][2]), y = warpY(targetPos[#targetPos][2]), rot = 0, sX = range(down.dt, 0, 1), sY = range(down.dt, 0, 1), oX = 16, oY = 8}
    else
      for i = 1, #targetPos do
        if targetPos[i + 1] ~= nil then
          if math.abs(targetPos[i][3] - (gameDt - otherTeamDelay)) < math.abs(targetPos[i + 1][3] - (gameDt - otherTeamDelay)) then
            thingsToDraw[#thingsToDraw + 1] = {type = 2, r = team[players[qb].team].r, g = team[players[qb].team].g, b = team[players[qb].team].b, a = 255, img = arrowTarget, quad = 0, x = warpX(targetPos[i][1], targetPos[i][2]), y = warpY(targetPos[i][2]), rot = 0, sX = range(down.dt - otherTeamDelay, 0, 1), sY = range(down.dt - otherTeamDelay, 0, 1), oX = 16, oY = 8}
            break
          end
        else
          break
        end
      end
    end
  end

  -- draw arrow
  if arrow.currentX ~= nil and arrow.currentY ~= nil then
    thingsToDraw[#thingsToDraw + 1] = {type = 2, r = 255, g = 255, b = 255, a = 255, img = arrowImg, quad = 0, x = warpX(arrow.currentX, arrow.currentY), y = warpY(arrow.currentY) + arrow.z - 16, rot = arrow.angle, sX = 1, sY = 1, oX = 16, oY = 16}
  end

  sort(thingsToDraw)

  -- acutally drawing
  love.graphics.push()
  love.graphics.translate(camera.x, camera.y)
  love.graphics.draw(fieldImg, -1000, -100)

  for i = 1, #thingsToDraw do
    drawFunction[thingsToDraw[i].type](thingsToDraw[i].r, thingsToDraw[i].g, thingsToDraw[i].b, thingsToDraw[i].a, thingsToDraw[i].img, thingsToDraw[i].quad, thingsToDraw[i].x, thingsToDraw[i].y, thingsToDraw[i].rot, thingsToDraw[i].sX, thingsToDraw[i].sY, thingsToDraw[i].oX, thingsToDraw[i].oY)
  end
  love.graphics.setColor(255, 255, 255)


  love.graphics.pop()
end

function client_mousepressed(x, y, button)
  if button == 1 then
    if qb == avatar.num and arrow.currentX == nil and arrow.currentY == nil and arrowShot == false then
      arrowTargetX, arrowTargetY = (players[avatar.num].x + math.floor(x) - 200), (players[avatar.num].y + math.floor(y) - 150)
      client:send(bin:pack({"arrow", arrowTargetX, arrowTargetY}))
      arrow = {oldX = players[avatar.num].x, oldY = players[avatar.num].y, startX = players[avatar.num].x, startY = players[avatar.num].y, currentX = players[avatar.num].x, currentY = players[avatar.num].y, theta = math.atan2(arrowTargetY - players[avatar.num].y, arrowTargetX - players[avatar.num].x), r = 0, targetX = arrowTargetX, targetY = arrowTargetY, z = 0, angle = 0}
      arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
      arrowShot = true
    end
  end
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
          animatePlayer(p, tempXV, tempYV)
          break
        end
      end
    end
  elseif data["1"] == "target" then
    if qb ~= avatar.num then
      targetPos[#targetPos + 1] = {data["2"], data["3"], data["4"]}
      if #targetPos > 200 then
        targetPos[1] = nil
      end
      targetPos = removeNil(targetPos)
    end
  elseif data["1"] == "arrow" then
    if qb ~= avatar.num then
      arrow = {oldX = players[qb].x, oldY = players[qb].y, startX = players[qb].x, startY = players[qb].y, currentX = players[qb].x, currentY = players[qb].y, theta = math.atan2(data["3"] - players[qb].y, data["2"] - players[qb].x), r = 0, targetX = data["2"], targetY = data["3"], z = 0, angle = 0}
      arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
      arrowShot = true
    end
  elseif data["1"] == "disconnect" then
    if data["2"] == identifier or data["2"] == "all" then
      disconnected = true
    end
  elseif data["1"] == "left" then
    for p = 1, #players do
      if players[p].id == data["2"] then
          players[p].delete = true
          players[p].image = "dissapear"
          players[p].frame = 1
        break
      end
    end
  end
end
