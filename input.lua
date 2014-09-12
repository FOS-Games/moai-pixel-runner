--
-- Created by IntelliJ IDEA.
-- User: Lars
-- Date: 9/12/2014
-- Time: 09:50
-- To change this template use File | Settings | File Templates.
--

local input = {}

local pointerX, pointerY = 0, 0
--local previousX, previousY = 0, 0

local tapDownFunctions = {}

local keyDownFunctions = {}

local keyUpFunctions={}

function input:registerTapDownFunction ( tapDownFunction, functionOwner )
    tapDownFunctions [ tapDownFunction ] = functionOwner
end

function input:unregisterTapDownFunction ( tapDownFunction )
    tapDownFunctions [ tapDownFunction ] = nil
end

function input:registerKeyDownFunction (keyDownFunction,keyDown, functionOwner)
    keyDownFunctions [keyDownFunction] = {["owner"]=functionOwner,["key"]=keyDown}
end

function input:registerKeyUpFunction(keyUpFunction,keyDown, functionOwner)
    keyUpFunctions [keyUpFunction] = {["owner"]=functionOwner,["key"]=keyDown}
end

function input:unregisterKeyDownFunction (keyDownFunction)
    keyDownFunctions [keyDownFunction] = nil
end

function input:unregisterKeyUpFunction(keyUpFunction)
    keyUpFunctions [keyUpFunction] = nil
end

local function handleKeyDown(keydown)
    for func, owner in pairs ( keyDownFunctions ) do
        if (keydown == owner["key"]) then
            func (owner)
        end
    end
end

local function handleKeyUp(keyUp)
    for func, owner in pairs ( keyUpFunctions ) do
        if (keyUp == owner["key"]) then
            func (owner)
        end
    end
end

local function handleClickOrTouchDown(x, y)
    for func, owner in pairs ( tapDownFunctions ) do
        func (owner, x , y)
    end
end

function input:initialize()
    print("initialize")
    --set Moai keyboard input events
    print(MOAIInputMgr.device.keyboard)
    print(MOAIInputMgr.device.pointer)
    if MOAIInputMgr.device.keyboard then
        MOAIInputMgr.device.keyboard:setCallback(function(key, down)
            if down then
                handleKeyDown(key)
            else
                handleKeyUp(key)
            end

        end)

    elseif MOAIInputMgr.device.pointer then
        local pointerDown = false
        MOAIInputMgr.device.mouseLeft:setCallback(
            function(isMouseDown)
                if(isMouseDown) then
                    handleClickOrTouchDown(MOAIInputMgr.device.pointer:getLoc())
                    pointerDown = true;
                else
                    pointerDown = false;
                end
            end
        )
        MOAIInputMgr.device.pointer:setCallback (
            function(x,y)
                if pointerDown then
                    --self:handleClickOrTouchMove(x,y)
                end
            end
        )
    else
        MOAIInputMgr.device.touch:setCallback (
            function ( eventType, idx, x, y, tapCount )
                if eventType == MOAITouchSensor.TOUCH_DOWN then
                    handleClickOrTouchDown(x,y)
                elseif eventType == MOAITouchSensor.TOUCH_MOVE then
                    --handleClickOrTouchMove(x,y)
                elseif eventType == MOAITouchSensor.TOUCH_UP then
                    --handleClickOrTouchUp(x,y)
                end
            --end
            end
        )
    end
    
end




return input
