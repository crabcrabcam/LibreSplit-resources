process("dsda-doom", "first")

--Runs on dsda-doom 0.29.3, Windows version (under Wine)
--Probably broken in current state
--https://github.com/kraflab/dsda-doom/releases/tag/v0.29.3

local current = {gametic, gamestate, map, attempt, isMenuOpen, isDemoPlaying}
local old = {gametic, gamestate, map, attempt, isMenuOpen, isDemoPlaying}
local isLoading = false

local settings = {
    rta = false
}

local vars = {
    totalGameTime = 0
}
    

function startup()
    if not settings.rta then
        isLoading = true
    end
end

function state()
    old = shallow_copy_tbl(current)

    current.gametic = readAddress('int', 0xB11090)
    current.gamestate = readAddress('int', 0x88BE90)
    current.map = readAddress('int', 0xB34F40)
    current.attempt = readAddress('int', 0x970B88)
    current.isMenuOpen =readAddress('int', 0xB32C4C)
    current.isDemoPlaying = readAddress('int', 0xB35164)
    
    print_tbl(current)
end


function start()
    if current.isMenuOpen == 0 and current.isDemoPlaying == 0 and current.gamestate == 0 then
        vars.totalGameTime = 0
        
        if (settings.rta) then
            vars.totalGameTime = vars.totalGameTime + 1
        end
        
        return true
    
    end
end

function reset()
    if not settings.rta and (current.attempt > old.attempt) then
        vars.totalGameTime = 0
        return true
    end
    
    if settings.rta then
        --This reset probably doesn't work, original has no reset on RTA mode. This starts the split later than when starting fresh. I guess you're intended to stop the timer manually before restarting. Will see if I can think of any way to reset
        if current.isMenuOpen == 0 and current.isDemoPlaying == 0 and current.gamestate == 0 and old.gametic < 2 then
            return true
        end
    end
    
    return false
end

function split()
    if (current.gamestate == 1) and (old.gamestate == 0) then
        if settings.rta then
            vars.totalGameTime = vars.totalGameTime + 1
        else
            vars.totalGameTime = vars.totalGameTime + (current.gametic / 35)
        end
        
        return true
    end
        
end

function gameTime()
    if settings.rta then
        delta = current.gametic - old.gametic
        if delta < 0 then
            delta = 0
        end
        
        vars.totalGameTime = vars.totalGameTime + delta
        
        return TimeSpan.fromSeconds(vars.totalGameTime / 35)
    else
        if (current.gamestate ~= 0 and old.gamestate ~= 0) then
            return TimeSpan.fromSeconds(vars.totalGameTime)
        end
        
        return TimeSpan.fromSeconds(vars.totalGameTime + current.gametic / 35)
    end
end

function update()
    
end

function isLoading()
    return isLoading
end
