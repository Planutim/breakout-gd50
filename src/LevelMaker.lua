LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1,5)

    -- same with columns
    local numColumns = math.random(7,13)

    -- lay out bricks such that they touch each other and fill the space
    for y=1, numRows do
        for x=1, numColumns do
            b = Brick(
                -- x-coord
                (x-1)
                --decrement x by 1
                *32
                +8 -- 8 pixels of padding; we can fit 13cols+16 pixels total
                + (13-numColumns)*16, -- left-side padding

                y*16 -- just use y*16, since we need top padding anyway
            )

            table.insert(bricks, b)
        end
    end
    return bricks
end