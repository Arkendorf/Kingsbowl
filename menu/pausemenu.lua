function pausemenu_load()
  screentype = {selected = 1, state = false, items = {"windowed", "fullscreen"}}
  refresh = false
  pausemenu_canvas()
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
    love.graphics.draw(screentype.closed, 162, 132)

    love.graphics.print("Scale:", 175, 155)
    love.graphics.draw(valueImg, arrowLeft, 202, 150)
      love.graphics.print(scaleFactor, 211, 155)
    love.graphics.draw(valueImg, arrowRight, 217, 150)
  else
    love.graphics.draw(screentype.open, 162, 132)
    love.graphics.rectangle("line", 162, 132 + screentype.selected * 16, 75, 16)
  end

  love.graphics.draw(mainmenuButton, 175, 186)
  love.graphics.draw(quitButton, 175, 204)
end

function pausemenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 225 and x <= 232 and y >= 136 and y <= 141 then
      if screentype.state == false then
        screentype.state = true
      else
        screentype.state = false
      end
      refresh = true
    elseif screentype.state == true then
      for i = 1, #screentype.items do
        if x >= 162 and x <= 237 and y >= 132 + i * 16 and y <= 150 + i * 16 then
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
    elseif x >= 202 and x <= 209 and y >= 152 and y <= 164 and scaleFactor > 1 then
      scaleFactor = scaleFactor - 1
      if love.window.getFullscreen() == false then
        love.window.setMode(400 * scaleFactor, 300 * scaleFactor)
        reloadCanvas()
      end
      adjustScreen()
      refresh = true
    elseif x >= 218 and x <= 225 and y >= 152 and y <= 164 and scaleFactor < 4 then
      scaleFactor = scaleFactor + 1
      if love.window.getFullscreen() == false then
        love.window.setMode(400 * scaleFactor, 300 * scaleFactor)
        reloadCanvas()
      end
      adjustScreen()
      refresh = true
    elseif x >= 175 and x <= 225 and y >= 186 and y <= 202 then
      if gamestate == "servermenu" then
        if proceed == true then
          server:send(bin:pack({"disconnect"}))
        end
      elseif gamestate == "clientmenu" then
        if proceed == true then
          client:disconnect()
        end
      end
      mainmenu_load()
      gamestate = "menu"
      pause = false
    elseif x > 175 and x <= 225 and y >= 204 and y <= 220 then
      love.event.quit()
    end
  end
end

function adjustScreen()
  scale = {x = scaleFactor, y = scaleFactor}
  offset = {x = (love.graphics.getWidth() - 400  * scaleFactor) / 2, y = (love.graphics.getHeight() - 300  * scaleFactor) / 2}
  screenW, screenH = love.graphics.getDimensions()
end
