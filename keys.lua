
dimensions = {}
dimensions.x, dimensions.y = love.graphics.getDimensions()
fullscreen = false
dimensions.x, dimensions.y = love.graphics.getDimensions()

love.mouse.setVisible(false)
love.mouse.setPosition(dimensions.x/2, dimensions.y/2)
love.mouse.setGrabbed(true)

local lastTap = -1

local function default(key)
    if key=="escape" then
        if fullscreen then
            fullscreen = nil
            love.window.setFullscreen(false)
        else
            love.event.quit(0)
        end
    elseif key=="f11" then
        fullscreen = not fullscreen and true or false
        love.window.setFullscreen(fullscreen)
    elseif key == "f2" then
        takingShot = true
        lod = 1000
        raycastShader:send("lod", lod)
    elseif key == "f3" then
        showdebug = showdebug == nil and true or nil
    elseif key == "f4" then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        debug.debug()
        love.mouse.setVisible(false)
        love.mouse.setPosition(dimensions.x/2, dimensions.y/2)
        love.mouse.setGrabbed(true)
    end
end

function love.keypressed(key, u)
    default(key)
    if key == "t" then
        fps = 5
    elseif key == "space" then
        if os.clock() - lastTap <= 0.3 then
            flying = flying == false and true or false
            if flying == true then
                accel.z = 0
                print("Flying")
            else
                print("Not Flying")
            end
        end
        lastTap = os.clock()
    end
end

function keyHeld()
    if love.keyboard.isDown("w") then
        accel.x = accel.x + deltatime*mvSpeed*math.cos(rot.x)
        accel.y = accel.y + deltatime*mvSpeed*math.sin(rot.x)
    end
    if love.keyboard.isDown("s") then
        accel.x = accel.x - deltatime*mvSpeed*math.cos(rot.x)
        accel.y = accel.y - deltatime*mvSpeed*math.sin(rot.x)
    end
    if love.keyboard.isDown("d") then
        accel.y = accel.y + deltatime*mvSpeed*math.cos(rot.x)
        accel.x = accel.x - deltatime*mvSpeed*math.sin(rot.x)
    end
    if love.keyboard.isDown("a") then
        accel.y = accel.y - deltatime*mvSpeed*math.cos(rot.x)
        accel.x = accel.x + deltatime*mvSpeed*math.sin(rot.x)
    end
    if love.keyboard.isDown("space") then
        if flying == true then
            pos.z = pos.z + deltatime*mvSpeed
        elseif contact.z == true then
            accel.z = accel.z + 10
        end
    end
    if love.keyboard.isDown("lshift") then
        if flying == true then
            pos.z = pos.z - deltatime*mvSpeed
        end
    end
    if love.keyboard.isDown("lctrl") then
        mvSpeed = 100
    else
        mvSpeed = 4
    end
end


function love.wheelmoved(x, y)
    if love.mouse.isDown(1) then
        lod = lod + (lod*0.1)*y
        raycastShader:send("lod", lod)
    elseif love.mouse.isDown(2) then
        fov = fov - (fov*0.1)*y
        raycastShader:send("fov", fov)
    else
        rendDist = math.max(rendDist + (rendDist*0.1)*y, 1)
        raycastShader:send("rendDist", rendDist)
        waterHeight = mathlib.bounds(waterHeight + y/30, 0, 1)
        raycastShader:send("waterHeight", waterHeight)
    end
end

function love.mousemoved(x, y, dx, dy)
    rot.x = (rot.x + dx/dimensions.x * math.pi*2)%(math.pi*2)
    rot.y = math.max(0, math.min(math.pi, rot.y + dy/dimensions.y * math.pi) )

    if x == 0 then
        love.mouse.setPosition(dimensions.x, y)
    elseif x == dimensions.x - 1 then
        love.mouse.setPosition(0, y)
    end
end
