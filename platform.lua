local class=require 'external/middleclass'
local toolsclass = require 'tools'
--
-- Created by IntelliJ IDEA.
-- User: Lars
-- Date: 9/16/2014
-- Time: 10:40
-- To change this template use File | Settings | File Templates.
--

platform = class('platform')

function platform:initialize(width, height, level, texture, world, layer)
    self.platformBody = world:addBody(MOAIBox2DBody.KINEMATIC)
    self.platformBody:addRect(-((width/2)*16),-((height/2)*16),((width/2)*16),((height/2)*16))
    self.ground = {}
    self.overlay = {}
    self.groundloc = 'Textures/'..level..'/Ground.png'
    self.overlayloc ='Textures/'..level..'/Overlay.png'

    for i = 1, width,1 do
        self.overlay[i] = toolsclass:newprop(self.overlayloc,16,16)
        self.overlay[i]:setParent(self.platformBody)

    end


    for k=1,width*height,1 do
        self.ground[k] = toolsclass:newprop(self.groundloc,16,16)
        self.ground[k]:setParent(self.platformBody)
        layer:insertProp(self.ground[k])
    end

    local count=1
    local startw = (-((width/2)*16))+8
    local starth = (-((height/2)*16))+8
    for i=1,height,1 do
        for j = 1, width, 1 do
            self.ground[count]:setLoc(startw+((j-1)*16),starth+((i-1)*16))
            count = count+1
        end
    end
    for i = 1, width , 1 do
        self.overlay[i]:setLoc(startw+((i-1)*16),8)
        layer:insertProp(self.overlay[i])
    end


    return self.platformBody

end

function platform:getBody()
    return self.platformBody
end




