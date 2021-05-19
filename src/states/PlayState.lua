PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()
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

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end
