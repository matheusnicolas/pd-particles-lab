-- Corelibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/animation"

-- libraries
import "scripts/libraries/glitterbomb"

-- manager
import "scripts/manager/particlesManager"
import "scripts/manager/inputManager"

delta = 0
lastTime = 0

local pd = playdate
local gfx = pd.graphics

pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

ParticlesManager.init()
