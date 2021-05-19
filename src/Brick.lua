Brick = Class{}


function Brick:init(x,y)
    -- used for coloring and score calculation
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width  = 32
    self.height = 16

    -- used to determine whether this brick should be rendered
    self.inPlay = true
end


function Brick:hit()

    gSounds['brick-hit-2']:play()
    
    self.inPlay = false
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'],
        -- multiply color by 4 (-1) to get our color offset, then
        -- add tier to draw the correct tier and color brick onto
        -- the screen
        gFrames['bricks'][1+((self.color-1)*4)+self.tier],
        self.x,self.y)
    end
end