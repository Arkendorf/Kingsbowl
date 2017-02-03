function pausemenu_load()
  screentype = {selected = 1, state = false, items = {"windowed", "fullscreen"}}
  refresh = false
  pausemenu_canvas()
  textBox = ""
end

function pausemenu_canvas()
  screentype.closed = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
  screentype.open = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
  mainmenuButton = loadButton("Main Menu", 50)
  quitButton = loadButton("Quit", 50)
end

function reloadCanvas()
  pausemenu_canvas()
  if gamestate == "menu" then
    mainmenu_canvas()
  elseif gamestate == "servermenu" then
    servermenu_canvas()
  elseif gamestate == "clientmenu" then
    clientmenu_canvas()
  end
end

function pausemenu_update(dt)
  if refresh == true then
    screentype.closed = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
    screentype.open = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
    refresh = false
  end
end

function pausemenu_draw()
  love.graphics.print("settings", 186, 114)

  if screentype.state == false then
    love.graphics.draw(screentype.closed, 212, 132)

    love.graphics.print("Scale:", 225, 155)
    love.graphics.draw(valueImg, arrowLeft, 252, 150)
      love.graphics.print(scaleFactor, 261, 155)
    love.graphics.draw(valueImg, arrowRight, 267, 150)
  else
    love.graphics.draw(screentype.open, 212, 132)
    love.graphics.rectangle("line", 212, 132 + screentype.selected * 16, 75, 16)
  end

  love.graphics.draw(mainmenuButton, 225, 186)
  love.graphics.draw(quitButton, 225, 204)

  --left side
  love.graphics.print("Name:", 140, 137)
  love.graphics.print(playerName, 149 - math.floor(getPixelWidth(playerName) / 2), 155)
  if textBox == "name" then
    love.graphics.rectangle("line", 113, 152, 74, 16)
  else
    love.graphics.draw(textboxImg, textboxSide1, 112, 152)
    love.graphics.draw(textboxImg, textboxSide2, 178, 152)
  end

  love.graphics.print("Blood:", 125, 175)
  love.graphics.draw(valueImg, arrowLeft, 153, 170)
    love.graphics.print(gore, 162, 175)
  love.graphics.draw(valueImg, arrowRight, 168, 170)
end

function pausemenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 275 and x <= 282 and y >= 136 and y <= 141 then
      if screentype.state == false then
        screentype.state = true
      else
        screentype.state = false
      end
      refresh = true
    elseif screentype.state == true then
      for i = 1, #screentype.items do
        if x >= 212 and x <= 287 and y >= 132 + i * 16 and y <= 150 + i * 16 then
          screentype.selected = i
          if screentype.items[i] == "windowed" then
            love.window.setFullscreen(false)
          else
            love.window.setFullscreen(true)
          end
          offset = {x = (love.graphics.getWidth() - 800) / 2, y = (love.graphics.getHeight() - 600) / 2}
          if love.window.getFullscreen() == false then
            love.window.setMode(400 * scaleFactor, 300 * scaleFactor)
            reloadCanvas()
          end
          adjustScreen()
          refresh = true
        end
      end
      if refresh == false then
        screentype.state = false
        refresh = true
      end
    elseif x >= 252 and x <= 259 and y >= 152 and y <= 164 and scaleFactor > 1 then
      scaleFactor = scaleFactor - 1
      if love.window.getFullscreen() == false then
        love.window.setMode(400 * scaleFactor, 300 * scaleFactor)
        reloadCanvas()
      end
      adjustScreen()
      refresh = true
    elseif x >= 258 and x <= 275 and y >= 152 and y <= 164 and scaleFactor < 4 then
      scaleFactor = scaleFactor + 1
      if love.window.getFullscreen() == false then
        love.window.setMode(400 * scaleFactor, 300 * scaleFactor)
        reloadCanvas()
      end
      adjustScreen()
      refresh = true
    elseif x >= 225 and x <= 275 and y >= 186 and y <= 202 then
      if gamestate == "servermenu" or gamestate == "server" then
        if proceed == true then
          server:send(bin:pack({"disconnect", "all"}))
        end
      elseif gamestate == "clientmenu" or gamestate == "client" then
        if proceed == true then
          client:send(bin:pack({"disconnect", identifier}))
          client:disconnect()
        end
      end
      mainmenu_load()
      gamestate = "menu"
      pause = false
    elseif x >= 225 and x <= 275 and y >= 204 and y <= 220 then
      love.event.quit()
    elseif x >= 153 and x <= 160 and y >= 172 and y <= 184 and gore > 0 then
      gore = gore - 1
    elseif x >= 168 and x <= 175 and y >= 172 and y <= 184 and gore < 5 then
      gore = gore + 1
    elseif x >= 113 and x <= 187 and y >= 152 and y <= 168 then
      textBox = "name"
    else
      textBox = ""
    end
  end
end

function pausemenu_textinput(text)
  if textBox == "name" then
    if getPixelWidth(playerName .. text) < 74 then
      playerName = playerName .. text
    end
  end
end

function pausemenu_keypressed(key)
  if key == "backspace" then
    if textBox == "name" then
        playerName = string.sub(playerName, 1, -2)
    end
  end
end

function adjustScreen()
  scale = {x = scaleFactor, y = scaleFactor}
  offset = {x = (love.graphics.getWidth() - 400  * scaleFactor) / 2, y = (love.graphics.getHeight() - 300  * scaleFactor) / 2}
  screenW, screenH = love.graphics.getDimensions()
end
