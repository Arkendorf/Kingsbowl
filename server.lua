function server_load()
  love.graphics.setLineWidth(3)
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
    players[p].action = 0
    players[p].frame = 1
    players[p].pause = 0
    animatePlayer(p, 0, 0)
  end

  camera = {x = 200, y = -50}
  avatar = {num = 0, xV = 0, yV = 0}

  if team[1].position == "offense" then
    qb = findQb(1)
  else
    qb = findQb(2)
  end
  possesion = qb
  newQb = false
  newQbTeam = 1
  targetPos = {}
  targetSize = 0
  currentTarget = 1
  gameDt = 0
  otherTeamDelay = 0.5

  down = {num = 1, dt = 0, scrim = 0}
  down.goal = findGoal()
  startNewDown = nil
  startAnnounce = {false, false, false}
  timeTillStart = 5
  newDownBuffer = 2
  arrow = {}
  objects = {}
  particles = {}
  arrowShot = false

  --drawing functions
  drawFunction = {function(a, b, c, d, e, f, g, h, i, j, k, l, m, o) love.graphics.setColor(a, b, c, d) love.graphics.draw(e, f, g, h + i, j, k, l, m, o) end,
                  function(a, b, c, d, e, f, g, h, i, j, k, l, m, o) love.graphics.setColor(a, b, c, d) love.graphics.draw(e, g, h + i, j, k, l, m, o) end,
                  function(a, b, c, d, e, f, g, h, i, j, k, l, m, o) love.graphics.setColor(a, b, c, d) love.graphics.print(e, g, h + i) end}

  message = {}
  messageDeleteSpeed = 20
  turnover = false

  scoreboard = {0, 0}
end

function server_update(dt)
  server:update(dt)
  -- get mouse position and limit it
  mX, mY = adjust(love.mouse.getPosition())
  if mX > 400 then mX = 400 end
  if mX < 0 then mX = 0 end
  if mY > 300 then mY = 300 end
  if mY < 0 then mY = 0 end

  --deserters
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


  --end game if one team has no players
  local team1Good = false
  local team2Good = false
  for p = 1, #players do
    if players[p].team == 1 then
      team1Good = true
    elseif players[p].team == 2 then
      team2Good = true
    end
  end
  if team1Good == false or team2Good == false then
    server:send(bin:pack({"disconnect", "all"}))
    mainmenu_load()
    gamestate = "menu"
    return
  end

  if newQb == true then
    findQb(newQbTeam)
    newQb = false
  end

  -- find which player is the "avatar"
  for p = 1, #players do
    if players[p].id == 1 then
      avatar.num = p
      break
    end
  end

  -- move player
  if players[avatar.num].pause <= 0 then
    if avatar.num == possesion or players[avatar.num].action == 2 then
      speed =  20
    elseif team[players[avatar.num].team].position == "offense" then
      speed = 40
    else
      speed = 30
    end
    if love.keyboard.isDown("d") then
      avatar.xV = avatar.xV + dt * speed
    end
    if love.keyboard.isDown("a") then
      avatar.xV = avatar.xV - dt * speed
    end
    if love.keyboard.isDown("w") then
      avatar.yV = avatar.yV - dt * speed
    end
    if love.keyboard.isDown("s") then
      avatar.yV = avatar.yV + dt * speed
    end
  end

  players[avatar.num].x = players[avatar.num].x + avatar.xV
  players[avatar.num].y = players[avatar.num].y + avatar.yV
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
  -- confine player to line of scrimmage
  if down.dt < timeTillStart then
    if players[avatar.num].team == 1 then
      if players[avatar.num].x > down.scrim then
        players[avatar.num].x = down.scrim
        avatar.xV = 0
      end
    else
      if players[avatar.num].x < down.scrim then
        players[avatar.num].x = down.scrim
        avatar.xV = 0
      end
    end
  end

  --animate avatar
  if players[avatar.num].pause <= 0 then
    animatePlayer(avatar.num, avatar.xV, avatar.yV)
  end

  avatar.xV = avatar.xV * 0.4
  avatar.yV = avatar.yV * 0.4

  -- send coords
  server:send(bin:pack({"coords", 1, players[avatar.num].x, players[avatar.num].y}))

  -- set camera position
  camera.x = -1 * warpX(players[avatar.num].x, players[avatar.num].y) - math.floor(mX) + 400
  camera.y = warpY(-1 * players[avatar.num].y) - math.floor(mY) + 300

  --quarterback's target
  if avatar.num == qb then
    if arrowShot == false then
      qbTargetX, qbTargetY = (players[avatar.num].x + (math.floor(mX) - 200) * 2), (players[avatar.num].y + (math.floor(mY) - 150) * 2)
      server:send(bin:pack({"target", qbTargetX, qbTargetY, gameDt}))
      targetPos[#targetPos + 1] = {qbTargetX, qbTargetY, gameDt}
      if #targetPos > 200 then
        targetPos[1] = nil
      end
      targetPos = removeNil(targetPos)
    end
  end
  if arrowShot == false then
    if players[avatar.num].team == players[qb].team then
      targetSize = range(down.dt, 0, 1)
      currentTarget = #targetPos
    else
      targetSize = range(down.dt - otherTeamDelay, 0, 1)
      for i = 1, #targetPos do
        if targetPos[i + 1] ~= nil then
          if math.abs(targetPos[i][3] - (gameDt - otherTeamDelay)) < math.abs(targetPos[i + 1][3] - (gameDt - otherTeamDelay)) then
            currentTarget = i
            break
          end
        else
          break
        end
      end
    end
  else
    targetSize = range((targetPos[#targetPos][3] - gameDt) * 2 + 1, 0, 1)
    currentTarget = #targetPos
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
        arrow.z = (((arrow.distance / 2 - arrow.r) * (arrow.distance / 2 - arrow.r)) * -1 + ((arrow.distance / 2) * (arrow.distance / 2))) / 340
      else
        arrow.z = (((arrow.distance / 2 - arrow.r) * (arrow.distance / 2 - arrow.r)) - ((arrow.distance / 2) * (arrow.distance / 2))) / 340
      end
      arrow.angle = math.atan2((arrow.currentY + arrow.z) - (arrow.oldY + arrow.oldZ), arrow.currentX - arrow.oldX)

      --check if arrow is caught
      if arrow.z < 16 then
        possible = {}
        for p = 1, #players do
          if p ~= qb then
            if team[players[p].team].position == "offense" then
              if math.sqrt((players[p].x - arrow.currentX) * (players[p].x - arrow.currentX) + (players[p].y - arrow.currentY) * (players[p].y - arrow.currentY)) < 16 then
                possible[#possible + 1] = p
              end
            else
              if math.sqrt((players[p].x - arrow.currentX) * (players[p].x - arrow.currentX) + (players[p].y - arrow.currentY) * (players[p].y - arrow.currentY)) < 8 then
                possible[#possible + 1] = p
              end
            end
          end
        end
        if #possible > 0 then
          item = math.random(1, #possible)
          server:send(bin:pack({"posses", possible[item]}))
          possesion = possible[item]
          arrow = {}
          if players[possesion].team == players[qb].team then
            message[#message + 1] = {players[possesion].name .. " caught the ball!", gameDt}
            objects[#objects + 1] = {type = "drop", subType = 2, x = players[possesion].x, y = players[possesion].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[possesion].team}
          else
            turnover = true
            message[#message + 1] = {players[possesion].name .. " intercepted the ball!", gameDt}
            objects[#objects + 1] = {type = "drop", subType = 1, x = players[possesion].x, y = players[possesion].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[possesion].team}

            down.num = 1
            if team[1].position == "offense" then
              team[1].position = "defense"
              team[2].position = "offense"
              qb = findQb(2)
            else
              team[1].position = "offense"
              team[2].position = "defense"
              qb = findQb(1)
            end
            down.goal = findGoal()
            for p = 1, #players do
              if p ~= possesion then
                if team[players[p].team].position == "offense" then
                  players[p].image = "dropSword"
                  players[p].frame = 1
                  players[p].pause = 1000
                  objects[#objects + 1] = {type = "drop", subType = 1, x = players[p].x, y = players[p].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[p].team}
                else
                  players[p].image = "dropShield"
                  players[p].frame = 1
                  players[p].pause = 1000
                  objects[#objects + 1] = {type = "drop", subType = 2, x = players[p].x, y = players[p].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[p].team}
                end
              end
            end
          end
          animatePlayer(possesion, 0, 0)
          for i = 1, gore do
            objects[#objects + 1] = {type = "blood", x = players[possesion].x, y = players[possesion].y, dt = 0, zV = -2, z = -16, mode = 1, xV = math.random(-3, 3), yV = math.random(-6, 0)}
          end
        end
      end
    else
      --incomplete
      objects[#objects + 1] = {type = "arrow", x = arrow.targetX, y = arrow.targetY, dt = 0}
      arrow = {}
      startNewDown = newDownBuffer
      message[#message + 1] = {players[qb].name .. " threw an incomplete pass!", gameDt}
    end
  end

  --new down
  if startNewDown ~= nil then
    startNewDown = startNewDown - dt

    --revive the dead
    if startNewDown <= newDownBuffer - 1 then
      for p = 1, #players do
        if players[p].action == 6 then
           players[p].frame = players[p].frame - dt * 32
           if players[p].frame < 1 then
             players[p].action = 0
             if team[players[p].team].position == "offense" then
               players[p].image = "dropSword"
             else
               players[p].image = "dropShield"
             end
             players[p].frame = 1
             players[p].pause = 1000
           end
         end
       end
     end

    -- setting up the new down
    if startNewDown <= 0 then
      turnover = false
      players[qb].image = "bowStill"
      down.num = down.num + 1
      down.dt = 0
      arrowShot = false
      startNewDown = nil
      startAnnounce = {false, false, false}

      if down.num > 4 then
        down.num = 1
        if team[1].position == "offense" then
          team[1].position = "defense"
          team[2].position = "offense"
          qb = findQb(2)
        else
          team[1].position = "offense"
          team[2].position = "defense"
          qb = findQb(1)
        end
        down.goal = findGoal()
        for p = 1, #players do
          if p ~= possesion then
            if team[players[p].team].position == "offense" then
              players[p].image = "dropSword"
              players[p].frame = 1
              players[p].pause = 1000
              objects[#objects + 1] = {type = "drop", subType = 1, x = players[p].x, y = players[p].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[p].team}
            else
              players[p].image = "dropShield"
              players[p].frame = 1
              players[p].pause = 1000
              objects[#objects + 1] = {type = "drop", subType = 2, x = players[p].x, y = players[p].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[p].team}
            end
          end
        end
      end

      possesion = qb

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
          players[p].x = down.scrim + (-118 + (playerNum[1] - playerNum[3]) * 10) / (players[p].y / 1600 + 0.5)
          players[p].direction = 1
          playerNum[3] = playerNum[3] + 1
        else
          players[p].y = 465
          players[p].x = down.scrim + (118 + (playerNum[2] - playerNum[4]) * -10) / (players[p].y / 1600 + 0.5)
          players[p].direction = -1
          playerNum[4] = playerNum[4] + 1
        end
        players[p].action = 0
        players[p].frame = 1
        players[p].pause = 0
        animatePlayer(p, 0, 0)
      end
      if down.num == 1 then
        message[#message + 1] = {down.num .. "st down", gameDt}
      elseif down.num == 2 then
        message[#message + 1] = {down.num .. "nd down", gameDt}
      elseif down.num == 3 then
        message[#message + 1] = {down.num .. "rd down", gameDt}
      else
        message[#message + 1] = {down.num .. "th down", gameDt}
      end
    end
  end

  --"3, 2, 1"
  if down.dt > timeTillStart - 3 and startAnnounce[3] == false then
    message[#message + 1] = {"3", gameDt}
    startAnnounce[3] = true
  elseif down.dt > timeTillStart - 2 and startAnnounce[2] == false then
    message[#message + 1] = {"2", gameDt}
    startAnnounce[2] = true
  elseif down.dt > timeTillStart - 1 and startAnnounce[1] == false then
    message[#message + 1] = {"1", gameDt}
    startAnnounce[1] = true
  end

  --objects
  for i = 1, #objects do
    objects[i].dt = objects[i].dt + dt
    if objects[i].type == "drop" then
      if objects[i].z >= 10 then
        objects[i].zV = objects[i].bounce
        objects[i].bounce = objects[i].bounce / 4
      end
      objects[i].z = objects[i].z + objects[i].zV
      objects[i].zV = objects[i].zV + 0.5
    elseif objects[i].type == "blood" then
      if objects[i].mode == 1 then
        objects[i].z = objects[i].z + objects[i].zV
        objects[i].zV = objects[i].zV + 0.2
        objects[i].x = objects[i].x + objects[i].xV
        objects[i].xV = objects[i].xV * 0.9
        objects[i].y = objects[i].y + objects[i].yV
        objects[i].yV = objects[i].yV * 0.9
        if objects[i].z >= 10 then
          objects[i].mode = 2
        end
      end
    end
    if objects[i].dt > 127 then
      objects[i] = nil
    end
  end
  objects = removeNil(objects)

  --messages
  for i = 1, #message do
    if (gameDt - message[i][2]) * messageDeleteSpeed >= 255 then
      message[i] = nil
    end
  end
  message = removeNil(message)

  -- qb drop bow / players drop stuff
  for p = 1, #players do
    if players[p].image == "dropBow" then
      players[p].frame = players[p].frame + dt * 12
      if players[p].frame > 14 then
        players[p].image = "grabShield"
        players[p].pause = 0
      end
    elseif players[p].image == "dropShield" then
      players[p].frame = players[p].frame + dt * 12
      if players[p].frame > 14 then
        players[p].image = "unsheathSword"
        players[p].pause = 0
      end
    elseif players[p].image == "dropSword" then
      players[p].frame = players[p].frame + dt * 12
      if players[p].frame > 14 then
        players[p].image = "grabShield"
        players[p].pause = 0
      end
    end
  end

  --actions
  if love.mouse.isDown(1) == false and players[avatar.num].action == 2 then
    server:send(bin:pack({"noshield", avatar.num}))
    players[avatar.num].action = 3
    players[avatar.num].image = "shieldUp"
    players[avatar.num].frame = 4
    players[avatar.num].pause = 1000
  end
  for p = 1, #players do
    if players[p].action > 0 then
      if players[p].action == 1 then
        players[p].frame = players[p].frame + dt * 30
        if players[p].frame > 4 then
          players[p].action = 2
          players[p].pause = 0
        end
      elseif players[p].action == 3 then
        players[p].frame = players[p].frame - dt * 30
        if players[p].frame < 1 then
          players[p].action = 0
          players[p].frame = 1
          players[p].pause = 0
        end
      elseif players[p].action == 4 then
        players[p].frame = players[p].frame + dt * 30
        if players[p].frame > 4 then
          players[p].action = 5
          players[p].frame = 4
        end
      elseif players[p].action == 5 then
        players[p].frame = players[p].frame - dt * 30
        if players[p].frame < 1 then
          players[p].action = 0
          players[p].pause = 0
        end
      elseif players[p].action == 6 then
        if players[p].frame < 4 then
          players[p].frame = players[p].frame + dt * 16
        end
      end
    end

    --killing
    if players[p].action == 4 and startNewDown == nil then
      if players[p].frame >= 3 or players[p].frame <= 4 then
        possible = {}
        for p2 = 1, #players do
          if players[p2].team ~= players[p].team and players[p].action ~= 6 then
            if players[p].direction == 1 then
              if math.sqrt((players[p2].x - players[p].x - 16) * (players[p2].x - players[p].x - 16) + (players[p2].y - players[p].y) * (players[p2].y - players[p].y)) < 16 then
                if players[p2].action == 1 or players[p2].action == 2 or players[p2].action == 3 then
                  server:send(bin:pack({"interrupt", p}))
                  possible = {}
                  players[p].action = 5
                  players[p].frame = 4
                  break
                else
                  possible[#possible + 1] = p2
                end
              end
            else
              if math.sqrt((players[p2].x - players[p].x + 16) * (players[p2].x - players[p].x + 16) + (players[p2].y - players[p].y) * (players[p2].y - players[p].y)) < 16 then
                if players[p2].action == 1 or players[p2].action == 2 or players[p2].action == 3 then
                  possible = {}
                  players[p].action = 5
                  players[p].frame = 4
                  break
                else
                  possible[#possible + 1] = p2
                end
              end
            end
          end
          if #possible > 0 then
            item = possible[math.random(1, #possible)]
            server:send(bin:pack({"dead", item}))
            players[item].action = 6
            players[item].image = "dead"
            players[item].frame = 1
            players[item].direction = 1
            players[item].pause = 1000
            --if guy with ball is killed
            if item == possesion then
              message[#message + 1] = {players[possesion].name .. " was tackled!", gameDt}
              down.scrim = players[possesion].x
              if players[possesion].team == 1 then
                if down.scrim > down.goal then
                  down.num = 0
                  down.dt = 0
                  down.goal = findGoal()
                end
              else
                if down.scrim < down.goal then
                  down.num = 0
                  down.dt = 0
                  down.goal = findGoal()
                end
              end
              if possesion == qb then
                objects[#objects + 1] = {type = "drop", subType = 3, x = players[item].x, y = players[item].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[item].team}
              end
              possesion = 0
              startNewDown = newDownBuffer
            else
              objects[#objects + 1] = {type = "drop", subType = 2, x = players[item].x, y = players[item].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = players[item].team}
            end
            for i = 1, gore * 2 do
              objects[#objects + 1] = {type = "blood", x = players[item].x, y = players[item].y, dt = 0, zV = -2, z = -16, mode = 1, xV = math.random(-3, 3), yV = math.random(-6, 0)}
            end
          end
        end
      end
    end
  end

  --tick down pauses
  for p = 1, #players do
    if players[p].pause > 0 and players[p].pause < 1000 then
      players[p].pause = players[p].pause - dt
    end
  end

  if possesion ~= 0 then
    if players[possesion].team == 1 and players[possesion].x >= 750 and startNewDown == nil then
      server:send(bin:pack({"td", 1}))
      message[#message + 1] = {players[possesion].name .. " scored!", gameDt}
      scoreboard[1] = scoreboard[1] + 7
      startNewDown = newDownBuffer
      down.scrim = 0
      down.num = 4
    elseif players[possesion].team == 2 and players[possesion].x <= -750 and startNewDown == nil then
      server:send(bin:pack({"td", 2}))
      message[#message + 1] = {players[possesion].name .. " scored!", gameDt}
      scoreboard[1] = scoreboard[1] + 7
      startNewDown = newDownBuffer
      down.scrim = 0
      down.num = 4
    end
  end

  gameDt = gameDt + dt
  down.dt = down.dt + dt
end

function server_draw()
  thingsToDraw = {}

  --draw objects
  for i = 1, #objects do
    if objects[i].type == "arrow" then
      thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255 - (objects[i].dt * 2), img = arrowWobble, quad = arrowWobbleQuad[range(math.floor(objects[i].dt * 50), 1, 11)], x = warpX(objects[i].x, objects[i].y), y = warpY(objects[i].y), z = 0, rot = 0, sX = 1, zY = 1, oX = 16, oY = 32}
    elseif objects[i].type == "drop" then
      thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255 - (objects[i].dt * 2), img = pDropImg, quad = pDropQuad[objects[i].subType], x = warpX(objects[i].x, objects[i].y), y = warpY(objects[i].y), z = math.floor(objects[i].z), rot = 0, sX = 1, zY = 1, oX = 16, oY = 34}
      thingsToDraw[#thingsToDraw + 1] = {type = 1, r = team[objects[i].team].r, g = team[objects[i].team].g, b = team[objects[i].team].b, a = 255 - (objects[i].dt * 2), img = pDropImg, quad = pDropQuad[objects[i].subType + 3], x = warpX(objects[i].x, objects[i].y), y = warpY(objects[i].y) + 1, z = math.floor(objects[i].z), rot = 0, sX = 1, zY = 1, oX = 16, oY = 35}
    elseif objects[i].type == "blood" then
      thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255 - (objects[i].dt * 2), img = bloodDrop, quad = bloodDropQuad[objects[i].mode], x = warpX(objects[i].x, objects[i].y), y = warpY(objects[i].y), z = math.floor(objects[i].z), rot = 0, sX = 1, zY = 1, oX = 16, oY = 16}
    end
  end

  -- draw players
  for p = 1, #players do
    char = drawChar(players[p].image, players[p].frame)
    if players[p].action ~= 6 then
      thingsToDraw[#thingsToDraw + 1] = {type = 2, r = 255, g = 255, b = 255, a = 255, img = charShadow, quad = 0, x = warpX(players[p].x, players[p].y), y = warpY(players[p].y) - 1, z = 0, rot = 0, sX = 1, sY = 1, oX = 16, oY = 15}
    end
    thingsToDraw[#thingsToDraw + 1] = {type = 1, r = 255, g = 255, b = 255, a = 255, img = char[1], quad = char[2], x = warpX(players[p].x, players[p].y), y = warpY(players[p].y), z = 0, rot = 0, sX = players[p].direction, sY = 1, oX = 16, oY = 32}
    thingsToDraw[#thingsToDraw + 1] = {type = 1, r = team[players[p].team].r, g = team[players[p].team].g, b = team[players[p].team].b, a = 255, img = char[3], quad = char[4], x = warpX(players[p].x, players[p].y), y = warpY(players[p].y) + 1, z = 0, rot = 0, sX = players[p].direction, sY = 1, oX = 16, oY = 33}
    thingsToDraw[#thingsToDraw + 1] = {type = 3, r = team[players[p].team].r, g = team[players[p].team].g, b = team[players[p].team].b, a = 255, img = players[p].name, quad = 0, x = warpX(players[p].x, players[p].y) - math.floor(getPixelWidth(players[p].name) / 2), y = warpY(players[p].y) - 48, z = 0, rot = 0, sX = 0, sY = 0, oX = 0, oY = 0}
  end

  -- draw qb targetPos
  if #targetPos > 0 then
    thingsToDraw[#thingsToDraw + 1] = {type = 2, r = team[players[qb].team].r, g = team[players[qb].team].g, b = team[players[qb].team].b, a = 255, img = arrowTarget, quad = 0, x = warpX(targetPos[currentTarget][1], targetPos[currentTarget][2]), y = warpY(targetPos[currentTarget][2]), z = 0, rot = 0, sX = targetSize, sY = targetSize, oX = 16, oY = 8}
  end

  -- draw arrow
  if arrow.currentX ~= nil and arrow.currentY ~= nil then
    thingsToDraw[#thingsToDraw + 1] = {type = 2, r = 255, g = 255, b = 255, a = 255, img = arrowImg, quad = 0, x = warpX(arrow.currentX, arrow.currentY), y = warpY(arrow.currentY), z = math.floor(arrow.z) - 16, rot = arrow.angle, sX = 1, sY = 1, oX = 16, oY = 16}
  end

  sort(thingsToDraw)

  -- acutally drawing
  love.graphics.push()
  love.graphics.translate(camera.x, camera.y)

  --draw field / lines
  love.graphics.draw(fieldImg, -1000, -100)
  love.graphics.setColor(team[2].r, team[2].g, team[2].b)
  love.graphics.draw(fieldOverlayImg, fieldOverlayQuad[1], -1000, -100, 0)
  love.graphics.setColor(team[1].r, team[1].g, team[1].b)
  love.graphics.draw(fieldOverlayImg, fieldOverlayQuad[2], 0, -100, 0)
  love.graphics.setColor(55, 55, 255)
  love.graphics.line(math.floor(down.scrim), 400, math.floor(down.scrim) / 2, 0)
  love.graphics.setColor(255, 55, 55)
  love.graphics.line(math.floor(down.goal), 400, math.floor(down.goal) / 2, 0)

  for i = 1, #thingsToDraw do
    drawFunction[thingsToDraw[i].type](thingsToDraw[i].r, thingsToDraw[i].g, thingsToDraw[i].b, thingsToDraw[i].a, thingsToDraw[i].img, thingsToDraw[i].quad, thingsToDraw[i].x, thingsToDraw[i].y, thingsToDraw[i].z, thingsToDraw[i].rot, thingsToDraw[i].sX, thingsToDraw[i].sY, thingsToDraw[i].oX, thingsToDraw[i].oY)
  end
  love.graphics.setColor(255, 255, 255)

  love.graphics.pop()

  --GUI
  love.graphics.draw(scoreboardImg, scoreboardBase, 0, 0)
  love.graphics.setColor(team[1].r, team[1].g, team[1].b)
  love.graphics.draw(scoreboardImg, scoreboardBanner1, 0, 0)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(tostring(scoreboard[1]), 150 - math.floor(getPixelWidth(tostring(scoreboard[1])) / 2), 14)
  love.graphics.setColor(team[2].r, team[2].g, team[2].b)
  love.graphics.draw(scoreboardImg, scoreboardBanner2, 200, 0)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(tostring(scoreboard[2]), 250 - math.floor(getPixelWidth(tostring(scoreboard[2])) / 2), 14)

  for i = 1, #message do
    love.graphics.setColor(0, 0, 0, 255 + (message[i][2] - gameDt) * messageDeleteSpeed)
    love.graphics.rectangle("fill", 3, 299 - ((#message - i + 1) * 12), getPixelWidth(message[i][1]) + 2, 11)
    love.graphics.setColor(255, 255, 255, 255 + (message[i][2] - gameDt) * messageDeleteSpeed)
    love.graphics.print(message[i][1], 4, 300 - ((#message - i + 1) * 12))
    love.graphics.setColor(255, 255, 255)
  end

   love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
   love.graphics.print("Gametime: "..math.floor(tostring(gameDt)), 10, 26)
end

function server_mousepressed(x, y, button)
  if button == 1 then
    if down.dt > timeTillStart then
      if qb == avatar.num and arrow.currentX == nil and arrow.currentY == nil and arrowShot == false then
        arrowTargetX, arrowTargetY = (players[avatar.num].x + (math.floor(mX) - 200) * 2), (players[avatar.num].y + (math.floor(mY) - 150) * 2)
        server:send(bin:pack({"arrow", arrowTargetX, arrowTargetY}))
        arrow = {oldX = players[avatar.num].x, oldY = players[avatar.num].y, startX = players[avatar.num].x, startY = players[avatar.num].y, currentX = players[avatar.num].x, currentY = players[avatar.num].y, theta = math.atan2(arrowTargetY - players[avatar.num].y, arrowTargetX - players[avatar.num].x), r = 0, targetX = arrowTargetX, targetY = arrowTargetY, z = 0, angle = 0}
        arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
        arrowShot = true
        dropBow()
        possesion = 0
      elseif team[players[avatar.num].team].position == "offense" and avatar.num ~= possesion then
        server:send(bin:pack({"shielding", avatar.num}))
        players[avatar.num].action = 1
        players[avatar.num].image = "shieldUp"
        players[avatar.num].frame = 1
        players[avatar.num].pause = 1000
      elseif team[players[avatar.num].team].position == "defense" and players[avatar.num].image ~= "dropBow" and avatar.num ~= possesion then
        server:send(bin:pack({"slicing", avatar.num}))
        players[avatar.num].action = 4
        players[avatar.num].image = "swordAttack"
        players[avatar.num].frame = 1
        players[avatar.num].pause = 1000
      end
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
  elseif data["1"] == "slicing" then
    server:send(bin:pack(data))
    players[data["2"]].action = 4
    players[data["2"]].image = "swordAttack"
    players[data["2"]].frame = 1
  elseif data["1"] == "shielding" then
    server:send(bin:pack(data))
    players[data["2"]].action = 1
    players[data["2"]].image = "shieldUp"
    players[data["2"]].frame = 1
  elseif data["1"] == "noshield" then
    server:send(bin:pack(data))
    players[data["2"]].action = 3
    players[data["2"]].image = "shieldUp"
    players[data["2"]].frame = 4
  elseif data["1"] == "arrow" then
    server:send(bin:pack(data))
    arrow = {oldX = players[qb].x, oldY = players[qb].y, startX = players[qb].x, startY = players[qb].y, currentX = players[qb].x, currentY = players[qb].y, theta = math.atan2(data["3"] - players[qb].y, data["2"] - players[qb].x), r = 0, targetX = data["2"], targetY = data["3"], z = 0, angle = 0}
    arrow.distance = math.sqrt((arrow.targetX - arrow.startX) * (arrow.targetX - arrow.startX) + (arrow.targetY - arrow.startY) * (arrow.targetY - arrow.startY))
    arrowShot = true
    dropBow()
    possesion = 0
  elseif data["1"] == "left" then
    server:send(bin:pack(data))
    for p = 1, #players do
      if players[p].id == data["2"] then
          players[p].delete = true
          players[p].image = "dissapear"
          players[p].frame = 1
          message[#message + 1] = {players[p].name .. "has disconnected", gameDt}
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
  if players[p].pause <= 0 then
    if xV > 0 and players[p].direction == -1 then
      players[p].direction = 1
    elseif xV < 0 and players[p].direction == 1 then
      players[p].direction = -1
    end
    local teamPos = team[players[p].team].position
    if math.abs(xV) > 0.1 or math.abs(yV) > 0.1 then
      if p == qb and arrowShot == false then
        players[p].image = "bowRun"
      elseif p ~= qb and p == possesion then
        players[p].image = "limp"
      elseif turnover == true and p == possesion then
        players[p].image = "limp"
      elseif teamPos == "offense" then
        if players[p].action == 2 then
          players[p].image = "shieldUpRun"
        else
          players[p].image = "runShield"
        end
      elseif teamPos == "defense" then
        players[p].image = "runSword"
      end
      if math.abs(xV) > math.abs(yV) then
        players[p].frame = loop(players[p].frame + math.abs(xV) / 2, 8)
      else
        players[p].frame = loop(players[p].frame + math.abs(yV) / 2, 8)
      end
    else
      if p == qb and arrowShot == false then
        players[p].image = "bowStill"
        players[p].frame = 1
      elseif p ~= qb and p == possesion then
        players[p].image = "limp"
        players[p].frame = 1
      elseif turnover == true and p == possesion then
        players[p].image = "limp"
        players[p].frame = 1
      elseif teamPos == "offense" then
        if players[p].action == 2 then
          players[p].image = "shieldUp"
          players[p].frame = 4
        else
          players[p].image = "grabShield"
          players[p].frame = 14
        end
      elseif teamPos == "defense" then
        players[p].image = "unsheathSword"
        players[p].frame = 14
      end
    end
  end
end

function findQb(team)
  possible = {}
  for p = 1, #players do
    if players[p].team == team then
      possible[#possible + 1] = p
    end
  end
  if # possible > 0 then
    item = math.random(1, #possible)
    server:send(bin:pack({"qb", possible[item]}))
    return possible[item]
  else
    return 1
  end
end

function findGoal()
  if team[1].position == "offense" then
    return down.scrim + 150
  else
    return down.scrim - 150
  end
end

function dropBow()
  players[qb].image = "dropBow"
  players[qb].pause = 1000
  players[qb].frame = 1
  objects[#objects + 1] = {type = "drop", subType = 3, x = players[qb].x, y = players[qb].y + 2, dt = 0, zV = 0, z = 0, bounce = -5, team = 1}
end
