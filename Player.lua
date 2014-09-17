local Player = {}
--
-- Created by IntelliJ IDEA.
-- User: Lars
-- Date: 9/12/2014
-- Time: 14:33
-- To change this template use File | Settings | File Templates.
--

local World
local tools=require('tools')
local player = {}

---------------------------------------
--------Initialize function------------
---------------------------------------
--Needs to be called before everything else
--related to the Player

function Player:Start(world)
    World=world

            -- setup playerclass

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
            player.body.tag = 'playerclass'
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

            -- playerclass foot sensor
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
            return player


end

-------------------------------------
--------Create prop function---------
-------------------------------------
--Creates prop and returns it
--this should be used to insert prop in a layer

function Player:getProp(filename)

    local prop = tools:newprop(filename,28,28)
    prop:setParent(player.body)
    return prop

end

------------------------------------------
-----------Update function----------------
------------------------------------------
--no param
--when registerd gets called from thread

function Player:Update()

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

        local playerx, playery = player.body:getPosition()
        if(playerx <-100) then
            local xtravel = ((playerx*-1)-100)^2
            player.body:setLinearVelocity( 20, dy )
            end
end

-------------------------------------------
---------Input Callback--------------------
-------------------------------------------
--Callback for playermovement
--Should be registerd to input module

function Player.MovementCallBack()
    if ( player.onGround or not player.doubleJumped ) then
        player.body:setLinearVelocity( player.body:getLinearVelocity(), 0 )
        player.body:applyLinearImpulse( 0, 100 )
        if not player.onGround then
            player.doubleJumped = true
        end
    end
end







return Player