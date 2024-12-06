local pd <const> = playdate
local gfx <const> = pd.graphics

class('ToggleButton').extends(AnimatedSprite)

function ToggleButton:init()
    local imagetable = gfx.imagetable.new("assets/images/toggle-button")
    ToggleButton.super.init(self, imagetable)
    self:moveTo(350, 220)
    self:setZIndex(1000)
    self:addState("light_mode", 1, 1)
    self:addState("dark_mode", 2, 2)
    self.currentState = "light_mode"
    self:playAnimation()
    self:add()
end

function ToggleButton:update()
    self:updateAnimation()
end

function ToggleButton:changeMode(isDarkMode)
    if isDarkMode then
        self:changeState("light_mode")
    else
        self:changeState("dark_mode")
    end
end
