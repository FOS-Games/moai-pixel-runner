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
        background =  tools:newprop("limbo like background.jpg", Stage.w,Stage.h)
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
        statusfont = tools:registerFont('kenvector_future.ttf', fontScale)
        status:setFont( statusfont )

        layer2 = MOAILayer2D.new()
        layer2:setViewport( viewport )
        layer2:insertProp( status )


    WorldBuilder:Initialize(world)


-- REMOVE ground (body) als distance speler.x - ground.x > 160
-- ADD ground op de distance van speler.x + 160

-- Ground thread
-- oneindige grond
groundThread = MOAIThread.new()
groundThread:run( function()
    while true do

      WorldBuilder:Update()
      coroutine.yield()

    end
end )



-- setup player
player = {}
player.onGround = false
player.currentContactCount = 0
player.move = {
    left = false,
    right = false
}
player.platform = nil
player.doubleJumped = false
player.verts = {
    -5, 8,
    -5, -9,
    -4, -10,
    4, -10,
    5, -9,
    5, 8
}
player.body = world:addBody( MOAIBox2DBody.DYNAMIC )
player.body.tag = 'player'
player.body:setFixedRotation( true )
player.body:setMassData( 80 )
player.body:resetMassData()
player.fixtures = {
    player.body:addPolygon( player.verts ),
    player.body:addRect( -4.9, -10.1, 4.9, -9.9 )
}
player.fixtures[1]:setRestitution( 0 )
player.fixtures[1]:setFriction( 0 )
player.fixtures[2]:setSensor( true )

-- Texture player
texture = MOAIGfxQuad2D.new()
texture:setTexture('Gnar.png')
texture:setRect(-14, -11, 14, 17)

sprite = MOAIProp2D.new()
sprite:setDeck(texture)
sprite:setParent(player.body)
layer:insertProp(sprite)



-- setup platforms
platforms = {}

platforms[3] = {}
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


platformThread = MOAIThread.new()
platformThread:run( function()
    while true do
      local x, y = platforms[3].body:getPosition()
      
      if x < -200 then
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

-- player foot sensor
function footSensorHandler( phase, fix_a, fix_b, arbiter )

    if phase == MOAIBox2DArbiter.BEGIN then
        player.currentContactCount = player.currentContactCount + 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = fix_b:getBody()
        end
    elseif phase == MOAIBox2DArbiter.END then
        player.currentContactCount = player.currentContactCount - 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = nil
        end
    end
    if player.currentContactCount == 0 then
        player.onGround = false
    else
        player.onGround = true
        player.doubleJumped = false
    end
end
player.fixtures[2]:setCollisionHandler( footSensorHandler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )

-- keyboard input handler
function onKeyboard( key, down )
    -- 'a' key
    if key == 97 then
        player.move.left = down
    -- 'd' key
    elseif key == 100 then
        player.move.right = down
    end
    
    -- jump
    if key == 119 and down and ( player.onGround or not player.doubleJumped ) then
        player.body:setLinearVelocity( player.body:getLinearVelocity(), 0 )
        player.body:applyLinearImpulse( 0, 100 )
        if not player.onGround then
            player.doubleJumped = true
        end
    end
end
MOAIInputMgr.device.keyboard:setCallback( onKeyboard )

-- player movement thread
playerThread = MOAIThread.new()
playerThread:run( function()
    while true do
        local dx, dy = player.body:getLinearVelocity()
        if player.onGround then
            if player.move.right and not player.move.left then
                dx = 50
            elseif player.move.left and not player.move.right then
                dx = -50
            else
                dx = 0
            end
        else
            if player.move.right and not player.move.left and dx <= 0 then
                dx = 25
            elseif player.move.left and not player.move.right and dx >= 0 then
                dx = -25
            end
        end
        if player.platform then
            dx = dx + player.platform:getLinearVelocity()
        end
        player.body:setLinearVelocity( dx, dy )
        coroutine.yield()
    end
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