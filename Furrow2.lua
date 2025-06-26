_addon.name = 'Furrow2'
_addon.author = 'Linktri & Algar'
_addon.version = '3.0'
_addon.language = 'english'
_addon.commands = {'furrow2', 'fu'}

require('logger')
require('coroutine')

-- Configuration
local config = {
    default_seed = "Revival Root",
    default_fertilizer = "Miracle Mulch",
    harvest_time = 3600, -- 1 hour in seconds
    fertilize_wait_time = 1800, -- 30 minutes in seconds
    reminder_intervals = {3000, 2400, 1800, 1200, 600}, -- 50, 40, 30, 20, 10 minutes
    fertilize_reminder_intervals = {1200, 600, 300}, -- 20, 10, 5 minutes
    max_target_attempts = 10,
    debug_mode = false
}

-- State management
local state = {
    running = false,
    current_action = nil,
    start_time = nil,
    fertilize_time = nil,
    furrows_found = {false, false, false}
}

-- Logging functions
local function log(message, color)
    color = color or 200
    windower.add_to_chat(color, 'Furrow2: ' .. message)
end

local function debug_log(message)
    if config.debug_mode then
        log('[DEBUG] ' .. message, 8)
    end
end

local function error_log(message)
    log('[ERROR] ' .. message, 167)
end

-- Enhanced targeting with retry limit and better error handling
local function find_furrow(furrow_name, furrow_number)
    debug_log('Searching for ' .. furrow_name)
    local attempts = 0
    
    while attempts < config.max_target_attempts do
        -- Clear current target first
        windower.send_command('target clear')
        coroutine.sleep(0.3)
        
        -- Tab to next target
        windower.send_command('setkey TAB down')
        coroutine.sleep(0.3)
        windower.send_command('setkey TAB up')
        coroutine.sleep(0.5)
        
        local target = windower.ffxi.get_mob_by_target('t')
        
        if target and target.name == furrow_name then
            log('Found ' .. furrow_name)
            state.furrows_found[furrow_number] = true
            return true
        elseif target == nil then
            debug_log('No target found, attempt ' .. (attempts + 1))
        else
            debug_log('Found ' .. (target.name or 'unknown target') .. ', continuing search')
        end
        
        attempts = attempts + 1
        coroutine.sleep(0.5)
    end
    
    error_log('Could not find ' .. furrow_name .. ' after ' .. config.max_target_attempts .. ' attempts')
    return false
end

-- Improved plant function with error checking
local function plant_seed(seed_name)
    seed_name = seed_name or config.default_seed
    log('Planting ' .. seed_name)
    
    -- Simple inventory check - we'll let the game handle the "item not found" error
    -- since properly checking item names in FFXI inventory is complex
    debug_log('Attempting to use ' .. seed_name)
    
    -- Use the item
    windower.chat.input('/item "' .. seed_name .. '" <t>')
    coroutine.sleep(3)
    
    -- Navigate through the planting menu
    local menu_steps = {
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 3},
        {key = 'escape', delay = 1}
    }
    
    for _, step in ipairs(menu_steps) do
        windower.send_command('setkey ' .. step.key .. ' down')
        coroutine.sleep(0.1)
        windower.send_command('setkey ' .. step.key .. ' up')
        coroutine.sleep(step.delay)
    end
    
    return true
end

-- New fertilize function
local function fertilize_furrow(fertilizer_name)
    fertilizer_name = fertilizer_name or config.default_fertilizer
    log('Fertilizing with ' .. fertilizer_name)
    
    debug_log('Attempting to use ' .. fertilizer_name)
    
    -- Use the fertilizer item
    windower.chat.input('/item "' .. fertilizer_name .. '" <t>')
    coroutine.sleep(3)
    
    -- Navigate through the fertilizing menu
    local menu_steps = {
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 3},
        {key = 'escape', delay = 1}
    }
    
    for _, step in ipairs(menu_steps) do
        windower.send_command('setkey ' .. step.key .. ' down')
        coroutine.sleep(0.1)
        windower.send_command('setkey ' .. step.key .. ' up')
        coroutine.sleep(step.delay)
    end
    
    return true
end

-- Enhanced harvest function
local function harvest_furrow()
    log('Harvesting furrow')
    
    -- Navigate through the harvest menu
    local menu_steps = {
        {key = 'enter', delay = 3},
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 2},
        {key = 'enter', delay = 3},
        {key = 'escape', delay = 1}
    }
    
    for _, step in ipairs(menu_steps) do
        windower.send_command('setkey ' .. step.key .. ' down')
        coroutine.sleep(0.1)
        windower.send_command('setkey ' .. step.key .. ' up')
        coroutine.sleep(step.delay)
    end
end

-- Plant cycle with better error handling
local function plant_cycle(seed_name)
    if not state.running then
        error_log('Planting cycle aborted - not running')
        return false
    end
    
    state.current_action = "planting"
    local furrows = {
        {name = "Garden Furrow", number = 1},
        {name = "Garden Furrow #2", number = 2},
        {name = "Garden Furrow #3", number = 3}
    }
    
    local success_count = 0
    
    for _, furrow in ipairs(furrows) do
        if not state.running then break end
        
        log('Searching for furrow ' .. furrow.number)
        if find_furrow(furrow.name, furrow.number) then
            coroutine.sleep(1)
            if plant_seed(seed_name) then
                success_count = success_count + 1
            end
        end
        coroutine.sleep(2)
    end
    
    log('Planting complete! Successfully planted ' .. success_count .. ' out of 3 furrows.')
    state.current_action = nil
    
    -- Return true if at least one furrow was planted
    if success_count > 0 then
        return true
    else
        error_log('No furrows could be planted')
        return false
    end
end

-- New fertilize cycle
local function fertilize_cycle(fertilizer_name)
    if not state.running then
        error_log('Fertilize cycle aborted - not running')
        return false
    end
    
    state.current_action = "fertilizing"
    local furrows = {
        {name = "Garden Furrow", number = 1},
        {name = "Garden Furrow #2", number = 2},
        {name = "Garden Furrow #3", number = 3}
    }
    
    local success_count = 0
    
    for _, furrow in ipairs(furrows) do
        if not state.running then break end
        
        log('Searching for furrow ' .. furrow.number)
        if find_furrow(furrow.name, furrow.number) then
            coroutine.sleep(1)
            if fertilize_furrow(fertilizer_name) then
                success_count = success_count + 1
            end
        end
        coroutine.sleep(2)
    end
    
    log('Fertilizing complete! Successfully fertilized ' .. success_count .. ' out of 3 furrows.')
    state.current_action = nil
    
    -- Return true if at least one furrow was fertilized
    if success_count > 0 then
        return true
    else
        error_log('No furrows could be fertilized')
        return false
    end
end

-- Harvest cycle with better error handling
local function harvest_cycle()
    if not state.running then
        error_log('Harvest cycle aborted - not running')
        return false
    end
    
    state.current_action = "harvesting"
    local furrows = {
        {name = "Garden Furrow", number = 1},
        {name = "Garden Furrow #2", number = 2},
        {name = "Garden Furrow #3", number = 3}
    }
    
    local success_count = 0
    
    for _, furrow in ipairs(furrows) do
        if not state.running then break end
        
        log('Searching for furrow ' .. furrow.number)
        if find_furrow(furrow.name, furrow.number) then
            coroutine.sleep(1)
            harvest_furrow()
            success_count = success_count + 1
        end
        coroutine.sleep(2)
    end
    
    log('Harvesting complete! Successfully harvested ' .. success_count .. ' out of 3 furrows.')
    state.current_action = nil
    
    -- Return true if at least one furrow was harvested
    if success_count > 0 then
        return true
    else
        error_log('No furrows could be harvested')
        return false
    end
end

-- Enhanced main loop with fertilize cycle and updated timing
local function main_loop(seed_name, fertilizer_name)
    if not state.running then
        error_log('Main loop stopped before starting')
        return
    end
    
    log('Starting automated gardening cycle')
    state.start_time = os.time()
    
    -- Plant cycle
    if not plant_cycle(seed_name) then
        error_log('Planting failed completely, aborting cycle')
        state.running = false
        return
    end
    
    -- Fertilize cycle (immediately after planting)
    log('Starting fertilize cycle')
    if not fertilize_cycle(fertilizer_name) then
        error_log('Fertilizing failed completely, aborting cycle')
        state.running = false
        return
    end
    
    state.fertilize_time = os.time()
    
    -- Wait 30 minutes after fertilizing before harvest
    log('Waiting ' .. math.floor(config.fertilize_wait_time / 60) .. ' minutes after fertilizing before harvest')
    local elapsed = 0
    local next_reminder_index = 1
    
    while elapsed < config.fertilize_wait_time and state.running do
        coroutine.sleep(60) -- Check every minute
        elapsed = elapsed + 60
        
        -- Check for fertilize reminders
        if next_reminder_index <= #config.fertilize_reminder_intervals and 
           elapsed >= config.fertilize_reminder_intervals[next_reminder_index] then
            local remaining_minutes = math.floor((config.fertilize_wait_time - elapsed) / 60)
            log('Reminder: Harvest will begin in ' .. remaining_minutes .. ' minutes after fertilizing. Use //fu stop to cancel.')
            next_reminder_index = next_reminder_index + 1
        end
    end
    
    if not state.running then
        log('Cycle cancelled by user')
        return
    end
    
    -- Harvest cycle
    log('Beginning harvest cycle')
    if harvest_cycle() then
        log('Full cycle completed successfully!')
        -- Optionally restart the loop
        if state.running then
            coroutine.sleep(5)
            main_loop(seed_name, fertilizer_name)
        end
    else
        error_log('Harvest failed completely')
        state.running = false
    end
end

-- Status function
local function show_status()
    if state.running then
        log('Status: RUNNING')
        log('Current action: ' .. (state.current_action or 'waiting'))
        if state.start_time then
            local elapsed = os.time() - state.start_time
            log('Total elapsed time: ' .. math.floor(elapsed / 60) .. ' minutes')
        end
        if state.fertilize_time then
            local fertilize_elapsed = os.time() - state.fertilize_time
            log('Time since fertilizing: ' .. math.floor(fertilize_elapsed / 60) .. ' minutes')
        end
    else
        log('Status: STOPPED')
    end
end

-- Enhanced command handler
local function furrow_command(...)
    local args = {...}
    local command = args[1] and args[1]:lower() or ""
    
    if command == 'start' then
        if state.running then
            log('Furrow2 is already running. Use //fu stop to cancel.')
            return
        end
        
        local seed_name = args[2] or config.default_seed
        local fertilizer_name = args[3] or config.default_fertilizer
        state.running = true
        state.furrows_found = {false, false, false}
        log('Starting automated cycle with ' .. seed_name .. ' and ' .. fertilizer_name)
        main_loop(seed_name, fertilizer_name)
        
    elseif command == 'stop' or command == 'abort' then
        if state.running then
            log('Stopping all operations...')
            state.running = false
            state.current_action = nil
            coroutine.sleep(1)
            log('Stopped successfully')
        else
            log('No operations running')
        end
        
    elseif command == 'plant' then
        if state.running then
            log('Another operation is running. Use //fu stop first.')
            return
        end
        
        local seed_name = args[2] or config.default_seed
        state.running = true
        log('Starting single planting cycle with ' .. seed_name)
        plant_cycle(seed_name)
        state.running = false
        
    elseif command == 'fertilize' then
        if state.running then
            log('Another operation is running. Use //fu stop first.')
            return
        end
        
        local fertilizer_name = args[2] or config.default_fertilizer
        state.running = true
        log('Starting single fertilize cycle with ' .. fertilizer_name)
        fertilize_cycle(fertilizer_name)
        state.running = false
        
    elseif command == 'harvest' then
        if state.running then
            log('Another operation is running. Use //fu stop first.')
            return
        end
        
        state.running = true
        log('Starting single harvest cycle')
        harvest_cycle()
        state.running = false
        
    elseif command == 'status' then
        show_status()
        
    elseif command == 'config' then
        if args[2] == 'debug' then
            config.debug_mode = not config.debug_mode
            log('Debug mode: ' .. (config.debug_mode and 'ON' or 'OFF'))
        elseif args[2] == 'seed' and args[3] then
            config.default_seed = args[3]
            log('Default seed changed to: ' .. config.default_seed)
        elseif args[2] == 'fertilizer' and args[3] then
            config.default_fertilizer = args[3]
            log('Default fertilizer changed to: ' .. config.default_fertilizer)
        elseif args[2] == 'waittime' and args[3] then
            local minutes = tonumber(args[3])
            if minutes and minutes > 0 and minutes <= 180 then
                config.fertilize_wait_time = minutes * 60 -- Convert minutes to seconds
                log('Wait time changed to: ' .. minutes .. ' minutes')
            else
                error_log('Wait time must be between 1 and 180 minutes')
            end
        elseif args[2] == 'show' then
            log('Current Configuration:')
            log('  Default seed: ' .. config.default_seed)
            log('  Default fertilizer: ' .. config.default_fertilizer)
            log('  Wait time: ' .. math.floor(config.fertilize_wait_time / 60) .. ' minutes')
            log('  Debug mode: ' .. (config.debug_mode and 'ON' or 'OFF'))
        else
            log('Config options:')
            log('  debug - Toggle debug mode')
            log('  seed <name> - Set default seed')
            log('  fertilizer <name> - Set default fertilizer')
            log('  waittime <minutes> - Set wait time (1-180 minutes)')
            log('  show - Display current settings')
        end
        
    elseif command == 'help' or command == '' then
        log('Available commands:')
        log('  start [seed] [fertilizer] - Begin automated cycle')
        log('  stop/abort - Stop all operations')
        log('  plant [seed] - Single planting cycle')
        log('  fertilize [fertilizer] - Single fertilize cycle')
        log('  harvest - Single harvest cycle')
        log('  status - Show current status')
        log('  config - Configuration options')
        log('Usage: //fu <command> or //furrow2 <command>')
        log('Default seed: ' .. config.default_seed)
        log('Default fertilizer: ' .. config.default_fertilizer)
        log('Wait time: ' .. math.floor(config.fertilize_wait_time / 60) .. ' minutes')
        
    else
        error_log('Unknown command: ' .. command .. '. Use //fu help for available commands.')
    end
end

-- Register the command
windower.register_event('addon command', furrow_command)

-- Cleanup on unload
windower.register_event('unload', function()
    if state.running then
        log('Addon unloading - stopping all operations')
        state.running = false
    end
end)

-- Initial message
log('Furrow2 v3.0 loaded by Linktri & Algar. Use //fu help for commands.')
notice('Please ensure at least one Garden Furrow is unlocked for proper operation.')