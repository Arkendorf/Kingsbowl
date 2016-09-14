function clientmenu_load()
  ip = ""
end

function clientmenu_update(dt)
end

function clientmenu_draw()
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("fill", 150, 150, 100, 16)
  love.graphics.setColor(0,0,0)
  love.graphics.print(ip, 150, 150)
end

function clientmenu_textinput(text)
  if textBox == "ip" and getPixelWidth(ip .. text) < 100 then
    ip = ip .. text
  end
end


function clientmenu_keypressed(key)
  if key == "backspace" then
    if textBox == "ip" then
      ip = string.sub(ip, 1, -2)
    end
  end
end

function clientmenu_mousepressed(x, y, button)
  if button == 1 then
    if x >= 150 and x <= 250 and y >= 150 and y <= 166 then
      textBox = "ip"
    else
      textBox = ""
    end
  end
end
