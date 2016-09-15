function clientmenu_load()
  ip = ""
  proceed = false
  connectButton = loadButton("Connect", 50)
end

function clientmenu_update(dt)
  if proceed == false then
    ipBoxLength = range(getPixelWidth(ip) + 6, 94, math.huge)
  else
    client:update(dt)

    if success == false then
      proceed = false
    end
  end
end

function clientmenu_draw()
  if proceed == false then
    love.graphics.print("Enter IP:", 181, 150)
    love.graphics.draw(textboxImg, textboxSide1, 200 - ipBoxLength / 2, 164)
    love.graphics.draw(textboxImg, textboxSide2, 190 + ipBoxLength / 2, 164)
    love.graphics.print(ip, 200 - getPixelWidth(ip) / 2, 168)
    love.graphics.draw(connectButton, 175, 186)
    if success == false then
      love.graphics.setColor(255, 55, 55)
      love.graphics.print("Unable to connect. check IP", 142, 208)
      love.graphics.setColor(255, 255, 255)
    end
  end
end

function clientmenu_textinput(text)
  if proceed == false then
    if textBox == "ip" then
      ip = ip .. text
    end
  end
end


function clientmenu_keypressed(key)
  if proceed == false then
    if key == "backspace" then
      if textBox == "ip" then
        ip = string.sub(ip, 1, -2)
      end
    elseif key == "return"  then
      proceed = true
      client = lube.udpClient()
    	success, err = client:connect(interpretIp(ip))
      client:send(bin:pack({msg = "name", name = playerName}))
    end
  end
end

function clientmenu_mousepressed(x, y, button)
  if proceed == false then
    if button == 1 then
      if x >= 200 - ipBoxLength / 2 and x <= 200 + ipBoxLength / 2 and y >= 164 and y <= 180 then
        textBox = "ip"
      elseif x >= 175 and x <= 225 and y >= 186 and y <= 202 and proceed == false then
        proceed = true
        client = lube.udpClient()
      	success, err = client:connect(interpretIp(ip))
        client:send(bin:pack({msg = "name", name = playerName}))
      else
        textBox = ""
      end
    end
  end
end

function interpretIp(ip)
  if string.find(":", ip) ~= nil then
    start, final = string.find(":", ip)
    return string.sub(ip, 1, start - 1), string.sub(ip, start + 1, -1)
  else
   return ip, 25565
  end
end
