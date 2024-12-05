local pd = playdate
local gfx = pd.graphics

class('InputManager').extends(gfx.sprite)

local darkMode = true

function InputManager:init()
    self:add()
end

function InputManager:update()
    if pd.buttonJustPressed(pd.kButtonUp) then
        ParticlesManager.emit(200, 120, 5, "example-1")
    elseif pd.buttonJustPressed(pd.kButtonLeft) then
        ParticlesManager.emit(200, 120, 12, "example-2")
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        ParticlesManager.emit(200, 120, 5, "example-3")
    elseif pd.buttonJustPressed(pd.kButtonA) then
        if darkMode then
            gfx.setBackgroundColor(gfx.kColorWhite)
        else
            gfx.setBackgroundColor(gfx.kColorBlack)
        end
        darkMode = not darkMode
    end
end
