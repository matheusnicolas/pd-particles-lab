import "global"

local pd <const> = playdate
local gfx <const> = pd.graphics

function pd.update()
    gfx.clear()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(0, 228)
    ParticlesManager.update()
end
