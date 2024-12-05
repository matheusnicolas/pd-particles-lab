local pd <const> = playdate
local gfx <const> = pd.graphics

ParticlesManager = {}

local particles = {}
local currentSpawner = nil
local currentParticle = "initial"

local particlesTable = {
    ["example-1"] = 1,
    ["example-2"] = 2,
    ["example-3"] = 3
}

local append = table.insert

function ParticlesManager.init()
    InputManager()
    ParticlesManager.slotMachineParticle()
    ParticlesManager.multiplyParticle()
    ParticlesManager.cardDestroyedParticle()
end

function ParticlesManager.update()
    delta = (pd.getCurrentTimeMilliseconds() - lastTime) / 1000
    lastTime = pd.getCurrentTimeMilliseconds()
    currentSpawner:update()
    currentSpawner:draw()
end

function ParticlesManager.switchParticle(particle)
    currentSpawner:pause()
    currentSpawner = particles[particle]
    currentSpawner:play()
end

function ParticlesManager.emit(x, y, amount, particle)
    if currentParticle ~= particle then
        currentParticle = particle
        ParticlesManager.switchParticle(particlesTable[particle])
    end
    currentSpawner:setPosition({ x = x, y = y })
    currentSpawner:burst(amount) -- 8 for shape
end

function ParticlesManager.flush()
    for i = 1, #particles do
        if particles[i] ~= nil then particles[i]:remove() end
    end
    particles = {}
end

function ParticlesManager.slotMachineParticle()
    local circleFilled = ShapeEmitter.new({ shape = 0, filled = true, color = gfx.kColorXOR, lineWidth = 4, randomScale = 2 })
    circleFilled:setEmissionRate(0)
    circleFilled:setParticleLifetime(.3)
    circleFilled:setParticleUpdateDelay(1)
    circleFilled:setEmissionForce(5)
    circleFilled:setEmitterWidth(360)
    circleFilled:setEmitterWidth(0)
    circleFilled:setEmissionSpread(360)
    circleFilled:setEmissionAngle(90)
    circleFilled:setGravity(0)
    circleFilled:setInheritVelocity(false)
    circleFilled:setParticleSize(42, 0)
    append(particles, circleFilled)
    currentSpawner = particles[1]
    currentSpawner:play()
end

function ParticlesManager.multiplyParticle()
    local circleNotFilled = ShapeEmitter.new({ shape = 0, filled = true, color = gfx.kColorXOR, lineWidth = 3.5, randomScale = 2 })
    circleNotFilled:setEmissionRate(0)
    circleNotFilled:setParticleLifetime(.3)
    circleNotFilled:setParticleUpdateDelay(1)
    circleNotFilled:setEmissionForce(3)
    circleNotFilled:setEmitterWidth(360)
    circleNotFilled:setEmitterWidth(0)
    circleNotFilled:setEmissionSpread(360)
    circleNotFilled:setEmissionAngle(90)
    circleNotFilled:setGravity(0)
    circleNotFilled:setInheritVelocity(false)
    circleNotFilled:setParticleSize(12, 12)
    append(particles, circleNotFilled)
end

function ParticlesManager.cardDestroyedParticle()
    local filledSquare = ShapeEmitter.new({ shape = 1, filled = true, color = gfx.kColorXOR, lineWidth = 4, randomScale = 2 })
    filledSquare:setEmissionRate(0)
    filledSquare:setParticleLifetime(.3)
    filledSquare:setParticleUpdateDelay(1)
    filledSquare:setEmissionForce(5)
    filledSquare:setEmitterWidth(360)
    filledSquare:setEmitterWidth(0)
    filledSquare:setEmissionSpread(360)
    filledSquare:setEmissionAngle(90)
    filledSquare:setGravity(0)
    filledSquare:setInheritVelocity(false)
    filledSquare:setParticleSize(14, 0)
    append(particles, filledSquare)
end
