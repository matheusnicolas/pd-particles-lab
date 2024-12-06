local pd = playdate
local gfx = pd.graphics
local darkMode = true
local toggleButtonInstance = nil

class('InputManager').extends(gfx.sprite)

function InputManager:init()
    toggleButtonInstance = ToggleButton()
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
        toggleButtonInstance:changeMode(darkMode)
    end
end
