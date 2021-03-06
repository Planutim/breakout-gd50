PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.highScores = params.highScores
    self.score = params.score
    self.ball = params.ball
    self.level = params.level
    self.recoverPoints = params.recoverPoints

    self.ball.dx = math.random(-200,200)
    self.ball.dy = math.random(-50,-60)
    -- self.paddle = Paddle()
    -- self.paused = false
    
    -- self.ball = Ball(1)

    -- self.ball.dx = math.random(-200,200)
    -- self.ball.dy = math.random(-50, -60)

    -- self.ball.x = VIRTUAL_WIDTH / 2 -4
    -- self.ball.y = VIRTUAL_HEIGHT - 42

    -- self.bricks = LevelMaker.createMap()
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
        -- raise ball above paddle in case it goes below it, then reverse dy
        self.ball.y = self.ball.y - 8
        self.ball.dy = -self.ball.dy

        -- tweak angle of bounce based on where it hits the baddle
        
        -- if we hit the paddle on its left side while moving left..

        if self.ball.x < self.paddle.x + (self.paddle.width/2) and 
            self.paddle.dx <0 then
                self.ball.dx = -50 + -(8*(self.paddle.x+self.paddle.width/2 - self.ball.x))

                -- else if we hit the paddle on its right side while moving right
            elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.ball.dx = 50 + (8*math.abs(self.paddle.x+self.paddle.width/2-self.ball.x))
            end

        gSounds['paddle-hit']:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        -- only check collision if we're in play
        if brick.inPlay and self.ball:collides(brick) then
            brick:hit()

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end


            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    ball = self.ball,
                    highScores = self.highScores,
                    recoverPoints = self.recoverPoints
                })
            end

            self.score = self.score + 10
            --[[
                we check to see if the opposite side of our velocity
                is outside of the brick
                if it is, we trigger a collision on that side
        else we're within the X
            ]]

            --left edge; only check if we're moving right
            if self.ball.x + 2 < brick.x and self.ball.dx >0 then
                --flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x -8 
            --right edge
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx<0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + 32

            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - 8
            -- bottom edge if no X collisions or top collision,
            -- last posibility
            else
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + 16
            end

            --slightly increase y velocity
            self.ball.dy = self.ball.dy * 1.015
            -- only allow colliding with one brick, for corners
            break
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health -1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
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

    --render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    renderScore(self.score)
    renderHealth(self.health)
    
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        
        love.graphics.printf("PAUSED",0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end
    return true
end