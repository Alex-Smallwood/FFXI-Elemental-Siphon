-- elemental_siphon.lua
-- Automatically performs Elemental Siphon when MP reaches 30% or lower.
--
-- Sequence:
--   1. Release the current avatar or spirit, if one is summoned
--   2. Summon the elemental spirit matching the current Vana'diel day
--   3. Use Elemental Siphon
--   4. Release the elemental spirit
--
-- The addon checks Elemental Siphon's actual in-game recast.
-- Failed attempts are limited to once every 30 seconds.
--
-- Manual command: //es

_addon.name = 'elemental_siphon'
_addon.author = 'Alex (Soulkiller)'
_addon.version = '1.4.1'
_addon.command = 'es'

require('coroutine')

local res = require('resources')

local mp_threshold = 30
local retry_seconds = 30

local running = false
local next_attempt_time = 0
local last_mp_check = 0

local spirit_by_day = {
    Firesday     = 'Fire Spirit',
    Earthsday    = 'Earth Spirit',
    Watersday    = 'Water Spirit',
    Windsday     = 'Air Spirit',
    Iceday       = 'Ice Spirit',
    Lightningday = 'Thunder Spirit',
    Lightsday    = 'Light Spirit',
    Darksday     = 'Dark Spirit',
}

local elemental_spirits = {
    ['Fire Spirit'] = true,
    ['Earth Spirit'] = true,
    ['Water Spirit'] = true,
    ['Air Spirit'] = true,
    ['Ice Spirit'] = true,
    ['Thunder Spirit'] = true,
    ['Light Spirit'] = true,
    ['Dark Spirit'] = true,
}

local blocked_towns = {
    ['Southern San d\'Oria'] = true,
    ['Northern San d\'Oria'] = true,
    ['Port San d\'Oria'] = true,

    ['Bastok Mines'] = true,
    ['Bastok Markets'] = true,
    ['Port Bastok'] = true,
    ['Metalworks'] = true,

    ['Windurst Waters'] = true,
    ['Windurst Walls'] = true,
    ['Port Windurst'] = true,
    ['Windurst Woods'] = true,
    ['Heavens Tower'] = true,

    ['Ru\'Lude Gardens'] = true,
    ['Upper Jeuno'] = true,
    ['Lower Jeuno'] = true,
    ['Port Jeuno'] = true,

    ['Selbina'] = true,
    ['Mhaura'] = true,
    ['Kazham'] = true,
    ['Norg'] = true,
    ['Rabao'] = true,
    ['Nashmau'] = true,
    ['Aht Urhgan Whitegate'] = true,
    ['Tavnazian Safehold'] = true,
    ['Western Adoulin'] = true,
    ['Eastern Adoulin'] = true,
    ['Chocobo Circuit'] = true,
    ['Mog Garden'] = true,
}

local function get_current_spirit()
    local info = windower.ffxi.get_info()

    if not info or info.day == nil then
        return nil, nil
    end

    local day = res.days[info.day]
    local day_name = day and day.english
    local spirit = day_name and spirit_by_day[day_name]

    return spirit, day_name
end

local function get_siphon_recast_id()
    for _, ability in pairs(res.job_abilities) do
        if ability.english == 'Elemental Siphon' then
            return ability.recast_id
        end
    end

    return nil
end

local function get_siphon_ability_id()
    for id, ability in pairs(res.job_abilities) do
        if ability.english == 'Elemental Siphon' then
            return id
        end
    end

    return nil
end

local siphon_recast_id = get_siphon_recast_id()
local siphon_ability_id = get_siphon_ability_id()

local function get_siphon_recast()
    if not siphon_recast_id then
        return nil
    end

    local recasts = windower.ffxi.get_ability_recasts()

    if not recasts then
        return nil
    end

    return recasts[siphon_recast_id] or 0
end

local function retry_remaining()
    return math.max(0, next_attempt_time - os.time())
end

local function release_siphon_spirit(attempt)
    attempt = attempt or 1

    local pet = windower.ffxi.get_mob_by_target('pet')

    windower.send_command('input /pet "Release" <me>')

    if attempt < 5 then
        coroutine.schedule(function()
            local current_pet = windower.ffxi.get_mob_by_target('pet')

            if current_pet then
                release_siphon_spirit(attempt + 1)
            else
                running = false
            end
        end, 1.0)
    else
        coroutine.schedule(function()
            running = false
        end, 1.0)
    end
end

local function is_blocked_town()
    local info = windower.ffxi.get_info()

    if not info then
        return true
    end

    -- Never attempt the sequence inside a Mog House.
    if info.mog_house then
        return true
    end

    if info.zone == nil then
        return true
    end

    local zone = res.zones[info.zone]
    local zone_name = zone and zone.english

    if not zone_name then
        return true
    end

    return blocked_towns[zone_name] == true
end

local function can_run()
    if running then
        return false
    end

    -- Prevent repeated failed commands from flooding the chat.
    if os.time() < next_attempt_time then
        return false
    end

    local player = windower.ffxi.get_player()

    if not player or not player.vitals then
        return false
    end

    if player.vitals.hp <= 0 then
        return false
    end

    if player.main_job ~= 'SMN' and player.sub_job ~= 'SMN' then
        return false
    end

    if is_blocked_town() then
        return false
    end

    -- Use Elemental Siphon's actual in-game recast.
    local recast = get_siphon_recast()

    if recast == nil or recast > 0 then
        return false
    end

    return true
end

local function run_siphon(manual)
    if not can_run() then
        if manual then
            local recast = get_siphon_recast()
            local retry = retry_remaining()

            if recast and recast > 0 then
                windower.add_to_chat(
                    123,
                    '[Elemental Siphon] Ability recast remaining: '
                        ..math.ceil(recast)..' seconds.'
                )
            elseif retry > 0 then
                windower.add_to_chat(
                    123,
                    '[Elemental Siphon] Retry available in '
                        ..retry..' seconds.'
                )
            end
        end

        return
    end

    local spirit, day_name = get_current_spirit()

    if not spirit then
        windower.add_to_chat(
            123,
            '[Elemental Siphon] Could not determine the current day spirit.'
        )

        next_attempt_time = os.time() + retry_seconds
        return
    end

    running = true

    -- Whether the sequence succeeds or fails, do not try again for 30 seconds.
    -- A successful Siphon will also be blocked by its actual in-game recast.
    next_attempt_time = os.time() + retry_seconds

    windower.add_to_chat(
        207,
        '[Elemental Siphon] '
            ..day_name..': summoning '..spirit..'.'
    )

    local pet = windower.ffxi.get_mob_by_target('pet')
    local summon_delay = 0.2

    -- Release the current avatar or spirit only when one is present.
    if pet then
        windower.send_command('input /pet "Release" <me>')
        summon_delay = 2.0
    end

    -- Summon the elemental spirit for the current Vana'diel day.
    coroutine.schedule(function()
        windower.send_command(
            'input /ma "'..spirit..'" <me>'
        )
    end, summon_delay)

    -- Use Elemental Siphon after the spirit has been summoned.
	coroutine.schedule(function()
		windower.send_command(
			'input /ja "Elemental Siphon" <me>'
		)

		coroutine.schedule(function()
			release_siphon_spirit(1)
		end, 9.0)
	end, summon_delay + 6.0)
    
end

-- Check MP approximately once per second.
windower.register_event('prerender', function()
    local current_time = os.time()

    if current_time == last_mp_check then
        return
    end

    last_mp_check = current_time

    local info = windower.ffxi.get_info()

    if not info or not info.logged_in then
        return
    end

    local player = windower.ffxi.get_player()

    if not player or not player.vitals then
        return
    end

    local current_mp = player.vitals.mp
    local maximum_mp = player.vitals.max_mp

    if not current_mp or not maximum_mp or maximum_mp <= 0 then
        return
    end

    local mp_percent = current_mp / maximum_mp * 100

    if mp_percent <= mp_threshold then
        run_siphon(false)
    end
end)

windower.register_event('addon command', function(command)
    command = command and command:lower() or ''

    if command == '' or command == 'go' or command == 'siphon' then
        run_siphon(true)
    else
        windower.add_to_chat(
            207,
            '[Elemental Siphon] Use: //es'
        )
    end
end)

windower.register_event('zone change', function()
    running = false

    -- Give the new area time to load before any automatic attempt.
    next_attempt_time = os.time() + retry_seconds
end)
