--SR3 City Lua file 


-- Gameplay Choice IDs -
-- these should match values from level_scripts.cpp
MISSION_06_CHOICE = 0
MISSION_22_CHOICE = 1
MISSION_21_CHOICE = 2

M06_CHOICE_BLOWN_TOWER = true;
M06_CHOICE_BRANDED_TOWER = false;
M22_CHOICE_KILLBANE_KILL = true;
M22_CHOICE_KILLBANE_ESCAPE = false;
M21_CHOICE_KILLBANE_UNMASKED = true;
M21_CHOICE_KILLBANE_NOT_UNMASKED = false;

function sr3_city_init()

end


function sr3_city_main()

end

-- ALL FOLLOWING COOP SKIP FUNCTIONS CALLED FROM CODE (+++MUST RETURN IMMEDIATLY+++)

-- Teleport players to a mission start node
--
-- mission_name:	(string) name of the mission start node (should be same as mission name)
-- skip_teleport:	(boolean) true to basically skip this whole function, nil or not true will run it
--
function sr3_teleport_mission_start(mission_name, skip_teleport)
	if skip_teleport == nil or skip_teleport ~= true then
		-- send them to the mission start
		local vehicle_exit = true
		local offset_x = 0.5
		teleport_to_object(LOCAL_PLAYER, mission_name, vehicle_exit, nil, offset_x)
		-- remote player not on top of player
		offset_x = -0.5
		teleport_to_object(REMOTE_PLAYER, mission_name, vehicle_exit, nil, offset_x)
	end
end

function m03_coop_skip( )
	crib_purchasing_unlock( )
end

function m06_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m06", skip_teleport)
	-- Update the world state based on the choice that they made during the mission
	if game_choice_get_state( MISSION_06_CHOICE ) == M06_CHOICE_BRANDED_TOWER then
		city_zone_swap("tower_saints")
	else
		city_zone_swap("tower_dmg")
	end
	-- kill the building interior either way
	city_zone_swap("m6")

	-- Set Hood ('Henry Steel Mills') to Spawn THE BALL from now on as ambient
	spawn_override_change_hood_alternate_spawning("HOOD_DT_01", true)

	if not mission_is_complete( "m07" ) then
		-- make sure we unlocked it
		mission_unlock( "m07" )
		mission_set_next_mission( "m07" )
	end
end

function m10_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m10", skip_teleport)
	set_stag_active(true)
	spawn_override_change_hood_alternate_spawning("HOOD_DT_02", true)
	
	city_zone_swap("thermext1") -- Thermopolye moves to south of DT
	city_zone_swap("therm2") -- This swap just the interior trigger and volume for thermext1.  Those two should be consolidated.
	city_zone_swap("stag") -- STAG shows up in DT
	traffic_disable_drawbridge_area(34, true) -- Disables splines on road through Sunset Park that STAG cordons off
end

function m13_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m13", skip_teleport)
	city_zone_swap("hq_dmg") -- HQ is damaged during this mission, swap it in
end

function m14_coop_skip( )
	-- Set Saints to be 'Hated' following this mission
	set_saints_hated(true)
end

function m17_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m17", skip_teleport)
	-- Set STAG Lockdown spawning for downtown hoods to True (Hood DT_02 still missing change, waiting on Chris N. solution to having two alternate spawn groups)
	spawn_override_change_hood_alternate_spawning("HOOD_DT_02", true)
	spawn_override_change_hood_alternate_spawning("HOOD_DT_03", true)
	
	-- Set STAG Lockdown area as immediate notoriety area
	set_stag_notoriety_area_active(true)
	
	-- Post mission swaps, Thermopolye destroyed and STAG take over downtown
	city_zone_swap("thermext1", false)
	city_zone_swap("therm2", false) -- This swap just the interior trigger and volume for thermext1.  Those two should be consolidated.
	city_zone_swap("therm3_dst")
	city_zone_swap("lockdown")
	
	-- Disable Traffic Splines Over Drawbridges
	traffic_disable_drawbridge_area(1, true)
	traffic_disable_drawbridge_area(2, true)
	traffic_disable_drawbridge_area(7, true)
	traffic_disable_drawbridge_area(8, true)
	traffic_disable_drawbridge_area(9, true)
	traffic_disable_drawbridge_area(10, true)
	traffic_disable_drawbridge_area(11, true)
	traffic_disable_drawbridge_area(12, true)
	traffic_disable_drawbridge_area(13, true)
	traffic_disable_drawbridge_area(14, true)
	traffic_disable_drawbridge_area(15, true)
	traffic_disable_drawbridge_area(16, true)
	traffic_disable_drawbridge_area(17, true)
	traffic_disable_drawbridge_area(18, true)
	traffic_disable_drawbridge_area(19, true)
	traffic_disable_drawbridge_area(20, true)
	traffic_disable_drawbridge_area(21, true)
	traffic_disable_drawbridge_area(22, true)
	traffic_disable_drawbridge_area(23, true)
	traffic_disable_drawbridge_area(24, true)
	traffic_disable_drawbridge_area(25, true)
	traffic_disable_drawbridge_area(27, true)
	traffic_disable_drawbridge_area(28, true)
	traffic_disable_drawbridge_area(29, true)
	traffic_disable_drawbridge_area(30, true)
	traffic_disable_drawbridge_area(31, true)
	traffic_disable_drawbridge_area(32, true)
	traffic_disable_drawbridge_area(33, true)
end

function m18_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m18", skip_teleport)
	-- Set Hood ('Arapice Island') to Spawn Zombies from now on as ambient
	spawn_override_change_hood_alternate_spawning("HOOD_ZOMBIE", true)
	
	-- Set Drawbridge Traffic Splines to Arapice Island as 'Disabled'
	traffic_disable_drawbridge_area(3, true)
	traffic_disable_drawbridge_area(4, true)
	traffic_disable_drawbridge_area(5, true)
	traffic_disable_drawbridge_area(6, true)
	traffic_disable_drawbridge_area(26, true)
	
	-- Swap the Zombie zone
	city_zone_swap("chemcrash")
	city_zone_swap("zombies")
end

function m22_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m22", skip_teleport)
	if game_choice_get_state( MISSION_22_CHOICE ) == M22_CHOICE_KILLBANE_KILL then
		mission_unlock( "m23" )
		city_zone_swap("rubble") -- Player went for Killbane, statue got blowed up
	else
		mission_unlock( "m24" )
	end
end

function m23_m24_coop_skip(skip_teleport)
	sr3_teleport_mission_start("m23", skip_teleport)
	
	-- Set STAG Inactive
	set_stag_active(false)
	
	-- Remove Lockdown Spawning from Downtown Hoods
	spawn_override_change_hood_alternate_spawning("HOOD_DT_02", false)
	spawn_override_change_hood_alternate_spawning("HOOD_DT_03", false)
	
	-- Set Traffic to Be Enabled Across Lockdown Drawbridges Again
	traffic_disable_drawbridge_area(7, false)
	traffic_disable_drawbridge_area(8, false)
	traffic_disable_drawbridge_area(9, false)
	traffic_disable_drawbridge_area(10, false)
	traffic_disable_drawbridge_area(11, false)
	traffic_disable_drawbridge_area(12, false)
	traffic_disable_drawbridge_area(13, false)
	traffic_disable_drawbridge_area(14, false)
	traffic_disable_drawbridge_area(15, false)
	traffic_disable_drawbridge_area(16, false)
	traffic_disable_drawbridge_area(17, false)
	traffic_disable_drawbridge_area(18, false)
	traffic_disable_drawbridge_area(19, false)
	traffic_disable_drawbridge_area(20, false)
	traffic_disable_drawbridge_area(21, false)
	traffic_disable_drawbridge_area(22, false)
	traffic_disable_drawbridge_area(23, false)
	traffic_disable_drawbridge_area(24, false)
	traffic_disable_drawbridge_area(25, false)
	traffic_disable_drawbridge_area(27, false)
	traffic_disable_drawbridge_area(28, false)
	traffic_disable_drawbridge_area(29, false)
	traffic_disable_drawbridge_area(30, false)
	traffic_disable_drawbridge_area(31, false)
	traffic_disable_drawbridge_area(32, false)
	traffic_disable_drawbridge_area(33, false)
	traffic_disable_drawbridge_area(34, false)
	
	-- Disable Downtown Notoriety Areas
	set_stag_notoriety_area_active(false)
	
	-- Set Saints to be beloved again
	set_saints_hated(false)
	
	-- Perform zone swaps
	city_zone_swap("hq_dmg", DISABLE) -- restore saints HQ
	
	-- Maybe allow you to play through again
	mission_maybe_uncomplete_m22()
end

function sh02_coop_skip(skip_teleport)
	sr3_teleport_mission_start("sh02", skip_teleport)
	crib_unlock_strongold("Crib_BDSM")
end

function sh03_coop_skip(skip_teleport)
	sr3_teleport_mission_start("sh03", skip_teleport)
	crib_unlock_strongold("Crib_Nuke")
end

function sh04_coop_skip(skip_teleport)
	sr3_teleport_mission_start("sh04", skip_teleport)
	crib_unlock_strongold("Crib_3Count")
end
