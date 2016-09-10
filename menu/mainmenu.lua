function mainmenu_load()
end

function mainmenu_update()
end

function mainmenu_draw()
  love.graphics.rectangle("fill", 350, 300, 100, 32)
  love.graphics.rectangle("fill", 350, 336, 100, 32)
  love.graphics.rectangle("fill", 350, 372, 100, 32)
end

function mainmenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 350 and x <= 350 + 100 and y >= 300 and y <= 300 + 32 then
      gamestate = "tutorial"
    elseif x >= 350 and x <= 350 + 100 and y >= 336 and y <= 336 + 32 then
      servermenu_load()
      gamestate = "servermenu"
    elseif x >= 350 and x <= 350 + 100 and y >= 372 and y <= 372 + 32 then
      gamestate = "clientmenu"
    end
  end
end
