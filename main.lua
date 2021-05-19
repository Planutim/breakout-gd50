require 'src/Dependencies'


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Breakout')

    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }


    love.graphics.setFont(gFonts['small'])

    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
        }

        -- Quads we will generate for all of our textures; Quads allow
        -- us to show only part of a texture and not the entire thing
        gFrames = {
            ['paddles'] = GenerateQuadsPaddles(gTextures['main'])
        }

        push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            vsync = true,
            fullscreen = false,
            resizable = true
        })

        gSounds = {
            ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static')                     
        }


    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end
    }

    gStateMachine:change('start')

    love.keyboard.keysPressed = {}
end

function love.resize(w,h)
    push:resize(w,h)
end


function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push:apply('start')

    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
    -- draw at 0,0 coords
    0,0,
    -- no rotation
    0,
    --scale factors on x and y axis so it fills the screen
    VIRTUAL_WIDTH / (backgroundWidth-1), VIRTUAL_HEIGHT / (backgroundHeight-1))

    gStateMachine:render()

    displayFPS()

    push:apply('end')
end


function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 5,5)
end