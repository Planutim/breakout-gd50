
-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1 --all colors the same in this row
ALTERNATE = 2 -- alternate colors
SKIP = 3 -- skip every other block
NONE = 4 -- no blocks this row


LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1,5)

    -- same with columns
    local numColumns = math.random(7,13)

    numColumns = numColumns %2 ==0 and (numColumns+1) or numColumns

    -- highest possible spawned brick color in this leve; ensure we -- don't go above 3
    local highestTier = math.min(3, math.floor(level/5))

    -- highest color of the highest tier
    local highestColor = math.min(5, level % 5 + 3)


    -- lay out bricks such that they touch each other and fill the space
    for y=1, numRows do

        --whether we want to enable skipping for this row
        local skipPattern = math.random(1,2) == 1 and true or false

        --whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1,2) == 1 and true or false

        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        --used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        --used only when we want to alternate a block, for alternative pattern
        local alternateFlag = math.random(2) ==1 and true or false

        -- solid color we'll use if we're not alternating
        local solidColor = math.random(1,highestColor)
        local solidTier = math.random(0, highestTier)


        for x=1, numColumns do

            -- if skipping is turned on and we're on a skip iteration
            if skipPattern and skipFlag then
                skipFlag = not skipFlag
                goto continue
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end

            b = Brick(
                -- x-coord
                (x-1)
                --decrement x by 1
                *32
                +8 -- 8 pixels of padding; we can fit 13cols+16 pixels total
                + (13-numColumns)*16, -- left-side padding

                y*16 -- just use y*16, since we need top padding anyway
            )
            -- if we're alternating, figure out which color/tier we're on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating and we made it here, use solid color/tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end


            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end
    -- return bricks
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end