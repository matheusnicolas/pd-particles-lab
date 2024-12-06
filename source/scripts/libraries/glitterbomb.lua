local pd <const> = playdate
local gfx <const> = pd.graphics
local cos <const> = math.cos
local sin <const> = math.sin
local rad <const> = math.rad
local random <const> = math.random

--todo make local?
function lerp(starting, ending, percent)
    local amt = starting + (ending - starting) * percent
    return amt
end

--todo: allow for other spawning patterns besides random
local newRandomForce = { x = 0, y = 0 }

local function forceRandomRange(angle, range, force)
    angle = angle + range * (random() - 0.5)
    local x = cos(rad(angle))
    local y = sin(rad(angle))
    newRandomForce.x = x * force
    newRandomForce.y = y * force
    return newRandomForce
end

class('Particle').extends()

function Particle.new(newParticle)
    return Particle(newParticle)
end

function Particle:init(newParticle)
    self.active = true
    self.position = { x = 0, y = 0 }
    self.velocity = { x = 0, y = 0 }
    self.position.x = newParticle.position.x
    self.position.y = newParticle.position.y
    self.velocity.x = newParticle.velocity.x
    self.velocity.y = newParticle.velocity.y
    self.size = newParticle.size or 1
    self.skipped = 0
    self.lifetime = 0
end

function Particle:setActive(state)
    self.active = state
end

function Particle:addForce(force)
    self.velocity.x += force.x
    self.velocity.y += force.y
end

function Particle:update()
    self.lifetime += delta
    self.position.x += self.velocity.x * delta
    self.position.y += self.velocity.y * delta
    --todo: implement a sprite version
    -- self.sprite:moveTo(self.position.x//1,self.position.y//1)
end

class('BaseEmitter').extends()
function BaseEmitter.new(newEmitter)
    return BaseEmitter(newEmitter)
end

function BaseEmitter:init(newEmitter)
    newEmitter = newEmitter or {}

    self.position = newEmitter.position or { x = 0, y = 0 }
    self.velocity = newEmitter.velocity or { x = 0, y = 0 }

    self.emissionRate = newEmitter.emissionRate or 1
    self.emissionForce = newEmitter.emissionForce or 0
    self.emitterWidth = newEmitter.emitterWidth or 0
    self.emissionAngle = newEmitter.emissionAngle or 270
    self.emissionSpread = newEmitter.emissionSpread or 0

    self.particles = {}
    self.particleIndex = 1

    self.burstParticles = {}

    self.particleLifetime = newEmitter.particleLifetime or 1
    self.particleUpdateDelay = newEmitter.particleUpdateDelay or 0

    self.startSize = newEmitter.startSize or 1
    self.endSize = newEmitter.endSize or self.startSize
    self.startOpacity = newEmitter.startOpacity or 1
    self.endOpacity = newEmitter.endOpacity or self.startOpacity

    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)

    self.randomScale = newEmitter.randomScale or 1
    self.inheritVelocity = newEmitter.inheritVelocity or true
    self.gravity = newEmitter.gravity or 9.8
    self.worldScale = newEmitter.worldScale or 50

    self.spawning = newEmitter.spawning or false
    self.spawnTime = 0

    --"holder" variables to avoid creating tables every frame (sometimes multiple times)
    self.newParticleParameters = { position = { x = 0, y = 0 }, velocity = { x = 0, y = 0 }, size = 0 }
    self.newForce = { x = 0, y = 0 }
    self.newGravity = { x = 0, y = 0 }
    self.newBurstForce = { x = 0, y = 0 }
end

--emitter settings
function BaseEmitter:setPosition(pos)
    self.position = pos
end

function BaseEmitter:setVelocity(v)
    self.velocity = v
end

function BaseEmitter:setEmissionRate(rate)
    self.emissionRate = rate
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)
end

function BaseEmitter:setEmissionForce(force)
    self.emissionForce = force
end

function BaseEmitter:setEmitterWidth(width)
    self.emitterWidth = width
end

function BaseEmitter:setEmissionAngle(angle)
    self.emissionAngle = angle
end

function BaseEmitter:setEmissionSpread(spread)
    self.emissionSpread = spread
end

--particle settings
function BaseEmitter:setParticleLifetime(life)
    self.particleLifetime = life
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)
end

function BaseEmitter:setParticleUpdateDelay(delay)
    self.particleUpdateDelay = delay
end

--these are only used for generating sprite sheets
function BaseEmitter:setParticleSize(startSize, endSize)
    --todo: allow for initial scaling of particle (maybe per particle?)
    self.startSize = startSize
    self.endSize = endSize or startSize
    --not necessary for image particles
    if self.startSize ~= self.endSize then
        self.animateSize = true
    end
end

function BaseEmitter:setParticleOpacity(startO, endO)
    --todo: allow for initial opacity of particle (maybe per particle?)
    self.startOpacity = startO
    self.endOpacity = endO or startO
end

--other settings

function BaseEmitter:setRandomScale(scale)
    self.randomScale = scale
end

function BaseEmitter:setInheritVelocity(iv)
    self.inheritVelocity = iv
end

function BaseEmitter:setGravity(g)
    self.gravity = g
end

function BaseEmitter:setWorldScale(scale)
    self.worldScale = scale
end

function BaseEmitter:pause()
    self.spawning = false
end

function BaseEmitter:play()
    self.spawnTime = 0
    self.spawning = true
end

--particle emitter functions

function BaseEmitter:generateParticleParameters(spawnForce)
    local spawnOffset = (random() - 0.5) * self.emitterWidth * self.worldScale
    local perpAngle = rad(self.emissionAngle + 90)
    local randomSize = 1 + random() * (self.randomScale - 1)
    if randomSize < 1 then randomSize = 1 end

    self.newParticleParameters.position.x = self.position.x + cos(perpAngle) * spawnOffset
    self.newParticleParameters.position.y = self.position.y + sin(perpAngle) * spawnOffset
    self.newParticleParameters.velocity.x = spawnForce.x
    self.newParticleParameters.velocity.y = spawnForce.y
    self.newParticleParameters.size = randomSize
    return self.newParticleParameters
end

function BaseEmitter:spawnParticle(spawnForce)
    local particleParameters = self:generateParticleParameters(spawnForce)
    local newParticle

    --if all particles have been spawned, reuse existing particles rather than spawn new ones
    if #self.particles >= self.maxParticles then
        newParticle = self.particles[self.particleIndex]
        newParticle.position.x = particleParameters.position.x
        newParticle.position.y = particleParameters.position.y
        newParticle.velocity.x = particleParameters.velocity.x
        newParticle.velocity.y = particleParameters.velocity.y

        newParticle.lifetime = 0
        newParticle.lastUpdate = 0

        newParticle.randomScale = particleParameters.randomScale

        newParticle:setActive(true)

        self.particleIndex += 1
        if self.particleIndex > self.maxParticles then
            self.particleIndex = 1
        end
    else
        --could add a overriding function here to determine which kind of particle is spawned
        self.particles[#self.particles + 1] = Particle.new(particleParameters)
        newParticle = self.particles[#self.particles]
    end

    if self.inheritVelocity then
        newParticle.velocity.x += self.velocity.x
        newParticle.velocity.y += self.velocity.y
    end
end

function BaseEmitter:burstSpawn(spawnForce)
    local particleParameters = self:generateParticleParameters(spawnForce)
    self.burstParticles[#self.burstParticles + 1] = Particle.new(particleParameters)
end

function BaseEmitter:burst(burstSize)
    for i = 1, burstSize do
        randomForce = forceRandomRange(self.emissionAngle, self.emissionSpread, self.emissionForce)
        self.newBurstForce.x = randomForce.x * self.worldScale
        self.newBurstForce.y = randomForce.y * self.worldScale
        self:burstSpawn(self.newBurstForce)
    end
end

function BaseEmitter:updateParticles()
    local currentParticle
    local currentParticleTime
    local randomForce
    local numParticles

    local emitterDelay = self.particleUpdateDelay
    local emitterLifetime = self.particleLifetime

    --todo: allow more forces than gravity
    self.newGravity.x = 0
    self.newGravity.y = self.gravity * self.worldScale * delta

    for i = #self.particles, 1, -1 do
        currentParticle = self.particles[i]
        if currentParticle.active then
            currentParticleTime = currentParticle.lifetime
            lifePercent = currentParticleTime / emitterLifetime
            if lifePercent >= 1 then
                --remove particles if the maximum decreased or spawner has been stopped (otherwise save for pooling)
                if #self.particles > self.maxParticles or self.spawning ~= true then
                    table.remove(self.particles, i)

                    if i < self.particleIndex then
                        self.particleIndex -= 1
                    end

                    if self.particleIndex > #self.particles then
                        self.particleIndex = 1
                    end
                else
                    currentParticle:setActive(false)
                end
            else
                if currentParticle.skipped >= emitterDelay then
                    currentParticle.skipped = 0
                    self.newForce.x = self.newGravity.x * (1 + emitterDelay)
                    self.newForce.y = self.newGravity.y * (1 + emitterDelay)
                    currentParticle:addForce(self.newForce)
                else
                    currentParticle.skipped += 1
                end
                currentParticle:update()
                if currentParticle.lifetime > emitterLifetime then currentParticle.lifetime = emitterLifetime end
            end
        end
    end

    for i = #self.burstParticles, 1, -1 do
        currentParticle = self.burstParticles[i]
        currentParticleTime = currentParticle.lifetime
        lifePercent = currentParticleTime / self.particleLifetime
        if lifePercent >= 1 then
            --remove particles if the maximum decreased or spawner has been stopped (otherwise save for pooling)
            table.remove(self.burstParticles, i)
        else
            if currentParticle.skipped >= self.particleUpdateDelay then
                currentParticle.skipped = 0
                self.newForce.x = self.newGravity.x * (1 + self.particleUpdateDelay)
                self.newForce.y = self.newGravity.y * (1 + self.particleUpdateDelay)
                currentParticle:addForce(self.newForce)
            else
                currentParticle.skipped += 1
            end
            currentParticle:update()
            if currentParticle.lifetime > self.particleLifetime then currentParticle.lifetime = self.particleLifetime end
        end
    end
end

function BaseEmitter:update()
    self.spawnTime += delta
    self.position.x += self.velocity.x * delta
    self.position.y += self.velocity.y * delta

    if self.spawnTime > (1 / self.emissionRate) and self.spawning then
        numParticles = math.floor(self.spawnTime * self.emissionRate)
        for i = 1, numParticles do
            --todo: allow for other spawn patterns
            randomForce = forceRandomRange(self.emissionAngle, self.emissionSpread, self.emissionForce)
            self.newForce.x = randomForce.x * self.worldScale
            self.newForce.y = randomForce.y * self.worldScale

            self:spawnParticle(self.newForce)
        end

        self.spawnTime -= numParticles / self.emissionRate
    end

    self:updateParticles()
end

class('ParticleEmitter').extends(BaseEmitter)

function ParticleEmitter.new(image, newEmitter)
    return ParticleEmitter(image, newEmitter)
end

function ParticleEmitter:init(image, newEmitter)
    ParticleEmitter.super.init(self, newEmitter)
    self.image = image
    self.drawOffset = { x = 0, y = 0 }
    self.drawOffset.x, self.drawOffset.y = self.image:getSize()
    self.drawOffset.x /= 2
    self.drawOffset.y /= 2
end

--todo draw from oldest to newest
function ParticleEmitter:draw()
    for i, v in ipairs(self.particles) do
        if v.active then
            self.image:draw(v.position.x + self.drawOffset.x, v.position.y + self.drawOffset.y)
        end
    end

    for i, v in ipairs(self.burstParticles) do
        self.image:draw(v.position.x + self.drawOffset.x, v.position.y + self.drawOffset.y)
    end
end

class('AnimatedParticleEmitter').extends(ParticleEmitter)

function AnimatedParticleEmitter.new(image, newEmitter)
    return AnimatedParticleEmitter(image, newEmitter)
end

function AnimatedParticleEmitter:init(image, newEmitter)
    AnimatedParticleEmitter.super.init(self, image, newEmitter)
    self.drawOffset.x, self.drawOffset.y = self.image:getImage(1):getSize()
    self.drawOffset.x /= 2
    self.drawOffset.y /= 2

    self.numFrames = self.image:getLength()
end

function AnimatedParticleEmitter:setNumFrames(num)
    self.numFrames = num
end

function AnimatedParticleEmitter:draw()
    local totalFrames = self.numFrames
    local currentFrame
    local currentImage
    for i, v in ipairs(self.particles) do
        if v.active then
            currentFrame = lerp(1, totalFrames, v.lifetime / self.particleLifetime) // 1
            currentImage = self.image:getImage(currentFrame)
            currentImage:draw(v.position.x - self.drawOffset.x, v.position.y - self.drawOffset.y)
        end
    end

    for i, v in ipairs(self.burstParticles) do
        currentFrame = lerp(1, totalFrames, v.lifetime / self.particleLifetime) // 1
        currentImage = self.image:getImage(currentFrame)
        currentImage:draw(v.position.x - self.drawOffset.x, v.position.y - self.drawOffset.y)
    end
end

circle = 0
square = 1

local filled

local function drawSquare(self, x, y, r)
    gfx.drawRect(x, y, r, r)
end

local function drawFilledSquare(self, x, y, r)
    gfx.fillRect(x, y, r, r)
end

local function drawCircle(self, x, y, r)
    gfx.drawCircleInRect(x, y, r, r)
end

local function drawFilledCircle(self, x, y, r)
    gfx.fillCircleInRect(x, y, r, r)
end

class('ShapeEmitter').extends(BaseEmitter)
function ShapeEmitter.new(newEmitter)
    return ShapeEmitter(newEmitter)
end

function ShapeEmitter:init(newEmitter)
    ShapeEmitter.super.init(self, newEmitter)

    newEmitter = newEmitter or {}

    self.shape = newEmitter.shape or circle
    self.filled = newEmitter.filled or false
    self.color = newEmitter.color or gfx.kColorBlack
    self.lineWidth = newEmitter.lineWidth or 1

    self.animateSize = false
    if self.startSize ~= self.endSize then
        self.animateSize = true
    end

    self.anchorPoint = newEmitter.anchorPoint or { x = .5, y = .5 }

    self:updateDrawFunc()
end

function ShapeEmitter:setShape(shape, filled)
    self.shape = shape
    self.filled = filled
    updateDrawFunc()
end

function ShapeEmitter:setColor(color)
    self.color = color
end

function ShapeEmitter:setLineWidth(lineWidth)
    self.lineWidth = lineWidth
end

function ShapeEmitter:setAnchorPoint(anchorX, anchorY)
    self.anchorPoint.x = anchorX
    self.anchorPoint.y = anchorY
end

function ShapeEmitter:updateDrawFunc()
    if self.shape == circle then
        if self.filled then
            self.drawFunc = drawFilledCircle
        else
            self.drawFunc = drawCircle
        end
    elseif self.shape == square then
        if self.filled then
            self.drawFunc = drawFilledSquare
        else
            self.drawFunc = drawSquare
        end
    end
end

function ShapeEmitter:drawParticle(particle)
    local lifePercent
    local currentSize = self.startSize

    local offsetX = currentSize * self.anchorPoint.x
    local offsetY = currentSize * self.anchorPoint.y

    local pPos = particle.position
    local pSize = particle.size
    local pLife = particle.lifetime
    --if animating size, update the particles size based on its lifetime
    if self.animateSize then
        lifePercent = pLife / self.particleLifetime
        currentSize = lerp(self.startSize, self.endSize, lifePercent)
    end

    --if particle sizes might be different, update the draw offset
    if self.animateSize or self.randomize then
        offsetX = currentSize * pSize * self.anchorPoint.x
        offsetY = currentSize * pSize * self.anchorPoint.y
    end

    self:drawFunc(pPos.x - offsetX, pPos.y - offsetY, currentSize * pSize)
end

function ShapeEmitter:draw()
    --todo: remove color?
    gfx.setColor(self.color)
    gfx.setLineWidth(self.lineWidth)
    for i, v in ipairs(self.particles) do
        if v.active then
            self:drawParticle(v)
        end
    end

    for i, v in ipairs(self.burstParticles) do
        self:drawParticle(v)
    end
end
