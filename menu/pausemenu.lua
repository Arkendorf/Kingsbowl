function pausemenu_load()
  screentype = {closed = loadDropDown({"windowed", "fullscreen"}, 1, false, 75), open = loadDropDown({"windowed", "fullscreen"}, 1, true, 75), selected = 1, state = false, items = {"windowed", "fullscreen"}}
  refresh = false
end

function pausemenu_update(dt)
  if refresh == true then
    screentype.closed = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
    screentype.open = loadDropDown(screentype.items, screentype.selected, screentype.state, 75)
    refresh = false
  end
end

function pausemenu_draw()
  love.graphics.print("settings", 186, 150)

  if screentype.state == false then
    love.graphics.draw(screentype.closed, 162, 168)

    love.graphics.print("Scale:", 175, 191)
    love.graphics.draw(valueImg, arrowLeft, 202, 186)
      love.graphics.print(scaleFactor, 211, 191)
    love.graphics.draw(valueImg, arrowRight, 217, 186)
  else
    love.graphics.draw(screentype.open, 162, 168)
  end
end

function pausemenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 225 and x <= 232 and y >= 173 and y <= 178 then
      if screentype.state == false then
        screentype.state = true
      else
        screentype.state = false
      end
      refresh = true
    elseif screentype.state == true then
      for i = 1, #screentype.items do
        if x >= 162 and x <= 237 and y >= 168 + i * 16 and y <= 184 + i * 16 then
          screentype.selected = i
          if screentype.items[i] == "windowed" then
            love.window.setFullscreen(false)
          else
            love.window.setFullscreen(true)
          end
          offset = {x = (love.graphics.getWidth() - 800) / 2, y = (love.graphics.getHeight() - 600) / 2}
          refresh = true
        end
      end
    elseif x >= 202 and x <= 209 and y >= 186 and y <= 202 then
      scaleFactor = range(scaleFactor - 1, 1, 4)
      scale = {x = love.graphics.getWidth() / 800 * scaleFactor, y = love.graphics.getHeight() / 600 * scaleFactor}
      offset = {x = (love.graphics.getWidth() - 400  * scaleFactor) / 2, y = (love.graphics.getHeight() - 300  * scaleFactor) / 2}
    elseif x >= 218 and x <= 225 and y >= 186 and y <= 202 then
      scaleFactor = range(scaleFactor + 1, 1, 4)
      scale = {x = love.graphics.getWidth() / 800 * scaleFactor, y = love.graphics.getHeight() / 600 * scaleFactor}
      offset = {x = (love.graphics.getWidth() - 400  * scaleFactor) / 2, y = (love.graphics.getHeight() - 300  * scaleFactor) / 2}
    else
      screentype.state = false
      refresh = true
    end
  end
end
