require('mainRequirements')
-- scale set so screen is 20 meters tall
scale = 10

-- screen dimensions
Screen = {
    w = 1216,
    h = 760
}

-- stage dimensions
Stage = {
    w = 320,
    h = 200
}
------------------------------------------
------------Scene building----------------
------------------------------------------

        -- Background image inladen
        background =  toolsclass:newprop("limbo like background.jpg", Stage.w,Stage.h)
        background:setLoc(0,0)

        -- background rendering layer
        bglayer = MOAILayer2D.new()

        -- main rendering layer
        layer = MOAILayer2D.new()

        -- open sim window
        MOAISim.openWindow( 'platformer_test', Screen.w, Screen.h )

        -- setup viewport
        viewport = MOAIViewport.new()
        viewport:setSize( Screen.w, Screen.h )
        viewport:setScale( Stage.w, Stage.h )

        -- setup Box2D world
        world = MOAIBox2DWorld.new()
        world:setGravity( 0, -20 )
        world:setUnitsToMeters( 1 / scale )

        -- Weghalen om outlines te verwijderen
        world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS +
                                 MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

        layer:setViewport( viewport )
        layer:setBox2DWorld( world )

        -- Background adden
        bglayer:setViewport( viewport )
        bglayer:insertProp( background )

-----------------------------------------------------
------------------Debug status-----------------------
-----------------------------------------------------

        local charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|/?.,<>!~`@#$%^&*\'":;'
        local fontScale = Screen.h / Stage.h
        -- status textbox
        status = MOAITextBox.new()
        status:setRect( -160 * fontScale, -100 * fontScale, 160 * fontScale, 100 * fontScale )
        status:setScl( 1 / fontScale )
        status:setYFlip( true )
        status:setColor( 1, 1, 1 )
        status:setString( 'status' )
        statusfont = toolsclass:registerFont('kenvector_future.ttf', fontScale)
        status:setFont( statusfont )

        layer2 = MOAILayer2D.new()
        layer2:setViewport( viewport )
        layer2:insertProp( status )

------------------------------------------------
--------------start functions-------------------
------------------------------------------------
    --local playerclass =require 'Player'
    local player = playerclass:Start(world)
    --local player1 = playerclass:Start(world)
    inputclass:initialize()
    WorldBuilderclass:Start(world,layer)
    inputclass:registerKeyDownFunction(playerclass.MovementCallBack ,119 ,playerclass)
    layer:insertProp(playerclass:getProp('Gnar.png'))


-- REMOVE ground (body) als distance speler.x - ground.x > 160
-- ADD ground op de distance van speler.x + 160

-- Ground thread
-- oneindige grond
groundThread = MOAIThread.new()
groundThread:run( function()
    while true do

      WorldBuilderclass:Update()
      playerclass:Update()
      coroutine.yield()

    end
end )







-- setup platforms
platforms = {}

platforms[3] = {}

platforms[3].object = platform:new(5,2,'Level1',world,layer)
platforms[3].body = platforms[3].object:getBody()

platforms[3].body:setLinearVelocity( -80, 0 )
--[[local pbody,pprop = toolsclass:generateKinematicBox(world,'64x64 balk.png')
pprop:setLoc(-10,-10)
layer:insertProp(pprop)
platforms[3].body = world:addBody( MOAIBox2DBody.KINEMATIC, 130, -34 )
platforms[3].body.tag = 'platform'
platforms[3].body:setLinearVelocity( -80, 0 )
--platforms[3].limits = {
--    xMax = 160, xMin = -160,
--    yMax = -43, yMin = -45
--}
platforms[3].fixtures = {
    platforms[3].body:addRect( -10, -10, 10, 10 )
}
prop = {}
for i=0,3,1 do
    prop[i] = toolsclass:newprop('64x64 balk.png',10,10)
end
prop[0]:setLoc(-5,5)
prop[1]:setLoc(5,-5)
prop[2]:setLoc(5,5)
prop[3]:setLoc(-5,-5)

for i=0,1,1 do
    prop[i]:setParent(platforms[3].body)
    layer:insertProp(prop[i])
end]]


platformThread = MOAIThread.new()
platformThread:run( function()
    while true do
      local x, y = platforms[3].body:getPosition()
      
      if x < -100 then
        platforms[3].body:setTransform(200, math.random(-80, 80))


      end

      
      coroutine.yield()
    end
end )

-- platform movement thread
--platformThread = MOAIThread.new()
--platformThread:run( function()
--    while true do
--        for k, v in ipairs( platforms ) do
--            local x, y = v.body:getWorldCenter()
--            local dx, dy = v.body:getLinearVelocity()
--            if x > v.limits.xMax or x < v.limits.xMin then
--                dx = -dx
--            end
--            if y > v.limits.yMax or y < v.limits.yMin then
--                dy = -dy
--            end
--            v.body:setLinearVelocity( dx, dy )
--        end
--        coroutine.yield()
--    end
--end )

-- playerclass movement thread
playerThread = MOAIThread.new()
playerThread:run( function()

end )

-- update function for status box
statusThread = MOAIThread.new()
statusThread:run( function()
    while true do
        local x, y = player.body:getWorldCenter()
        local dx, dy = player.body:getLinearVelocity()
        status:setString( 'x, y:   ' .. math.ceil( x ) .. ', ' .. math.ceil( y )
                     .. '\ndx, dy: ' .. math.ceil( dx ) .. ', ' .. math.ceil( dy )
                     .. '\nOn Ground: ' .. ( player.onGround and 'true' or 'false' )
                     .. '\nContact Count: ' .. player.currentContactCount
                     .. '\nPlatform: ' .. ( player.platform and 'true' or 'false' ) )
        coroutine.yield()
    end
end )

-- render scene and begin simulation
world:start()
MOAIRenderMgr.setRenderTable( { bglayer, layer, layer2 } )