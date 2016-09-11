function mainmenu_load()
end

function mainmenu_update()
end

function mainmenu_draw()
  love.graphics.rectangle("fill", 175, 150, 50, 16)
  love.graphics.rectangle("fill", 175, 168, 50, 16)
  love.graphics.rectangle("fill", 175, 186, 50, 16)
end

function mainmenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 175 and x <= 175 + 50 and y >= 150 and y <= 150 + 16 then
      gamestate = "tutorial"
    elseif x >= 175 and x <= 175 + 50 and y >= 168 and y <= 168 + 16 then
      servermenu_load()
      gamestate = "servermenu"
    elseif x >= 175 and x <= 175 + 50 and y >= 186 and y <= 186 + 16 then
      gamestate = "clientmenu"
    end
  end
end
