require "keys"
require "debugoverlay"
require "mathlib"
require "load"
require "polygons"

function love.load()
    print(unpack(love.graphics.getSupported() ) )

    dimensions = {}
    dimensions.x, dimensions.y = love.graphics.getDimensions()
    mouse = {}
    mouse.x, mouse.y = love.mouse.getPosition()

    targetFps = 30
    fps = targetFps

    rot = {x = 0, y = math.pi/2}
    pos = {x = 0, y = 0, z = 0}
    mvSpeed = 4
    accel = {x = 0, y = 0, z = 0}
    deAccel = 0.8
    fov = 0.382*math.pi
    rendDist = 1000
    lod = 70
    maxLod = 5000

    waterHeight = 0.2

    contact = {x = false, y = false, z = false}
    flying = false

    canvasMultiplier = 1
    renderCanvas = love.graphics.newCanvas(dimensions.x*canvasMultiplier, dimensions.y*canvasMultiplier)

    load_shaders(true)
    load_textures(true)

    shader.raycast:send("rendDist", rendDist)
    shader.raycast:send("fov", fov)
    shader.raycast:send("lod", lod)

    shader.raycast:send("waterHeight", waterHeight)

    shader.raycast:send("stone", texture.stone)
    shader.raycast:send("heightmap2", texture.heightmap2)
    shader.raycast:send("pretty", texture.pretty)

    heightmapData = love.image.newImageData("textures/heightmap2.png")

end

function love.update(dt)
    deltatime = dt
    runtime = runtime and runtime + deltatime or 0
    fps = mathlib.round(mathlib.lerp(fps, 1/dt, mathlib.bounds(dt, 0, 1) ), 2)
    dimensions.x, dimensions.y = love.graphics.getDimensions()
    mouse.x, mouse.y = love.mouse.getPosition()
    keyHeld()

    if renderCanvas:getWidth() ~= dimensions.x*canvasMultiplier or renderCanvas:getHeight() ~= dimensions.y*canvasMultiplier then
        renderCanvas = love.graphics.newCanvas(dimensions.x*canvasMultiplier, dimensions.y*canvasMultiplier)
    end

    if runtime%1 + dt > 1 then
        load_shaders()
    end

    if flying ==false and contact.z == false then
        accel.z = accel.z - 20*dt
    end

    for i, v in pairs(pos) do
        pos[i] = pos[i] + accel[i]*deAccel*math.min(1, dt)
    end

    tempPixelHeight = heightmapData:getPixel( (pos.x + 1000/2)%1000/1000*heightmapData:getWidth(), (pos.y + 1000/2)%1000/1000*heightmapData:getHeight())

    if pos.z - 2 <= -10 then
        contact.z = true
        accel.z = math.max(0, accel.z)
        if flying == false then
            pos.z = -8
        end
    elseif pos.z - 2 <= tempPixelHeight*50 - 0 then
        contact.z = true
        accel.z = math.max(0, accel.z)
        if flying == false then
            pos.z = tempPixelHeight*50 - 0 + 2
        end
    else
        contact.z = false
    end


    for i, v in pairs(accel) do
        accel[i] = accel[i] - accel[i]*deAccel*math.min(1, dt)
        if accel[i] < 0.01 and accel[i] > -0.01 then
            accel[i] = 0
        end
    end

    if fps < targetFps then
        --rendDist = math.max(rendDist - 0.0001 * math.max(targetFps - fps, 0)^3, 5)
        --lod = math.max(1, lod - 0.wdd5 * (math.max(targetFps - fps + 30, 0)*0.02)^10/0.02)
        lod = math.max(1, lod - 0.5 * math.sinh(math.max(math.min(targetFps - fps, 20) + 4, 0)*1)*dt)
        shader.raycast:send("lod", lod)
    elseif fps > targetFps + 10 then
        --rendDist = rendDist + 0.5
        lod = math.min(maxLod, lod + 0.5 * math.sinh(math.max(math.min(fps - targetFps, 5) - 2, 0)*1)*dt)
        shader.raycast:send("lod", lod)
    end

    shader.raycast:send("dimensions", {dimensions.x*canvasMultiplier, dimensions.y*canvasMultiplier} )
    shader.raycast:send("rot", {rot.x, rot.y} )
    shader.raycast:send("pos", {pos.x, pos.y, pos.z} )
end

function love.draw()
    love.graphics.setCanvas(renderCanvas)

    love.graphics.setShader(shader.raycast)
    love.graphics.rectangle("fill", 0, 0, dimensions.x*canvasMultiplier, dimensions.y*canvasMultiplier)
    love.graphics.setShader()

    love.graphics.setCanvas()

    love.graphics.draw(renderCanvas, 0, 0, 0, 1/canvasMultiplier, 1/canvasMultiplier)

    if showdebug then
        debugoverlay()
    end
end
