PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()
    self.paused = false
    
    self.ball = Ball(1)

    self.ball.dx = math.random(-200,200)
    self.ball.dy = math.random(-50, -60)

    self.ball.x = VIRTUAL_WIDTH / 2 -4
    self.ball.y = VIRTUAL_HEIGHT - 42

    self.bricks = LevelMaker.createMap()
end


function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        self.ball.dy = -self.ball.dy
        gSounds['paddle-hit']:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        -- only check collision if we're in play
        if brick.inPlay and self.ball:collides(brick) then
            brick:hit()
        end
    end


    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()

    for _, brick in pairs(self.bricks) do
        brick:render()
    end
    
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        
        love.graphics.printf("PAUSED",0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
    end
end