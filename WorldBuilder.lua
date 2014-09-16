local WorldBuilder = {}

--
-- Created by IntelliJ IDEA.
-- User: Lars
-- Date: 9/12/2014
-- Time: 14:13
-- To change this template use File | Settings | File Templates.
--

local World
local worldlayer
level = 'Level1'

---------------------------------------
--------Initialize function------------
---------------------------------------
--Needs to be called before everything else
--related to the WorldBuilder
require 'platform'
function WorldBuilder:randomPlatform(width,height, jumpwidth)
    print('width: '..width..' || Height: '..height..' || jump: '..jumpwidth)
    local pwidth=width + (160/16)
    print('weird  width = '.. pwidth)
    rplatform = platform:new(pwidth,1+height,level,World,worldlayer)
    local platformbody=rplatform:getBody()
    platformbody:setLinearVelocity(groundSpeed,0)
    platformbody:setTransform(320+(jumpwidth*16),(-(200/2))+((height)*16))
    return platformbody,rplatform
end

function WorldBuilder:Start(world, layer)
    World = world
    worldlayer = layer
    -- setup ground
    ground = {}

    groundSpeed = -100

    ground[1].body, ground[1].object= WorldBuilder:randomPlatform(1,1,1)
    ground[1]:setTransform(-310,(-(200/2)))
    ground[1].body, ground[1].object= WorldBuilder:randomPlatform(0,0,0)
    ground[2]:setTransform(0,(-(200/2)))
    ground[1].body, ground[1].object= WorldBuilder:randomPlatform(0,0,0)
    ground[3]:setTransform(320,(-(200/2)))

    --[[-- GROUND 1 ligt aan het begin links uit het scherm
    -- GROUND 2 ligt aan het begin in het midden van het scherm
    -- GROUND 3 ligt aan het begin rechts uit het scherm

    ground[1] = {}
    ground[1].verts = {
        -160, 10,
        -120, 10,
        -120, -10,
        -15, -10,
        -15, 5,
        5, 5,
        20, 20,
        40, 20,
        40, -18,
        140, -18,
        140, 20,
        160, 10
    }


    -- Ground is normaal .STATIC
    ground[1].body = world:addBody( MOAIBox2DBody.KINEMATIC, -320, -60 )
    ground[1].body.tag = 'ground'
    ground[1].body:setLinearVelocity ( groundSpeed, 0 )
    ground[1].fixtures = {
        ground[1].body:addChain( ground[1].verts )
    }
    ground[1].fixtures[1]:setFriction( 0.3 )


    -- ground 2, wordt geplakt achter ground 1 voor 'endless'
    ground[2] = {}
    ground[2].verts = {
        -160, 10,
        -120, 10,
        -120, -10,
        -15, -10,
        -15, 5,
        5, 5,
        20, 20,
        40, 20,
        40, -18,
        140, -18,
        140, 20,
        160, 10
    }

    -- Ground is normaal .STATIC
    ground[2].body = world:addBody( MOAIBox2DBody.KINEMATIC, 0, -60 )
    ground[2].body.tag = 'ground'
    ground[2].body:setLinearVelocity ( groundSpeed, 0 )
    ground[2].fixtures = {
        ground[2].body:addChain( ground[2].verts )
    }
    ground[2].fixtures[1]:setFriction( 0.3 )


    -- ground 2, wordt geplakt achter ground 1 voor 'endless'
    ground[3] = {}
    ground[3].verts = {
        -160, 10,
        -120, 10,
        -120, -10,
        -15, -10,
        -15, 5,
        5, 5,
        20, 20,
        40, 20,
        40, -18,
        140, -18,
        140, 20,
        160, 10
    }

    -- Ground is normaal .STATIC
    ground[3].body = world:addBody( MOAIBox2DBody.KINEMATIC, 320, -60 )
    ground[3].body.tag = 'ground'
    ground[3].body:setLinearVelocity ( groundSpeed, 0 )
    ground[3].fixtures = {
        ground[3].body:addChain( ground[3].verts )
    }
    ground[3].fixtures[1]:setFriction( 0.3 )]]
end




------------------------------------------
-----------Update function----------------
------------------------------------------
--no param
--when registerd gets called from thread

function WorldBuilder.Update()

    local g1x, g1y = ground[1]:getPosition()

    jumpcorrection = 0
    if(g1x<=-320) then
        ground[1]:destroy()
        ground[1]=ground[2]
        ground[2]=ground[3]
        ground[3] = nil
        width = math.random(0,5)
        ground[3]=WorldBuilder:randomPlatform(width, math.random(0,2), math.random(0,6)+jumpcorrection)
        jumpcorrection=width
    end

    --[[local g2x, g2y = ground[2].body:getPosition()
    local g3x, g3y = ground[3].body:getPosition()

    if g1x < -320 then
        print(g1x)
        ground[1].body:setTransform(320, -60)
    end

    if g2x < - 320 then
        print(g2x)
        ground[2].body:setTransform(320, -60)
    end

    if g3x < -320 then
        print(g3x)
        ground[3].body:setTransform(320, -60)
    end]]

end










return WorldBuilder

