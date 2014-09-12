--
-- Created by IntelliJ IDEA.
-- User: Lars
-- Date: 9/12/2014
-- Time: 09:33
-- To change this template use File | Settings | File Templates.
--

local tools = {}

local textureCache = {}

-- char code for fonts
local charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|/?.,<>!~`@#$%^&*\'":;'



local function textureFromCache ( name, width, height )
    if textureCache [ name ] == nil then
        textureCache[name] = MOAIGfxQuad2D.new ()
        textureCache[name]:setTexture ( name )
        textureCache[name]:setRect ( -width/2, -height/2, width/2, height/2 )
    end
    return textureCache [ name ]
end

function tools:newprop ( filename, width, height )

    local gfxQuad = self:loadimage ( filename, width, height )
    local prop = MOAIProp2D.new ()
    prop:setDeck ( gfxQuad )
    prop.filename = filename
    return prop
end

function tools:loadimage( filename, width, height )
    if width == nil or height == nil then
        local img = MOAIImage.new ()
        img:load ( filename )
        width, height = img:getSize ()
        img = nil
    end

    local gfxQuad = textureFromCache ( filename, width, height )
    return gfxQuad
end



function tools:registerFont (fontpath, fontScale)
    local font = MOAIFont.new()
    font:load(fontpath)
    font:preloadGlyphs( charCode, math.ceil( 4 * fontScale ), 72 )
    return font
end

return tools

