Hud_healthbars_status = {	
	
	--Hostiles Info
	hostiles = { },
	
	hostile_elements = {
		grp_h = 0, fill_h = 0, border_h = 0,
	},
	
	--animations
	anims = { },
	
	anim_elements = {
		healthbar_anim_h = 0, 
	},
	
	handles = {},
}

USE_OBJECT_HANDLE_KEY = 0

COLOR_RED				= 0
COLOR_BLUE				= 1
COLOR_NEUTRAL			= 2

function hud_healthbars_init()
	--mini healthbar
	local h = -1
	Hud_healthbars_status.hostile_elements.grp_h = vint_object_find("health_mini_grp")
	vint_set_property(Hud_healthbars_status.hostile_elements.grp_h, "visible", false)
	
	h = Hud_healthbars_status.hostile_elements.grp_h
	Hud_healthbars_status.hostile_elements.fill_h = vint_object_find("health_mini_fill", h)
	Hud_healthbars_status.hostile_elements.border_h = vint_object_find("health_mini_border", h)
	Hud_healthbars_status.hostile_elements.grit_h = vint_object_find("health_mini_grit", h)
	Hud_healthbars_status.handles.mp_arrow_h = vint_object_find("mp_arrow", h)
	Hud_healthbars_status.handles.mp_name_h = vint_object_find("mp_name", h)
	Hud_healthbars_status.handles.overhead_cash_h = vint_object_find("overhead_cash", h)
	Hud_healthbars_status.handles.race_pos_h = vint_object_find("race_pos", h)
	
	--large healthbar
	Hud_healthbars_status.handles.health_large_grp = vint_object_find("health_large_grp")
	vint_set_property(Hud_healthbars_status.handles.health_large_grp, "visible", false)
	
	h = Hud_healthbars_status.handles.health_large_grp
	Hud_healthbars_status.handles.health_large_fill = vint_object_find("health_large_fill", h)
	Hud_healthbars_status.handles.health_large_border = vint_object_find("health_large_border", h)
	
	--animation
	Hud_healthbars_status.anim_elements.healthbar_anim_h = vint_object_find("health_mini_fade_out")
	--large
	Hud_healthbars_status.handles.health_large_fade_out = vint_object_find("health_large_fade_out")
	--overhead_cash fade out
	Hud_healthbars_status.handles.overhead_cash_fade_out = vint_object_find("overhead_cash_fade_out")
	
	--Pause animations
	vint_set_property(Hud_healthbars_status.anim_elements.healthbar_anim_h, "is_paused", true)
	--large
	vint_set_property(Hud_healthbars_status.handles.health_large_fade_out, "is_paused", true)
	--overhead_cash fade out
	vint_set_property(Hud_healthbars_status.handles.overhead_cash_fade_out, "is_paused", true)
		
	--Health Bar Subscription
	vint_datagroup_add_subscription("sr2_local_player_septic", "insert", "hud_healthbars_update")
	vint_datagroup_add_subscription("sr2_local_player_septic", "update", "hud_healthbars_update")
	vint_datagroup_add_subscription("sr2_local_player_septic", "remove", "hud_healthbars_update")
end

function hud_healthbars_cleanup()
end

function tint_element( handle, color )
	if color == COLOR_RED then
		vint_set_property( handle, "tint", 0.71, 0, 0 )
	elseif color == COLOR_BLUE then
		vint_set_property( handle, "tint", COLOR_SAINTS_PURPLE.R, COLOR_SAINTS_PURPLE.G, COLOR_SAINTS_PURPLE.B )
		--SR2 COOP Blue
		--vint_set_property( handle,	"tint", 0.27, 0.51, 0.84 )
	else
		vint_set_property( handle, "tint", 1, 1, 1 )
	end
end

function tint_healthbar( hostile, color )
	tint_element( hostile.fill_h, color )
	tint_element( hostile.mp_name_h, color )
	tint_element( hostile.mp_arrow_h, color )
	tint_element( hostile.cash_h, color )
	tint_element( hostile.race_pos_h, color )
end

function hud_healthbars_update(di_h, event)

	local no_object_key, object_handle, screen_x, screen_y, z_depth,
		distance, health_pct, name, overhead_cash, race_position,
		is_visible, color, is_big, health_full_alpha, mp_respawn_invulnerable,
		show_bar, show_name, show_arrow, show_cash, show_race_pos, alpha = vint_dataitem_get(di_h)
	
	local decoded_name = vint_debug_decode_wide_string( name )	
	
	local key = ( no_object_key == USE_OBJECT_HANDLE_KEY ) and object_handle or no_object_key
	
	if event == "update" then
	
		--check to see if there is a hostile indicator for the key
		if Hud_healthbars_status.hostiles[key] == nil then
			
			--Doesn't currently exist so create the hostile indicator
			local grp_h = vint_object_clone(Hud_healthbars_status.hostile_elements.grp_h)
			local fill_h = vint_object_find("health_mini_fill", grp_h)
			local border_h = vint_object_find("health_mini_border", grp_h)
			local grit_h = vint_object_find("health_mini_grit", grp_h)
			local mp_name_h = vint_object_find("mp_name", grp_h)
			local mp_arrow_h = vint_object_find("mp_arrow", grp_h)
			local overhead_cash_h = vint_object_find("overhead_cash", grp_h)
			local race_pos_h = vint_object_find("race_pos", grp_h)
			
			--Create the animation clones			
			local anim_clone_0 = vint_object_clone(Hud_healthbars_status.anim_elements.healthbar_anim_h )
			local anim_0_fade = vint_object_find("mini_alpha_twn", anim_clone_0)
			vint_set_property(anim_clone_0, "is_paused", true)
			vint_set_property(anim_0_fade, "target_handle",	grp_h)
			
			
			local invulnerable_anim_0 = 0 
			if MP_enabled == true then
				
				--Create invulnerable animation clones				
				invulnerable_anim_0 = vint_object_clone(vint_object_find("health_anim_1"))
				
				---   0 = 191; 112; 0  ->> 0 = 255; 255; 147
				local h = vint_object_find("health_flash_0_tween", invulnerable_anim_0)
				vint_set_property(h, "start_value", 0.749, 0.439, 0)
				vint_set_property(h, "end_value", 1, 1, 0.576)
				vint_set_property(h, "loop_mode", "bounce")
				vint_set_property(h, "target_handle", fill_h)
				
				--Destroy the other tween :)
				local h = vint_object_find("health_flash_1_tween", invulnerable_anim_0)
				vint_object_destroy(h)
				
				if mp_respawn_invulnerable == false then
					vint_set_property(invulnerable_anim_0, "is_paused", true)
				else
					lua_play_anim(invulnerable_anim_0, 0)
				end
			end
			
			
			--Create the animation clones			
			local cash_fade_clone = vint_object_clone(Hud_healthbars_status.handles.overhead_cash_fade_out)
			local cash_fade_1 = vint_object_find("over_cash_fade_1", cash_fade_clone)
			local cash_fade_2 = vint_object_find("over_cash_fade_2", cash_fade_clone)
			vint_set_property(cash_fade_clone, "is_paused", true)
			vint_set_property(cash_fade_1, "target_handle",	overhead_cash_h)
			vint_set_property(cash_fade_2, "target_handle",	overhead_cash_h)

			-- Assign the handles (these values shouldn't change after creation)
			Hud_healthbars_status.hostiles[key] = {
				--dont delete items from this table................
				grp_h = grp_h,
				fill_h = fill_h,
				border_h = border_h,
				grit_h = grit_h,
				health_pct = health_pct ,
				anim_clone_0 = anim_clone_0,
				anim_0_fade = anim_0_fade,
				invulnerable_anim_0 = invulnerable_anim_0,
				mp_respawn_invulnerable = mp_respawn_invulnerable,
				cash_fade_clone = cash_fade_clone,
				cash_fade_1 = cash_fade_1,
				cash_fade_2 = cash_fade_2,
				distance = distance,
				is_visible = is_visible,
				screen_x = screen_x,
				screen_y = screen_y,
				z_depth = z_depth,
				mp_arrow_h = mp_arrow_h,
				mp_name_h = mp_name_h, 
				overhead_cash_h = overhead_cash_h,
				overhead_cash = overhead_cash,
				race_pos_h = race_pos_h,
				race_position = race_position,
			}
			
			-- Convenience local var
			local hostile = Hud_healthbars_status.hostiles[key]
						
			if is_big then
				-- Different fill graphics
				vint_set_property(hostile.fill_h, "image", "uhd_ui_hud_meter_fill")
				vint_set_property(hostile.border_h, "image", "uhd_ui_hud_meter_border")
				vint_set_property(hostile.grit_h, "image", "uhd_ui_hud_meter_grit")	
			end
			
--			debug_print( "vint_healthbars", "Creating healthbar for " .. decoded_name .. " key: " .. key .. "\n" )
		end
		
		-- Convenience local var
		local hostile = Hud_healthbars_status.hostiles[key]
		
		-- This is all debug calculations, so comment this out if you don't need to see it
		do
			local current_visible = vint_get_property( hostile.grp_h, "visible" )
			local current_bar = vint_get_property( hostile.fill_h, "visible" )
			local current_name = vint_get_property( hostile.mp_name_h, "visible" )
			local current_arrow = vint_get_property( hostile.mp_arrow_h, "visible" )
			local current_cash = vint_get_property( hostile.overhead_cash_h, "visible" )
			local current_race_pos = vint_get_property( hostile.race_pos_h, "visible" )
			
			if current_visible ~= is_visible or
				current_bar ~= show_bar or
				current_name ~= show_name or
				current_arrow ~= show_arrow or
				current_cash ~= show_cash or
				current_race_pos ~= show_race_pos then
				
				--[[
				debug_print( "vint_healthbars", "Updating healthbar for " .. decoded_name ..
					" key: " .. key ..
					( is_visible and " visible " or "" ) ..
					( show_bar and " bar " or "" ) ..
					( show_name and " name " or "" ) ..
					( show_arrow and " arrow " or "" ) ..
					( show_cash and " cash " or "" ) ..
					( show_race_pos and " race_pos " or "" ) ..
					"\n" )	]]
			end
		end
		
		if is_big then
			--big bar
			local w, h = element_get_actual_size(Hud_healthbars_status.handles.health_large_fill)
			vint_set_property(hostile.fill_h, "source_se", w * health_pct, h)
			vint_set_property(hostile.border_h, "source_se", (w * health_pct) + 12 * 3, h + 12 * 3)
		else
			--regular bar
			local w, h = element_get_actual_size(Hud_healthbars_status.hostile_elements.fill_h)
			vint_set_property(hostile.fill_h, "source_se", w * health_pct, h)
			vint_set_property(hostile.border_h, "source_se", (w * health_pct) + 12 * 3, h + 12 * 3)
		end
		
		--debug_print("vint", "health_full_alpha " .. var_to_string(health_full_alpha) .. "\n")
		
		if health_pct ~= hostile.health_pct and health_pct == 0 then
			if health_full_alpha == false then
				lua_play_anim(hostile.anim_clone_0, 0)
			end
		end
		
		if health_full_alpha == true then
			vint_set_property(hostile.grp_h, "alpha", 1)
		end
		
		-- Change visibility for: whole group
		vint_set_property(hostile.grp_h, "visible", is_visible)
		
		-- ...bar
		vint_set_property(hostile.fill_h, "visible", show_bar)
		if alpha < 1.0 then
			vint_set_property(hostile.border_h, "visible", false)
			vint_set_property(hostile.grit_h, "visible", false)
		else
			vint_set_property(hostile.border_h, "visible", show_bar)
			vint_set_property(hostile.grit_h, "visible", show_bar)
		end
		
		-- ...name
		vint_set_property(hostile.mp_name_h, "visible", show_name)
		if alpha < 1.0 then
			vint_set_property(hostile.mp_name_h, "shadow_enabled", false) 
		else
			vint_set_property(hostile.mp_name_h, "shadow_enabled", true) 
		end
		
		-- ...arrow
		vint_set_property(hostile.mp_arrow_h, "visible", show_arrow)
		
		-- ...cash
		if overhead_cash ~= 0 then
			vint_set_property(hostile.overhead_cash_h, "text_tag", "+$" .. format_cash(overhead_cash))
		end
		
		if overhead_cash == 0 and hostile.overhead_cash ~= 0  then
			lua_play_anim(hostile.cash_fade_clone)
		else
			vint_set_property(hostile.overhead_cash_h, "visible", show_cash)
			vint_set_property(hostile.overhead_cash_h, "alpha", 1)
			vint_set_property(hostile.case_fade_clone, "is_paused", true)
		end
		
		hostile.overhead_cash = overhead_cash
		
		-- ...race_pos
		vint_set_property(hostile.race_pos_h, "visible", show_race_pos)
		if show_race_pos then
			vint_set_property(hostile.race_pos_h, "image", "ingame_race_position_" .. race_position) 
		end
		
		-- Set the name
		vint_set_property(hostile.mp_name_h, "text_tag", name)
		
		-- Set the color
		tint_healthbar( hostile, color )
		
		--Screen Position		
		local x = screen_x
		local y = screen_y
		vint_set_property(hostile.grp_h, "anchor", x, y)	
		
		--Scale
		local maxclamp = 0.40
		local minclamp = 0.1
		
		local maxscale = 1
		local minscale = 0.5
		
		--Clamp the distances
		if distance <= minclamp then
			distance = minclamp 
		elseif distance >= maxclamp then
			distance = maxclamp
		end

		local newdist = (distance - minclamp)
		local ratio = 1 - (newdist / (maxclamp - minclamp))
		local scale = (ratio * (maxscale-minscale)) + minscale
		
		vint_set_property(hostile.grp_h, "scale", scale, scale)
		vint_set_property(hostile.grp_h, "alpha", alpha)
			
		--Z Depth
		if z_depth ~= hostile.z_depth then
			vint_set_property(hostile.grp_h,  "depth", z_depth)
		end
		
		--Invulnerability change
		if MP_enabled == true then
			if hostile.mp_respawn_invulnerable ~= mp_respawn_invulnerable then
				if mp_respawn_invulnerable == false then
					vint_set_property(hostile.invulnerable_anim_0, "is_paused", true)
				else
					lua_play_anim(hostile.invulnerable_anim_0, 0)
				end
			end
			hostile.mp_respawn_invulnerable = mp_respawn_invulnerable
		end
		
		--dont ever delete this.........
		hostile.health_pct = health_pct
		
		-- For debugging purposes we also store the decoded name
		hostile.decoded_name = decoded_name
	end

		
	--If you got a remove event, remove the clones	
	if event == "remove" and Hud_healthbars_status.hostiles[key] ~= nil then
--		debug_print("vint_healthbars", "Remove healthbar for " .. decoded_name .. " key: " .. key .. "\n")
		local hostile = Hud_healthbars_status.hostiles[key]
		vint_object_destroy(hostile.grp_h)
		vint_object_destroy(hostile.anim_clone_0)
		vint_object_destroy(hostile.cash_fade_clone)
		vint_object_destroy(hostile.invulnerable_anim_0)
		Hud_healthbars_status.hostiles[key] = nil
	end
		
end

-- Prints out info for every entry in the current hostiles list
--
function hud_healthbars_debug_print()
--	debug_print( "vint_healthbars", "Current healthbar entries:\n" )
	
--	for key, entry in pairs(Hud_healthbars_status.hostiles) do
--		debug_print( "vint_healthbars", "\tkey: " .. key .. " name: " .. entry.decoded_name .. "\n" )
--	end
end




_wlocal HUD_RETICULE_OVERHEAT_RED 		= { R = 230/255, G = 5/255, B = 5/255}
local HUD_RETICULE_OVERHEAT_LIGHT 	= { R = 230/255, G = 109/255, B = 33/255}
local HUD_RETICULE_CHARGE_MAX 		= { R = 69/255, G = 185/255, B = 10/255}
local HUD_RETICULE_CHARGE_MIN 		= { R = 178/255, G = 218/255, B = 19/255}


local HUD_RETICULE_RING_SIZE_DIF 	= .44		--This is the scale difference between the small and large ring...

local RET_CONFIG_NONE					= 0
local RET_CONFIG_PISTOL 				= 1
local RET_CONFIG_HOLT55					= 2
local RET_CONFIG_SHOTGUN 				= 3
local RET_CONFIG_SUB_RIFLE 			= 4
local RET_CONFIG_RIFLE 					= 5
local RET_CONFIG_RPG 					= 6
local RET_CONFIG_RPG_ANNIHILATOR 	= 7
local RET_CONFIG_THROWN 				= 8
local RET_CONFIG_SNIPER				 	= 9
local RET_CONFIG_PRESSURE			 	= 10

local RET_SPREAD_DEFAULT			 	= 0
local RET_SPREAD_RIFLE				 	= 1
local RET_SPREAD_SMG				 		= 2
local RET_SPREAD_SNIPER				 	= 3

local RET_CROSS_SIZE_NONE				= 0 
local RET_CROSS_SIZE_SMALL 			= 1
local RET_CROSS_SIZE_LARGE 			= 2

local RET_HIT_MAX							= 5

Hud_reticules = {
	configs = {
		[RET_CONFIG_NONE] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {false, false},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_PISTOL] = {
			dot = {true, false},
			ring = {true, true},
			ring_split = {false, false},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_HOLT55] = {
			dot = {false, false},
			ring = {true, true},
			ring_split = {false, false},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = true,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_SHOTGUN] = {
			dot = {false, false},
			ring = {true, true},
			ring_split = {false, false},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = false,
			spread_style = RET_CONFIG_SHOTGUN,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_SUB_RIFLE] = {
			dot = {false, false},
			ring = {true, true},
			ring_split = {false, false},
			cross = {true, true},
			cross_size = RET_CROSS_SIZE_SMALL,
			cross_orientation = 0,
			spread = true,
			spread_style = RET_SPREAD_SMG,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_RIFLE] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {false, false},
			cross = {true, true},
			cross_size = RET_CROSS_SIZE_LARGE,
			cross_orientation = 0,
			spread = true,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_RPG] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {false, false},
			cross = {true, true},
			cross_size = RET_CROSS_SIZE_LARGE,
			cross_orientation = 1,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_RPG_ANNIHILATOR] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {false, false},
			cross = {true, true},
			cross_size = RET_CROSS_SIZE_LARGE,
			cross_orientation = 1,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_THROWN] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {true, true},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = false,
		},
		[RET_CONFIG_SNIPER] = {
			dot = {false, false},
			ring = {false, false},
			ring_split = {false, false},
			cross = {true, true},
			cross_size = "large",
			cross_orientation = 0,
			spread = false,
			spread_style = RET_SPREAD_SNIPER,
			sniper = true,
			pressure = false,
		},
		[RET_CONFIG_PRESSURE] = {
			dot = {false, false},
			ring = {true, true},
			ring_split = {false, false},
			cross = {false, false},
			cross_size = nil,
			cross_orientation = nil,
			spread = false,
			spread_style = RET_SPREAD_DEFAULT,
			sniper = false,
			pressure = true,
		}
	},
	categories = {
		["WPNCAT_MELEE"] = RET_CONFIG_NONE,
		["WPNCAT_PISTOL"] = RET_CONFIG_PISTOL,
		["WPNCAT_SHOTGUN"] = RET_CONFIG_SHOTGUN,
		["WPNCAT_SUB_MACHINE_GUN"] = RET_CONFIG_SUB_RIFLE,
		["WPNCAT_RIFLE"] = RET_CONFIG_RIFLE,
		["WPNCAT_SPECIAL"] = RET_CONFIG_SHOTGUN,
		["WPNCAT_THROWN"] = RET_CONFIG_THROWN,
		["WPNCAT_HAVOK"] = RET_CONFIG_THROWN,
	},
	wpn_names = {
		["stun_gun"] = RET_CONFIG_PISTOL,
		["Holt_55"] = RET_CONFIG_HOLT55,
		["pepper_spray"] = RET_CONFIG_SHOTGUN,
		["fireext"] = RET_CONFIG_SHOTGUN,
		["minigun"] = RET_CONFIG_SHOTGUN,
		["rpg_annihilator"] = RET_CONFIG_RPG_ANNIHILATOR,
		["rpg_launcher"] = RET_CONFIG_RPG,
		["mcmanus2010"] = RET_CONFIG_SNIPER,
		["bean_bag_gun"] = RET_CONFIG_PISTOL,
		["truck_2dr_septic01_Rear"] = RET_CONFIG_PRESSURE,
		["truck_2dr_septic01_Front"] = RET_CONFIG_PRESSURE,
		["truck_2dr_fire01"] = RET_CONFIG_PRESSURE,
		["sp_novelty01"] = RET_CONFIG_PRESSURE,
		
		["sp_tank01_w"] = RET_CONFIG_RIFLE,
		["sp_tank01_w2"] = RET_CONFIG_RIFLE,
		["sp_tank02_w"] = RET_CONFIG_RIFLE,
		["sp_tank03_w"] = RET_CONFIG_RIFLE,
		["sp_tank03_w2"] = RET_CONFIG_RIFLE,
	},
	elements = {
		reticule_h = -1,
		dot_h = -1,
		cross_h = -1,
		cross_n_h = -1,
		cross_e_h = -1,
		cross_s_h = -1,
		cross_w_h = -1,
		ring_small_h = -1,
		ring_large_h = -1,
		ring_mask_nw_h = -1,
		ring_mask_ne_h = -1,
		ring_mask_sw_h = -1,
		ring_mask_se_h = -1,
		ring_split_h = -1,
		sniper_h = -1,
		sniper_cross_w_h = -1,
		sniper_cross_s_h = -1,
		sniper_cross_e_h = -1,
		sniper_dir_grp_h = -1,
		sniper_dir_bmp_h = -1,
		friendly_h = -1,
		pressure_grp_h = -1,
		pressure_fill_h = -1,
	},
	status = {
		wpn_name = -1,
		config = -1,
		highlight = -1,
		wpn_spread = -1,
		fine_aim = -1,
		y_screen_coord = -1,
	}, 
	spread_style = {
		[RET_SPREAD_DEFAULT] = {
			cross_mag_min = 3,
			cross_mag_max = 6,
			cross_mag_fineaim_min = -1,
			cross_mag_fineaim_max = 16,
			ring_alpha = .67, 
			ring_alpha_highlight = .9,
			ring_min = 1,--0.7,
			ring_max = 2.3,
			ring_fineaim_min = 0.85,--0.5,
			ring_fineaim_max = 1.8,
			ring_mask_min = 0,
			ring_mask_max = 20,
			ring_mask_fineaim_min = 0,
			ring_mask_fineaim_max = 20,
		},
		[RET_SPREAD_SMG] = {
			cross_mag_min = 1,
			cross_mag_max = 8,
			cross_mag_fineaim_min = -1,
			cross_mag_fineaim_max = 8,
			ring_alpha = .67, 
			ring_alpha_highlight = .9,
			ring_min = 1,
			ring_max = 1.2,--2.3,
			ring_fineaim_min = .85,
			ring_fineaim_max = 1.2,
			ring_mask_min = 0,
			ring_mask_max = 10,
			ring_mask_fineaim_min = 0,
			ring_mask_fineaim_max = 8,
		},
		[RET_CONFIG_SHOTGUN] = {
			cross_mag_min = 1,
			cross_mag_max = 19,
			cross_mag_fineaim_min = -1,
			cross_mag_fineaim_max = 16,
			ring_alpha = .67, 
			ring_alpha_highlight = .9,
			ring_min = 1.6,
			ring_max = 2.3,
			ring_fineaim_min = 1.2,
			ring_fineaim_max = 1.8,
			ring_mask_min = 0,
			ring_mask_max = 20,
			ring_mask_fineaim_min = 0,
			ring_mask_fineaim_max = 20,
		},
		[RET_SPREAD_SNIPER] = {
			cross_mag_min = 15,
			cross_mag_max = 25,
			cross_mag_fineaim_min =  15,
			cross_mag_fineaim_max =  25,
			ring_alpha = .67, 
			ring_alpha_highlight = .9,
			ring_min = 1,
			ring_max = 2.3,
			ring_fineaim_min = .85,
			ring_fineaim_max = 1.8,
			ring_mask_min = 0,
			ring_mask_max = 20,
			ring_mask_fineaim_min = 0,
			ring_mask_fineaim_max = 20,
		}
	},
	pressure = {
		cur_value = -1,
		start_angle = 3.147,
		end_angle = 0
	},
	overheat = {
		is_overheated = -1,
		pct = -1,
		x_scale = 1,
		y_scale = 1,
	}
}

Hud_sniper_arrows = {}

Hud_hit_data = {}

Hud_current_hit_index = 0



function hud_reticules_init()
	--Reticules
	
	--Reticule Base for positioning(Controlled by game code) and doing master fades
	local h = vint_object_find("reticules")
	Hud_reticules.elements.reticule_base_h = h
	
	--Contains all the reticules but seperated from the persistant reticule which is used for fading.
	local h = vint_object_find("reticule_container", h)
	Hud_reticules.elements.reticule_h = h
	
	--Deep Reticule Parts
	Hud_reticules.elements.dot_h = vint_object_find("dot", h)
	Hud_reticules.elements.ring_small_h = vint_object_find("ring_small", h)
	Hud_reticules.elements.ring_large_h = vint_object_find("ring_large", h)
	Hud_reticules.elements.ring_split_h = vint_object_find("ring_split", h)
	Hud_reticules.elements.ring_mask_nw_h  = vint_object_find("mask_nw", h)
	Hud_reticules.elements.ring_mask_ne_h  = vint_object_find("mask_ne", h)
	Hud_reticules.elements.ring_mask_sw_h  = vint_object_find("mask_sw", h)
	Hud_reticules.elements.ring_mask_se_h  = vint_object_find("mask_se", h)
	Hud_reticules.elements.cross_h = vint_object_find("cross", h)
	Hud_reticules.elements.friendly_h = vint_object_find("friendly", h)
	
	--pressure group
	Hud_reticules.elements.pressure_grp_h =  vint_object_find("pressure_grp", h)
	Hud_reticules.elements.pressure_fill_h =  vint_object_find("pressure_fill", h)
	
	--Cross Hairs
	h = Hud_reticules.elements.cross_h 
	Hud_reticules.elements.cross_n_h = vint_object_find("n", h)
	Hud_reticules.elements.cross_e_h = vint_object_find("e", h)
	Hud_reticules.elements.cross_s_h = vint_object_find("s", h)
	Hud_reticules.elements.cross_w_h = vint_object_find("w", h)
	
	--Sniper!
	Hud_reticules.elements.sniper_h = vint_object_find("sniper")
	Hud_reticules.elements.sniper_dir_grp_h = vint_object_find("sniper_dir_grp")
	Hud_reticules.elements.sniper_dir_bmp_h = vint_object_find("sniper_dir_bmp")
	h = Hud_reticules.elements.sniper_h 
	
	Hud_reticules.elements.sniper_cross_w_h = vint_object_find("cross_w", h)
	Hud_reticules.elements.sniper_cross_s_h = vint_object_find("cross_s", h)
	Hud_reticules.elements.sniper_cross_e_h = vint_object_find("cross_e", h)
	
	--Persistant Reticules
	Hud_reticules.elements.dot_persistant_h = vint_object_find("dot_persistant")
	
	--Hit indication
	Hud_reticules.elements.ret_hit_grp_h = vint_object_find("ret_hit")
	Hud_reticules.elements.ret_hit_anim = vint_object_find("reticule_hit_anim")
	
	--Data subscriptions	
	
	--Sniper Directional Indicators
	vint_datagroup_add_subscription("sniper_dir_arrows", "update", "hud_sniper_dir_update")
	vint_datagroup_add_subscription("sniper_dir_arrows", "insert", "hud_sniper_dir_add")
	vint_datagroup_add_subscription("sniper_dir_arrows", "remove", "hud_sniper_dir_remove")
	
	--Hit Indicators
	vint_datagroup_add_subscription("sr2_local_player_hit_indicator", "insert", "Hud_hit_add")
end

function Hud_reticule_process_hit(bullet_hit)
	--process a hit
	if bullet_hit then
		lua_play_anim(Hud_reticules.elements.ret_hit_anim,0)
	end
end

--####################################################################
--Reticules
--####################################################################
function Hud_reticule_update(wpn_name, wpn_category, reticule_highlight ) 
	
	local reticule_layout_type = RET_CONFIG_NONE
	
	if wpn_name == nil then
		--Use default layout type 
	else
		--Check weapon name first
		reticule_layout_type = Hud_reticules.wpn_names[wpn_name]
	
		--If we didn't find a match then use default category
		if reticule_layout_type == nil then
			reticule_layout_type = Hud_reticules.categories[wpn_category]
		end
	end
	
	if wpn_category == "WPNCAT_MELEE" or wpn_category == nil then
		if wpn_name == "stun_gun" then
			vint_set_property(Hud_reticules.elements.reticule_h, "visible", true)
			vint_set_property(Hud_reticules.elements.dot_persistant_h, "visible", true)
		else
			vint_set_property(Hud_reticules.elements.ret_hit_grp_h, "visible", false)
			vint_set_property(Hud_reticules.elements.reticule_h, "visible", false)
			vint_set_property(Hud_reticules.elements.dot_persistant_h, "visible", false)
		end
	else
		vint_set_property(Hud_reticules.elements.ret_hit_grp_h, "visible", true)
		vint_set_property(Hud_reticules.elements.reticule_h, "visible", true)
		vint_set_property(Hud_reticules.elements.dot_persistant_h, "visible", true)
	end

	local reticule_layout = Hud_reticules.configs[reticule_layout_type]
	local spread_style = Hud_reticules.spread_style[Hud_reticules.configs[reticule_layout_type].spread_style]
	
	--Error Check
 	if reticule_layout == nil then
		return
	end

	--Process reticule highlighting
	if reticule_highlight == "friendly" then

		--Tint Sniper reticules for friendly
		vint_set_property(Hud_reticules.elements.sniper_cross_w_h, "tint", .164, .63, .18)
		vint_set_property(Hud_reticules.elements.sniper_cross_s_h, "tint", .164, .63, .18)
		vint_set_property(Hud_reticules.elements.sniper_cross_e_h, "tint", .164, .63, .18)
		
	elseif reticule_highlight == "enemy" then
		
		local r_0 = .89
		if reticule_layout.dot[2] == true then
			vint_set_property(Hud_reticules.elements.dot_h, "tint", r_0, 0, 0)
		else
			vint_set_property(Hud_reticules.elements.dot_h, "tint", 1, 1, 1)
		end
		
		if reticule_layout.ring[2] == true then
			vint_set_property(Hud_reticules.elements.ring_small_h, "tint", r_0, 0, 0)
			vint_set_property(Hud_reticules.elements.ring_large_h, "tint", r_0, 0, 0)
			
			vint_set_property(Hud_reticules.elements.ring_small_h, "alpha", spread_style.ring_alpha_highlight)
			vint_set_property(Hud_reticules.elements.ring_large_h, "alpha", spread_style.ring_alpha_highlight)
			
		else
			vint_set_property(Hud_reticules.elements.ring_small_h, "tint", 1, 1, 1)
			vint_set_property(Hud_reticules.elements.ring_large_h, "tint", 1, 1, 1)
			
			vint_set_property(Hud_reticules.elements.ring_small_h, "alpha", spread_style.ring_alpha)
			vint_set_property(Hud_reticules.elements.ring_large_h, "alpha", spread_style.ring_alpha)
			
		end
				
		if reticule_layout.ring_split[2] == true then
			vint_set_property(Hud_reticules.elements.ring_split_h, "tint", r_0, 0, 0)
		else
			vint_set_property(Hud_reticules.elements.ring_split_h, "tint", 1, 1, 1)
		end
		
		if reticule_layout.cross[2] == true then
			vint_set_property(Hud_reticules.elements.cross_h, "tint", r_0, 0, 0)
		else
			vint_set_property(Hud_reticules.elements.cross_h, "tint", 1, 1, 1)
		end
		
		--Tint Sniper reticules for Enemy
		vint_set_property(Hud_reticules.elements.sniper_cross_w_h, "tint", r_0, 0, 0)
		vint_set_property(Hud_reticules.elements.sniper_cross_s_h, "tint", r_0, 0, 0)
		vint_set_property(Hud_reticules.elements.sniper_cross_e_h, "tint", r_0, 0, 0)
		
	elseif reticule_highlight == "none" then
	
		vint_set_property(Hud_reticules.elements.dot_h, "tint", 1, 1, 1)
		vint_set_property(Hud_reticules.elements.ring_small_h, "tint", 1, 1, 1)
		vint_set_property(Hud_reticules.elements.ring_large_h, "tint", 1, 1, 1)
		vint_set_property(Hud_reticules.elements.ring_split_h, "tint", 1, 1, 1)
		vint_set_property(Hud_reticules.elements.cross_h, "tint", 1, 1, 1)
		
		--Tint Sniper reticules
		vint_set_property(Hud_reticules.elements.sniper_cross_w_h, "tint", .25, .25, .25)
		vint_set_property(Hud_reticules.elements.sniper_cross_s_h, "tint", .25, .25, .25)
		vint_set_property(Hud_reticules.elements.sniper_cross_e_h, "tint", .25, .25, .25)
	end	
	
	--Toggle between friendly reticule and standard reticule parts
	if reticule_highlight == "friendly" and reticule_layout_type ~= "none" then
		--Display friendly reticule and hide other parts
		vint_set_property(Hud_reticules.elements.friendly_h, "visible", true) 
		vint_set_property(Hud_reticules.elements.dot_h, "visible", false)
		vint_set_property(Hud_reticules.elements.ring_small_h, "visible",false)
		vint_set_property(Hud_reticules.elements.ring_large_h, "visible", false)
		vint_set_property(Hud_reticules.elements.ring_split_h, "visible", false)
		vint_set_property(Hud_reticules.elements.cross_h, "visible", false)
	
	else
		--Hide friendly reticule and display the proper parts
		vint_set_property(Hud_reticules.elements.friendly_h, "visible", false) 	
		vint_set_property(Hud_reticules.elements.dot_h, "visible", reticule_layout.dot[1])
		vint_set_property(Hud_reticules.elements.ring_small_h, "visible", reticule_layout.ring[1])
		vint_set_property(Hud_reticules.elements.ring_large_h, "visible", reticule_layout.ring[1])
		vint_set_property(Hud_reticules.elements.ring_split_h, "visible", reticule_layout.ring_split[1])
		vint_set_property(Hud_reticules.elements.cross_h, "visible", reticule_layout.cross[1])

		--Cross Size
		if reticule_layout.cross_size == "large" then
			--Set all bitmaps to the large size
			vint_set_property(Hud_reticules.elements.cross_n_h, "image", "uhd_ui_hud_reticule_cross_large")
			vint_set_property(Hud_reticules.elements.cross_e_h, "image", "uhd_ui_hud_reticule_cross_large")
			vint_set_property(Hud_reticules.elements.cross_s_h, "image", "uhd_ui_hud_reticule_cross_large")
			vint_set_property(Hud_reticules.elements.cross_w_h, "image", "uhd_ui_hud_reticule_cross_large")
			vint_set_property(Hud_reticules.elements.cross_n_h, "offset", -8 * 3, -24 * 3)
			vint_set_property(Hud_reticules.elements.cross_e_h, "offset", -8 * 3, -24 * 3)
			vint_set_property(Hud_reticules.elements.cross_s_h, "offset", -8 * 3, -24 * 3)
			vint_set_property(Hud_reticules.elements.cross_w_h, "offset", -8 * 3, -24 * 3)
			
		elseif reticule_layout.cross_size == "small" then
			--Set all bitmaps to small size
			vint_set_property(Hud_reticules.elements.cross_n_h, "image", "uhd_ui_hud_reticule_cross_small")
			vint_set_property(Hud_reticules.elements.cross_e_h, "image", "uhd_ui_hud_reticule_cross_small")
			vint_set_property(Hud_reticules.elements.cross_s_h, "image", "uhd_ui_hud_reticule_cross_small")
			vint_set_property(Hud_reticules.elements.cross_w_h, "image", "uhd_ui_hud_reticule_cross_small")
			vint_set_property(Hud_reticules.elements.cross_n_h, "offset", -8 * 3, -19 * 3)
			vint_set_property(Hud_reticules.elements.cross_e_h, "offset", -8 * 3, -19 * 3)
			vint_set_property(Hud_reticules.elements.cross_s_h, "offset", -8 * 3, -19 * 3)
			vint_set_property(Hud_reticules.elements.cross_w_h, "offset", -8 * 3, -19 * 3)
		end                                                        
		
		--Cross Orientation
		if reticule_layout.cross_orientation == 0 then
			--Standard Orientation
			vint_set_property(Hud_reticules.elements.cross_h, "rotation", 0)
		elseif reticule_layout.cross_orientation == 1 then
			--45 Degree Rotation
			vint_set_property(Hud_reticules.elements.cross_h, "rotation", 0.785398163)
		end
		
	end
	
	--Show pressure gauge?
	--we don't have any pressure weapons in SR3, yet
	--[[if reticule_layout.pressure == true then
		vint_set_property(Hud_reticules.elements.pressure_grp_h, "visible", true)
	else
		vint_set_property(Hud_reticules.elements.pressure_grp_h, "visible", true)--false)
	end]]
	
	--Store reticule status to internal data sets
	Hud_reticules.status.wpn_name = wpn_name
	Hud_reticules.status.highlight = reticule_highlight
	Hud_reticules.status.config = reticule_layout_type
end

function hud_reticule_spread_update(wpn_spread, show_spread)

	--debug_print("vint", "show_spread" .. var_to_string(show_spread) .. "\n")
	
	local fine_aim = Hud_weapon_status.fine_aim_transition
	local spread_style = Hud_reticules.spread_style[Hud_reticules.configs[Hud_reticules.status.config].spread_style]
	
	if spread_style == nil then
		--debug_print("vint", "Spread Style \"" .. Hud_reticules.configs[Hud_reticules.status.config].spread_style .. "\" not found in Hud_reticules.spread_style\n")
		spread_style = Hud_reticules.spread_style[RET_SPREAD_DEFAULT]
	end
	
	--Spread for to calculate crosshairs
	local pixel_spread
	
	local cross_mag_min = spread_style.cross_mag_min
	local cross_mag_max = spread_style.cross_mag_max
	
	cross_mag_min = cross_mag_min - ((cross_mag_min - spread_style.cross_mag_fineaim_min) * fine_aim)
	cross_mag_max = cross_mag_max - ((cross_mag_max - spread_style.cross_mag_fineaim_max) * fine_aim)
	
	--debug_print("vint", "fine_aim: " .. fine_aim .. "\n")
	--debug_print("vint", "cross_mag_min: " .. cross_mag_min .. "\n")
	--debug_print("vint", "cross_mag_max: " .. cross_mag_max .. "\n")
	
	if show_spread == true then
		pixel_spread = wpn_spread * cross_mag_max + cross_mag_min
	else
		pixel_spread = cross_mag_min
	end
	
	vint_set_property(Hud_reticules.elements.cross_n_h, "anchor", 0, -pixel_spread)
	vint_set_property(Hud_reticules.elements.cross_e_h, "anchor", pixel_spread, 0)
	vint_set_property(Hud_reticules.elements.cross_s_h, "anchor", 0, pixel_spread)
	vint_set_property(Hud_reticules.elements.cross_w_h, "anchor", -pixel_spread, 0)
	
	--If the reticule is highlighted over an enemy then the ring alpha is stronger
	local ring_alpha = 0
	if Hud_reticules.status.highlight == "enemy" then
		ring_alpha = spread_style.ring_alpha_highlight
	else
		ring_alpha = spread_style.ring_alpha
	end

	local ring_small_min = spread_style.ring_min 
	local ring_small_max = spread_style.ring_max
	local ring_large_min = spread_style.ring_min * HUD_RETICULE_RING_SIZE_DIF
	local ring_large_max = spread_style.ring_max * HUD_RETICULE_RING_SIZE_DIF
	local ring_mask_min = spread_style.ring_mask_min
	local ring_mask_max = spread_style.ring_mask_max
	
	local ring_small_fineaim_min = spread_style.ring_fineaim_min 
	local ring_small_fineaim_max = spread_style.ring_fineaim_max 
	local ring_large_fineaim_min = spread_style.ring_fineaim_min * HUD_RETICULE_RING_SIZE_DIF
	local ring_large_fineaim_max = spread_style.ring_fineaim_max * HUD_RETICULE_RING_SIZE_DIF
	local ring_mask_fineaim_min = spread_style.ring_mask_fineaim_min
	local ring_mask_fineaim_max = spread_style.ring_mask_fineaim_max
	
	--Fine aim calculations
	ring_small_min = ring_small_min  - ((ring_small_min 	- ring_small_fineaim_min) * fine_aim)
	ring_small_max = ring_small_max  - ((ring_small_max 	- ring_small_fineaim_max) * fine_aim)
	ring_large_min = ring_large_min  - ((ring_large_min 	- ring_large_fineaim_min) * fine_aim)
	ring_large_max = ring_large_max  - ((ring_large_max 	- ring_large_fineaim_max) * fine_aim)
	ring_mask_min 	= ring_mask_min 	- ((ring_mask_min 	- ring_mask_fineaim_min) * fine_aim)
	ring_mask_max 	= ring_mask_max  	- ((ring_mask_max 	- ring_mask_fineaim_max) * fine_aim)
	                                                      
	local ring_small_scale, ring_small_alpha, ring_large_scale, ring_large_alpha, ring_mask_offset
	
	if show_spread == true then
		ring_small_scale = ring_small_min + wpn_spread * (ring_small_max - ring_small_min)
		ring_small_alpha = ring_alpha - (wpn_spread * 1.5) * ring_alpha
	
		if ring_small_alpha < 0 then
			ring_small_alpha = 0
		end

		ring_large_scale = ring_large_min + wpn_spread * (ring_large_max - ring_large_min)
		ring_large_alpha = (wpn_spread * 1.5) * ring_alpha
		
		if ring_large_alpha > ring_alpha then
			ring_large_alpha = ring_alpha
		end
		
		ring_mask_offset = ring_mask_min + wpn_spread * (ring_mask_max - ring_mask_min)
		
	else
		--No Spread
		ring_small_scale = ring_small_min
		ring_small_alpha = ring_alpha
		ring_large_scale = ring_large_min
		ring_large_alpha = 0
		ring_mask_offset = 0 
	end
	
	--Ring Cropping		
	vint_set_property(Hud_reticules.elements.ring_mask_nw_h, "anchor", -ring_mask_offset, -ring_mask_offset)
	vint_set_property(Hud_reticules.elements.ring_mask_ne_h, "anchor", ring_mask_offset, -ring_mask_offset)
	vint_set_property(Hud_reticules.elements.ring_mask_sw_h, "anchor", -ring_mask_offset, ring_mask_offset)
	vint_set_property(Hud_reticules.elements.ring_mask_se_h, "anchor", ring_mask_offset, ring_mask_offset)		
	
	--Ring Scaling
	vint_set_property(Hud_reticules.elements.ring_small_h, "scale", ring_small_scale, ring_small_scale)
	vint_set_property(Hud_reticules.elements.ring_small_h, "alpha", ring_small_alpha)
	vint_set_property(Hud_reticules.elements.ring_large_h, "scale", ring_large_scale, ring_large_scale)
	vint_set_property(Hud_reticules.elements.ring_large_h, "alpha", ring_large_alpha)
	
	--Dim for fine aim
	--No more dimming because the vignette has been altered
--	local fine_aim_alpha =  fine_aim * .2 + .3
--	vint_set_property(Hud_vignettes.fine_aim_dim.grp_h, "alpha", fine_aim_alpha)
	
	Hud_reticules.status.fine_aim = fine_aim
end

--##################################################################### 
--Sniper Directional Indicators
--#####################################################################
function hud_sniper_dir_update(di_h)
	local rotation = vint_dataitem_get(di_h)
	
	--Find the arrow to update
	for index, value in pairs(Hud_sniper_arrows) do
		if index == di_h then
			--Found now update the rotation
			vint_set_property(value.arrow_h, "rotation", rotation)
			break
		end
	end
end

function hud_sniper_dir_add(di_h)
	
	--TODO: look through the table to make sure we don't have one already
	--Clone bitmap
	local arrow_clone_h = vint_object_clone(Hud_reticules.elements.sniper_dir_bmp_h)
	
	vint_set_property(arrow_clone_h, "visible", true)
	
	--Add handle to data object
	Hud_sniper_arrows[di_h] = {
		arrow_h = arrow_clone_h
	}
	
	--update the sniper arrow
	hud_sniper_dir_update(di_h)
end

function hud_sniper_dir_remove(di_h)
	--Find the arrow to remove
	for index, value in pairs(Hud_sniper_arrows) do
		if index == di_h then
			vint_object_destroy(value.arrow_h)
			Hud_sniper_arrows[index] = nil
			break
		end
	end
end

function hud_reticule_update_pressure(pressure_value)
	if pressure_value == nil then
		return
	end
	--invert value
	pressure_value = 1 - pressure_value
	--TODO: Update pressure
	if pressure_value ~= Hud_reticules.pressure.cur_value then
		--calculate angle and set property
		local angle = Hud_reticules.pressure.start_angle * pressure_value
		vint_set_property(Hud_reticules.elements.pressure_fill_h, "start_angle", angle)
		Hud_reticules.pressure.cur_value = pressure_value
	end
end

function hud_reticule_change_position(x_screen_coord, y_screen_coord)
	--Change the y screen anchor of the reticule
	if Hud_reticules.status.y_screen_coord ~= y_screen_coord or Hud_reticules.status.x_screen_coord ~= x_screen_coord then
		vint_set_property(Hud_reticules.elements.reticule_base_h, "anchor", x_screen_coord, y_screen_coord)
		hud_cruise_control_update_pos(x_screen_coord, y_screen_coord)
		hud_hits_updates_pos(x_screen_coord, y_screen_coord)
		Hud_reticules.status.x_screen_coord = x_screen_coord 
		Hud_reticules.status.y_screen_coord = y_screen_coord 
	end
end



--##################################################################### 
--hud_reticule_spread_update()
--
--Updates the opacity of the reticule
--#####################################################################
function hud_reticule_opacity_update(opacity) 

	local persistant_opacity = (1 - opacity) * .67
	
	vint_set_property(Hud_reticules.elements.dot_persistant_h, "alpha", persistant_opacity)
	vint_set_property(Hud_reticules.elements.reticule_h, "alpha", opacity)
end

--##################################################################### 
-- Overheat Meter
--#####################################################################
function hud_reticule_overheat_update(pct, is_overheated)
	
	local anim_h = vint_object_find("reticule_overheat_flash_anim",0,HUD_DOC_HANDLE)
	local twn_h = vint_object_find("overheat_twn_h")

	if pct ~= Hud_reticules.overheat.pct then
		if pct == 0 then
			vint_set_property(Hud_reticules.elements.pressure_grp_h, "visible", false)
		else
			vint_set_property(Hud_reticules.elements.pressure_grp_h, "visible", true)
			
			--get a short handle to the weapon name
			local wpn_name = Hud_reticules.status.wpn_name
			
			--check if we have a charge weapon
			local charge = false
			if wpn_name == "Special-SonicGun" or wpn_name == "Special-CyberCannon" then
				charge = true
			end
			
			local r,g,b
			--set meter color based on charge or overheat
			if charge then
				--charge
				r = (HUD_RETICULE_CHARGE_MAX.R - HUD_RETICULE_OVERHEAT_RED.R) * pct	+ HUD_RETICULE_OVERHEAT_RED.R
				g = (HUD_RETICULE_CHARGE_MAX.G - HUD_RETICULE_OVERHEAT_RED.G) * pct	+ HUD_RETICULE_OVERHEAT_RED.G
				b = (HUD_RETICULE_CHARGE_MAX.B - HUD_RETICULE_OVERHEAT_RED.B) * pct	+ HUD_RETICULE_OVERHEAT_RED.B
			else
				--overheat
				r = (HUD_RETICULE_OVERHEAT_RED.R - HUD_RETICULE_OVERHEAT_LIGHT.R) * pct	+ HUD_RETICULE_OVERHEAT_LIGHT.R
				g = (HUD_RETICULE_OVERHEAT_RED.G - HUD_RETICULE_OVERHEAT_LIGHT.G) * pct	+ HUD_RETICULE_OVERHEAT_LIGHT.G
				b = (HUD_RETICULE_OVERHEAT_RED.B - HUD_RETICULE_OVERHEAT_LIGHT.B) * pct	+ HUD_RETICULE_OVERHEAT_LIGHT.B
			end
			
			--if meter is full then flash tint
			if pct >= 1.0 then
				if charge then
					--change to charge colors
					vint_set_property(twn_h,"start_value",HUD_RETICULE_CHARGE_MAX.R,HUD_RETICULE_CHARGE_MAX.G,HUD_RETICULE_CHARGE_MAX.B)
					vint_set_property(twn_h,"end_value",HUD_RETICULE_CHARGE_MIN.R,HUD_RETICULE_CHARGE_MIN.G,HUD_RETICULE_CHARGE_MIN.B)
				else
					--change to overheat colors
					vint_set_property(twn_h,"start_value",HUD_RETICULE_OVERHEAT_RED.R,HUD_RETICULE_OVERHEAT_RED.G,HUD_RETICULE_OVERHEAT_RED.B)
					vint_set_property(twn_h,"end_value",HUD_RETICULE_OVERHEAT_LIGHT.R,HUD_RETICULE_OVERHEAT_LIGHT.G,HUD_RETICULE_OVERHEAT_LIGHT.B)
				end
				--colors are set, play the animation
				lua_play_anim(anim_h,0,HUD_DOC_HANDLE)
			elseif is_overheated == false then
				--stop the animation and handle colors dynamically
				vint_set_property(anim_h, "is_paused", true)
				vint_set_property(Hud_reticules.elements.pressure_fill_h, "tint", r, g, b)
			end

			local overheat_value = 1 - pct
			if overheat_value ~= Hud_reticules.overheat.pct then
				--calculate angle and set property
				local angle = Hud_reticules.pressure.start_angle * overheat_value
				vint_set_property(Hud_reticules.elements.pressure_fill_h, "start_angle", angle)
			end
		end
		
		Hud_reticules.overheat.is_overheated = is_overheated
		Hud_reticules.overheat.pct = pct	
	end
	
	
end

--[[
NOT USED ANYMORE BUT IT COULD COME BACK LATER
function hud_reticule_process_hit()
	--we got a hit so add to the index
	Hud_current_hit_index = Hud_current_hit_index + 1
	
	--we don't want too many going, cap it at RET_HIT_MAX
	if Hud_current_hit_index > RET_HIT_MAX then
		Hud_current_hit_index = 1
	end
	
	--clear out the table
	if Hud_hit_data[Hud_current_hit_index] ~= nil then
		vint_object_destroy(Hud_hit_data[Hud_current_hit_index].image_h)
		vint_object_destroy(Hud_hit_data[Hud_current_hit_index].anim_h)
		Hud_hit_data[Hud_current_hit_index] = {} 
	end
	
	--create the clones and store them
	local image_h = vint_object_find("hit_ring")
	local anim_h = vint_object_find("reticule_hit_anim")
	local image_clone_h = vint_object_clone(image_h)
	local anim_clone_h = vint_object_clone(anim_h)
	
	--Hud_hit_data[Hud_current_hit_index].image_h = image_clone_h
	--Hud_hit_data[Hud_current_hit_index].anim_h = anim_clone_h
	
	--turn on the clone
	vint_set_property(image_clone_h, "visible", true)
	
	--retarget the new animation to the new image
	vint_set_property(anim_clone_h, "target_handle", image_clone_h)
	
	--play the animation
	lua_play_anim(anim_clone_h,0)
end--]]Á™local	HUD_COLLECTION_FLASHPOINT		= 0
local	HUD_COLLECTION_COLLECTIBLE_GENERIC      = 1
local	HUD_COLLECTION_COLLECTIBLE_PHOTO_OP	= 2
local	HUD_COLLECTION_HITMAN			= 3
local	HUD_COLLECTION_CHOP_SHOP		= 4
local	HUD_COLLECTION_STUNT_JUMP		= 5
local	HUD_COLLECTION_BARNSTORMING		= 6
local	HUD_COLLECTION_SURVIVAL			= 7
local	HUD_COLLECTION_SECRET			= 8
local	HUD_COLLECTION_STAG			= 9

local	STATS_INVALID = -1

local	DT_NONE				= -1
local	DT_CHOP_SHOP		= 2
local	DT_BARNSTORMING	= 4
local DT_EXPLORATION		= 5
local	DT_FLASHPOINT		= 6
local	DT_HITMAN			= 7
local	DT_SURVIVAL			= 12

local Hud_collection_types = {
	[HUD_COLLECTION_FLASHPOINT] =		{
		audio = "ui_hud_gang_flash_complete",
		d_type = DT_FLASHPOINT,
	},
	[HUD_COLLECTION_COLLECTIBLE_GENERIC] =	{
		audio = "ui_hud_generic_div_complete",
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_COLLECTIBLE_PHOTO_OP] =	{
		audio = "ui_hud_photo_op_complete",
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_HITMAN] =		{
		audio = "ui_hud_hitman_complete",
		d_type = DT_HITMAN,
	},
	[HUD_COLLECTION_CHOP_SHOP] =		{
		audio = "ui_hud_chop_shop_complete",
		d_type = DT_CHOP_SHOP,
	},
	[HUD_COLLECTION_STUNT_JUMP] =		{
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_BARNSTORMING] =		{
		d_type = DT_BARNSTORMING,
	},
	[HUD_COLLECTION_SURVIVAL] =		{
		audio = "ui_hud_survival_complete",
		d_type = DT_SURVIVAL,
	},
	[HUD_COLLECTION_SECRET] =		{
		d_type = DT_EXPLORATION,
	},
	[HUD_COLLECTION_STAG] =		{
		audio = "ui_hud_generic_div_complete",
		d_type = DT_NONE,
	}
}

local Hud_collection_anims = {}
local Hud_collection_data = {}
local Hud_collection_initialized = false
local Hud_collection_is_active = false
local Current_collection_index = 0
local Num_collection_data = 0
local Queued_collection_data = { }

local Hud_collection_control_meter 				= 0		--Control meter object...
local Hud_collection_respect_meter 				= 0		--Respect meter object...
local Hud_collection_cash_h 					 	= 0		--Cash Display...

local HUD_COLLECTION_ICON_WIDTH 			= 64 * 3
local HUD_COLLECTION_CONTROL_WIDTH		= 84 * 3
local HUD_COLLECTION_RESPECT_WIDTH 		= 84 * 3
local HUD_COLLECTION_MAX_WIDTH 			= 818 * 3
local HUD_COLLECTION_HEADER_MAX_WIDTH 	= 495 * 3

-------------------------------------------------------------------------------
-- This is included with hud.vint_doc
-------------------------------------------------------------------------------
function hud_collection_init()
	vint_dataitem_add_subscription("collection_hud_element", "update", "hud_collection_update")
	vint_dataitem_add_subscription("game_paused_item", "update", "hud_collection_game_is_paused")	--to check if game is paused...
	
	local h = vint_object_find("collection_grp")
	vint_set_property(h, "visible", false)
	
	--Animations stored to globals
	Hud_collection_anims.in_anim_h 			= vint_object_find("collection_in_anim")
	Hud_collection_anims.district_anim_h		= vint_object_find("collection_district_anim")
	Hud_collection_anims.respect_anim_h 		= vint_object_find("collection_respect_anim")
	Hud_collection_anims.cash_anim_h 		= vint_object_find("collection_cash_anim")
	Hud_collection_anims.complete_anim_h		= vint_object_find("collection_complete_anim")
	
	-- Setup callbacks to tweens....
	local control_twn_h = vint_object_find("collection_control_twn")
	local respect_twn_h = vint_object_find("collection_respect_twn")
	local cash_twn_h = vint_object_find("collection_cash_twn")
	local collection_fade_out_twn_h = vint_object_find("collection_fade_out_twn")
	
	vint_set_property(control_twn_h, "end_event", "hud_collection_start_control")
	vint_set_property(respect_twn_h, "start_event", "hud_collection_show_respect")
	vint_set_property(respect_twn_h, "end_event", "hud_collection_start_respect")
	vint_set_property(cash_twn_h, "start_event", "hud_collection_start_cash")
	vint_set_property(collection_fade_out_twn_h, "start_event", "hud_collection_audio_out")		--audio play out...
	vint_set_property(collection_fade_out_twn_h, "end_event", "hud_collection_finished")

	--Initialize control meter.
	Hud_collection_control_meter = Vdo_city_control:new("collection_control_meter")
	
	--Initialize respect meter.
	Hud_collection_respect_meter = Vdo_city_control:new("collection_respect_meter")
	Hud_collection_respect_meter:change_to_respect()

	Hud_collection_cash_h = vint_object_find("collection_cash_txt")
	
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	local collection_hud_bg_tile_twn = vint_object_find("collection_hud_bg_tile_twn")
	vint_set_property(collection_hud_bg_tile_twn, "duration", 30)
	vint_set_property(collection_hud_bg_tile_twn, "loop_mode", "cycle")
end

-------------------------------------------------------------
-- Fills in the data object for populating the screen...
-------------------------------------------------------------
--		VINT_PROP_TYPE_INT,           // Collection type
--		VINT_PROP_TYPE_UINT,          //    Title of the Collection message ("Gang Operation", "Hitman", "Chopshop") 
--		VINT_PROP_TYPE_UINT,          //    Subtitle (Destroyed, Completed, Found)
--		VINT_PROP_TYPE_INT,           //    How many items the player has left in district or game
--		VINT_PROP_TYPE_INT,           // Total items in district or game
--		
--		// if the following are nil then we omit their display...
--		VINT_PROP_TYPE_FLOAT,         //    Cash Reward
--		VINT_PROP_TYPE_INT,           // Respect Reward 
--		VINT_PROP_TYPE_FLOAT,  		 	//    District percentage before...
--		VINT_PROP_TYPE_FLOAT,   		// District percentage after...
--		VINT_PROP_TYPE_STRING,  		// DISTRICT name
--		VINT_PROP_TYPE_BOOL,				// Whether the rewards should be saved on mission failure/restart
--		VINT_PROP_TYPE_BOOL,				// whether to award cash / respect

function hud_collection_update(di_h)
	local collection_type, title, sub_title, items_left, items_total, cash_reward, respect_reward, district_pct_old, district_pct_new, district_name, save_in_mission, no_reward = vint_dataitem_get(di_h)
	
	if Hud_collection_initialized == false then
		--This gets called on subscription but we have nothing to process at boot... so we exit.
		Hud_collection_initialized = true
		return
	end

	--determine what kind of collection type we are and do some shit based on that...
	local collection_type = collection_type

	if title == 0 then
		--No data... Abort Collection screen.
		return
	end
	local gained_pct = district_pct_new - district_pct_old	
	
	--Queue up any data into memory...
	Queued_collection_data[Num_collection_data] = {
		collection_type = collection_type,
		title = title, 
		sub_title = sub_title, 
		items_left = items_left, 
		items_total = items_total, 
		cash_reward = cash_reward, 
		respect_reward = respect_reward, 
		district_pct_old = district_pct_old, 
		district_pct_new = district_pct_new, 
		district_name = district_name,
		save_in_mission = save_in_mission,
		no_reward = no_reward,
	}

	Num_collection_data = Num_collection_data + 1
	if Num_collection_data == 1 then
		hud_collection_start()
	end
end


function hud_collection_start()
	Hud_collection_is_active = true
	Hud_collection_data = Queued_collection_data[Current_collection_index]
	Current_collection_index = Current_collection_index + 1
	
	--Determine what rewards to display...
	Hud_collection_data.has_district 	= true
	Hud_collection_data.has_respect	 	= true
	Hud_collection_data.has_cash			= true
	
	if Hud_collection_data.district_pct_old == Hud_collection_data.district_pct_new then
		--No district
		Hud_collection_data.has_district = false
	end
	
	if Hud_collection_data.respect_reward == 0 then
		--No cash reward...
		Hud_collection_data.has_respect = false
	end
	
	if Hud_collection_data.cash_reward == 0 then
		--No cash reward...
		Hud_collection_data.shas_cash = false
	end
	
	--All reward elements start out hidden...
	Hud_collection_control_meter:set_alpha(0)
	Hud_collection_respect_meter:set_alpha(0)
	vint_set_property(Hud_collection_cash_h, "alpha", 0)
	
	
	--Initialize Control meter...
	Hud_collection_control_meter:update(Hud_collection_data.district_pct_old, false)
	
	--Do update of text items...
	local header_txt_h = vint_object_find("collection_header_txt")
	local insert_values = { [0] = Hud_collection_data.title, [1] = Hud_collection_data.items_left, [2] = Hud_collection_data.items_total}
	
	local text_string
	if Hud_collection_data.collection_type == HUD_COLLECTION_STAG then
		text_string = Hud_collection_data.title
	else
		text_string = vint_insert_values_in_string("{0} {1}/{2}", insert_values)
	end
	
	vint_set_property(header_txt_h, "text_tag", text_string)
	
	local sub_txt_h = vint_object_find("collection_sub_txt")
	vint_set_property(sub_txt_h, "text_tag", Hud_collection_data.sub_title)

	--Set cash total...
	vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(Hud_collection_data.cash_reward))
	
	--calculate widths of headers and cash
	local header_width, header_height = element_get_actual_size(header_txt_h)
	local header_sub_width, header_sub_height = element_get_actual_size(sub_txt_h)
	
	--Need to scale but by how much?
	local new_header_width = max(header_width, header_sub_width)
	local scale = 1.0
	local max_width = HUD_COLLECTION_HEADER_MAX_WIDTH
	
	if header_width > header_sub_width then
		if header_width > max_width then
			scale = max_width / header_width
			new_header_width = header_width * scale
		end
	else
		if header_sub_width > max_width then
			scale =  max_width / header_sub_width
			new_header_width = header_sub_width * scale
		end
	end
	
	--Apply scale to whole text group...
	local collection_title_grp_h = vint_object_find("collection_title_grp")
	vint_set_property(collection_title_grp_h, "scale", scale, scale)
	
	local pos_y = 102 * 3							--Start position for reward elements...
	local start_time = 1.5					--start offset for first reward...
	local start_time_spacing = 1.2		--Time between rewards..
	local header_width_min = 0 			-- min size of element 		
	local HUD_COLLECTION_TEXT_SPACING = 15 * 3
	--positions
	local title_x, title_y = vint_get_property(collection_title_grp_h, "anchor")
	local x, y = Hud_collection_control_meter:get_anchor()
	x = title_x + new_header_width + HUD_COLLECTION_TEXT_SPACING 
	
	--Positions for elements...
	local control_x 	= 0					
	local respect_x 	= 0
	local cash_x 		= 0
	
	--Start times for elements...
	local control_start_time 	= 0
	local respect_start_time 	= 0
	local cash_start_time 		= 0 
	local complete_start_time 	= 0
	
	local HUD_COLLECTION_ITEM_SPACING = 10 * 3
	
	--Determine what we have and then calculate each item based on that...
	if Hud_collection_data.has_district then
		local half_width = (HUD_COLLECTION_CONTROL_WIDTH *.5)
		control_x = x + half_width
		x = x + HUD_COLLECTION_CONTROL_WIDTH + HUD_COLLECTION_ITEM_SPACING
		
		control_start_time = start_time
		start_time =  start_time + start_time_spacing
	end
	
	if Hud_collection_data.has_respect then
		local half_width = (HUD_COLLECTION_RESPECT_WIDTH *.5)
		respect_x = x + half_width
		x = x + HUD_COLLECTION_RESPECT_WIDTH + HUD_COLLECTION_ITEM_SPACING
	
		respect_start_time = start_time
		start_time =  start_time + start_time_spacing
	end
	
	if Hud_collection_data.has_cash then
		local cash_width, cash_height = element_get_actual_size(Hud_collection_cash_h)
		local half_width = (cash_width *.5)
		cash_x = x  + half_width
		x = x + cash_width + HUD_COLLECTION_ITEM_SPACING		
		
		cash_start_time = start_time
	end


	local total_width = x							--total width of the element is x....	
	complete_start_time = start_time + 3		--Delay close out animation by 3 seconds...

	--Set positions...
	Hud_collection_control_meter:set_anchor(control_x, y)
	Hud_collection_respect_meter:set_anchor(respect_x, y)
	vint_set_property(Hud_collection_cash_h, "anchor", cash_x, y)
	
	local collection_elements_grp_h = vint_object_find("collection_elements_grp")
	local collection_x, collection_y = vint_get_property(collection_elements_grp_h, "anchor")
	collection_x = (640 * 3) - (total_width * 0.5)
	vint_set_property(collection_elements_grp_h, "anchor", collection_x, collection_y)
	
	--Unhide
	local h = vint_object_find("collection_grp")
	vint_set_property(h, "visible", true)
	
	
	--Playback animations at different times...
	
	-- Play back main animation....
	lua_play_anim(Hud_collection_anims.in_anim_h, 0)
	
	ui_audio_post_event("ui_generic_band_anim_in")
			
	--Play back animations... but only if they are needed... this is to prevent bad callbacks...
	if Hud_collection_data.has_district then
		lua_play_anim(Hud_collection_anims.district_anim_h, control_start_time)
	end
	if Hud_collection_data.has_respect then
		lua_play_anim(Hud_collection_anims.respect_anim_h, respect_start_time)
	end
	if Hud_collection_data.has_cash then
		lua_play_anim(Hud_collection_anims.cash_anim_h, cash_start_time)
	end
	
	--This animation closes it out...
	lua_play_anim(Hud_collection_anims.complete_anim_h, complete_start_time)
		
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	lua_play_anim(collection_hud_bg_tile_h)
	
	--Get audio string from collection type...
	local audio = Hud_collection_types[Hud_collection_data.collection_type].audio
	if audio ~= nil then
		--Play event...
		audio_object_post_event(audio, nil, nil, nil, false)
	end
end

function hud_collection_audio_out()
	ui_audio_post_event("ui_generic_band_anim_out")
end

function hud_collection_finished()

	--pause looping bg animation..
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	vint_set_property(collection_hud_bg_tile_h, "is_paused", true)
	
	--award the stuff for real...
	if Hud_collection_data.has_respect and Hud_collection_data.no_reward ~= true then
		game_award_respect(Hud_collection_data.respect_reward, STATS_INVALID, Hud_collection_types[Hud_collection_data.collection_type].d_type, Hud_collection_data.save_in_mission)		
	end
	if Hud_collection_data.has_cash and Hud_collection_data.no_reward ~= true then
		game_award_cash(Hud_collection_data.cash_reward, Hud_collection_types[Hud_collection_data.collection_type].d_type, Hud_collection_data.save_in_mission)			
	end

	if Current_collection_index == Num_collection_data then
		Num_collection_data = 0
		Current_collection_index = 0
		Queued_collection_data = { }
		Hud_collection_is_active = false
		
		--only save after last collection is done...
		game_autosave()
	else 
		hud_collection_start()
	end
end

-------------------------------------------------------------
-- Starts control meter fill/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_control()
	Hud_collection_control_meter:update(Hud_collection_data.district_pct_new, true)
end

-------------------------------------------------------------
-- Makes respect meter visible....(done via callback)
-------------------------------------------------------------
function hud_collection_show_respect()
	--Query respect meter for current values...
	local respect_total, respect_pct, respect_level = Hud_respect:get_data()

	--Initialize meter...
	Hud_collection_respect_meter:update_respect(Hud_collection_data.respect_reward, respect_pct, respect_level, false)
end

-------------------------------------------------------------
-- Starts respect meter fill/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_respect()

	-- Query for the new values...
	local respect_total_new, respect_pct_new, respect_level_new  = Hud_respect:get_data()

	--Start animationg the meter...
	Hud_collection_respect_meter:update_respect(Hud_collection_data.respect_reward, respect_pct_new, respect_level_new, true)
end

-------------------------------------------------------------
-- Starts cash count/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_cash()
	hud_collection_animate_cash()		
end

-----------------------------------------
--Cash count...
-----------------------------------------
function hud_collection_animate_cash()
   thread_new("hud_collection_anim_cash_thread")
end

function hud_collection_anim_cash_thread()
	--init stuff
	local start_cash = 0
	local cash_this_frame = -1
	local is_complete = false

	--get the variables from the global
	local cash = Hud_collection_data.cash_reward

	local amt_min = 100
	local amt_max = 5000
	
	local time_min = 300
	local time_max = 2999
	local init_time = floor(vint_get_time_index() * 1000)
	local cur_time = init_time
	local time_to_count = floor(time_min + ((time_max - time_min) * (cash / amt_max)))
	
	if time_to_count > time_max then
		time_to_count = time_max
	end
	
	--init sound IDs
	local activity_cash_count = 0
	local activity_cash_hit = 0

	while is_complete == false do
		cur_time = floor(vint_get_time_index() * 1000) - init_time
		
		--set my values
		cash_this_frame = cash * (cur_time / time_to_count)
		vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(cash_this_frame))
		
		if cur_time >= time_to_count then
			--game_audio_stop(activity_cash_count)
			--activity_cash_hit = game_audio_play(Completion_audio.cash_hit)
			vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(cash))
			is_complete = true
		end
		thread_yield()
	end		
end

-------------------------------------------------------------------------------
-- Pausing support for hud collection...
--
function hud_collection_game_is_paused(di_h)
	local is_paused = vint_dataitem_get(di_h)
	if Hud_collection_is_active then
		if is_paused == true then
			--Stop anims
			vint_set_property(Hud_collection_anims.complete_anim_h, "is_paused", true)
		else
			--Play all anims
			vint_set_property(Hud_collection_anims.complete_anim_h, "is_paused", false)
		end
	end
end-------------------------------------------------------------------------------
-- This deals with the notoriety icons around the minimap.
---------------------------------------------------------------------------------

--Notoriety States
local NOTO_STATE_INITIALIZE	= -1
local NOTO_STATE_HIDDEN 		= 0
local NOTO_STATE_VISIBLE 		= 1
local NOTO_STATE_ADD				= 2
local NOTO_STATE_REMOVE			= 3
local NOTO_STATE_DECAYING		= 4
local NOTO_STATE_INCREASING	= 5

-------------------------------------------------------------------------------
-- Hud notoriety data.
-- 
Hud_noto_data = {
	gangs = {
		cur_team = 0,
		cur_level = -1,
		teams = {
			["brotherhood"]	= 	{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
			["ronin"]	= 			{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
			["samedi"]	= 			{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
		},
		icons = {
			[1] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[2] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[3] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[4] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[5] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0}
		},
	},

	police = {
		cur_team = 0,
		cur_level = -1,
		teams = {
			["police"]	= {icon_image = "ui_hud_not_police", noto_level = -1},
		},
		icons = {
			[1] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[2] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[3] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[4] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[5] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0}
		},
	},
}

-------------------------------------------------------------------------------
-- Initialize and subscribe to data.
-- 
function hud_noto_init()

	--find reference base icons
	for i = 1, 5 do
		local gang_icon_h = vint_object_find("gang_noto_icon_" .. i)
		local police_icon_h = vint_object_find("police_noto_icon_" .. i)
		Hud_noto_data.gangs.icons[i].icon_h = gang_icon_h
		Hud_noto_data.police.icons[i].icon_h = police_icon_h
	end

	--decay tweens must play at the same time. so we start the animation but disable the tweens and enable them as we go.
	local decaying_anim_h = vint_object_find("noto_decaying_anim")
	local noto_decaying_twn_h = vint_object_find("noto_decaying_twn", decaying_anim_h)
	vint_set_property(noto_decaying_twn_h, "state", VINT_TWEEN_STATE_DISABLED)
	lua_play_anim(decaying_anim_h)
	
	--Notoriety
	vint_datagroup_add_subscription("sr2_notoriety", "update", "hud_noto_change")
	vint_datagroup_add_subscription("sr2_notoriety", "insert", "hud_noto_change")
end

-------------------------------------------------------------------------------
-- Datagroup callback
-- 
function hud_noto_change(data_item_h, event_name)
	local team_name, noto_level, noto_icon = vint_dataitem_get(data_item_h)
	local noto_data, display_data, icon_data, meter_data, team_data

	-- find the interesting data for team
	for key, noto_type in pairs(Hud_noto_data) do
		if noto_type.teams[team_name] ~= nil then
			noto_data = noto_type
			display_data = noto_type.teams[team_name]
			icon_data = noto_type.icons
			break
		end
	end

	if noto_data == nil then
		-- not an interesting team so outta here
		return
	end

	-- update the notoriety table
	display_data.noto_level = noto_level

	-- find the team in this group with highest notoriety
	noto_level = -1
	team_name = nil
	for key, value in pairs(noto_data.teams) do
		if value.noto_level > noto_level then
			team_name = key
			noto_level = value.noto_level
			team_data = value
		end
	end

	-- better safe then sorry
	if team_name == nil then
		return
	end

	local base_new_noto = floor(noto_level)
	local base_old_noto = floor(noto_data.cur_level)
	local icon_h = 0

	-- new team, animate in all icons
	if team_name ~= noto_data.cur_team then
		--update current image
		for i = 1, 5 do
			--Set image of icon...
			vint_set_property(noto_data.icons[i], "image", team_data.icon_image)
		
			--set the proper state for the icon...
			if base_new_noto >= i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			else
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			end
		end

		noto_data.cur_team = team_name
		
		--Make sure we are visible...
		hud_player_notoriety_show()

	-- noto on the rise, animate in all new icons
	elseif base_new_noto > base_old_noto then
		for i = 1, 5 do
			icon_h = noto_data.icons[i].icon_h
			if base_new_noto >= i and base_old_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			elseif base_new_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			else
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_VISIBLE)
			end
		end
		
		--Make sure we are visible...
		hud_player_notoriety_show()

	-- noto falling, animate the highest active icon
	elseif base_new_noto < base_old_noto then
		for i = 1, 5 do
			if base_new_noto == i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			elseif base_new_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			end
		end
	end

	-- update meter
	local part_new_noto = noto_level - base_new_noto
	

	--determine if we are still, decaying or increasing
	local noto_diff = noto_level - noto_data.cur_level
	if base_new_noto == base_old_noto then

		if noto_diff < -0.001 then
			--decaying...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_DECAYING)
				end
			end
		elseif noto_diff > 0.001 then
			--Increase...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_INCREASING)
				end
			end
		elseif abs(noto_level) > 0.0001 then
			--probably the same level again just make sure we are visible...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_VISIBLE)
				end
			end
		end
	end

	--store the current level to the notoriety type(gang or police)
	noto_data.cur_level = noto_level
	
	--Process the states...
	hud_noto_icon_process_state(noto_data)
	
	-- find lowest notoriety value
	local lowest_noto_level = 0
	local x_data = Hud_noto_data
	for key, noto_type in pairs(Hud_noto_data) do
		if noto_type.cur_level ~= -1 then
			if noto_type.cur_level > lowest_noto_level then
				lowest_noto_level = noto_type.cur_level
			end		
		end
	end
	
	--hide notoriety if we are less than 1.
	if lowest_noto_level < 1 then
		hud_player_notoriety_hide()
	end
end

-------------------------------------------------------------------------------
-- Icon set state
--
function hud_noto_icon_set_state(icon, state)
	if state == NOTO_STATE_ADD then
		if icon.state == NOTO_STATE_VISIBLE then
			--Don't try to re-add an icon.
			icon.state = NOTO_STATE_VISIBLE
		else
			icon.state = NOTO_STATE_ADD
		end
	elseif state == NOTO_STATE_REMOVE then
		if icon.state == NOTO_STATE_HIDDEN then
			--Don't try to re-hide an icon
			icon.state = NOTO_STATE_HIDDEN
		else
			icon.state = NOTO_STATE_REMOVE
		end
	elseif state == NOTO_STATE_VISIBLE then
		if icon.state == NOTO_STATE_ADD then
			--If the state is already adding, we just keep it that way instead of trying to force visible.
			icon.state = NOTO_STATE_ADD
		else
			icon.state = NOTO_STATE_VISIBLE
		end
	elseif state == NOTO_STATE_INCREASING then
		if icon.state == NOTO_STATE_ADD then
			--can't change to increasing if we are currently adding.
			icon.state = NOTO_STATE_ADD
		else
			icon.state = NOTO_STATE_INCREASING
		end		
	else
		icon.state = state
	end
end

-------------------------------------------------------------------------------
-- Silenetly resets the state. This happens after our ADD, REMOVE and PULSE
-- callbacks. This way we don't reprocess a hidden state.
--
function hud_noto_icon_set_state_silent(icon, state)
	icon.state = state
	icon.state_prev = state
end

-------------------------------------------------------------------------------
-- Processes the state for the specific noto type.
-- noto_type			(gang or police) Hud_noto_data.gang or Hud_noto_data.police
-- process_icon_id 	if icon# is specified, we will only process that icon.
--
function hud_noto_icon_process_state(noto_type)
	-- Loop through our icons and change state...
	for icon_id = 1, 5 do
		local icon = noto_type.icons[icon_id]
		local icon_h = icon.icon_h
		if icon.state ~= icon.state_prev then
			-- We need to change states now...
			if icon.state == NOTO_STATE_ADD then
				hud_noto_icon_add(icon_h, icon)
			elseif icon.state == NOTO_STATE_DECAYING then
				hud_noto_icon_decay(icon_h, icon)
			elseif icon.state == NOTO_STATE_INCREASING then
				hud_noto_icon_pulse(icon_h, icon)
			elseif icon.state == NOTO_STATE_REMOVE then
				hud_noto_icon_remove(icon_h, icon)
			elseif icon.state == NOTO_STATE_VISIBLE then
				hud_noto_icon_visible(icon_h, icon)	
			elseif icon.state == NOTO_STATE_HIDDEN then
				hud_noto_icon_hide(icon_h, icon)
			end
			icon.state_prev = icon.state
		end
	end
end

-------------------------------------------------------------------------------
-- Hides icons with animation...
-- 
function hud_noto_icon_remove(icon_h, icon)
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	--ANIMATE: Fade Icon Away
	local anim_3 = vint_object_find("noto_fade_out_anim")
	local anim_clone_3 = vint_object_clone(anim_3)

	--Targets
	local anim_3_alpha_tween = vint_object_find("noto_alpha_3", anim_clone_3)
	vint_set_property(anim_3_alpha_tween, "target_handle",	icon_h)

	--Reset Tween value
	local alpha_val = vint_get_property(icon_h, "alpha")
	vint_set_property_typed("float", anim_3_alpha_tween, "start_value", alpha_val)

	--Callback
	vint_set_property(anim_3_alpha_tween, "end_event",		"hud_noto_icon_hide_end")

	lua_play_anim(anim_clone_3, 0);

	icon.bmp_clone_0 = 0
	icon.bmp_clone_1 = 0
	icon.anim_0 = 0
	icon.anim_1 = 0
	icon.anim_2 = 0
	icon.anim_3 = anim_clone_3
	icon.tween_end = anim_3_alpha_tween
end

function hud_noto_icon_hide_end(tween_h, event_name)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_alpha_out == tween_h then
				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)
				vint_object_destroy(icon.anim_3)
				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.anim_3 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_HIDDEN)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Shows icons with animation...
-- 
function hud_noto_icon_add(icon_h, icon)
	vint_set_property(icon_h, "visible", true)

	--Destroy all objects if there are any currently being animated
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	--Create bitmap clones for animation
	local bmp_clone_0 = vint_object_clone(icon_h)
	local bmp_clone_1 = vint_object_clone(icon_h)
	vint_set_property(bmp_clone_0, "depth",	-1)
	vint_set_property(bmp_clone_1, "depth",	-2)

	--Clone the notoriety anim and adjust the childs targets

	--ANIMATION: Large to small
	local anim_0 = vint_object_find("noto_add_down_anim")
	local anim_clone_0 = vint_object_clone(anim_0)

	--Target Tweens
	local anim_0_alpha_tween = vint_object_find("noto_alpha_0", anim_clone_0)
	local anim_0_scale_tween = vint_object_find("noto_scale_0", anim_clone_0)
	vint_set_property(anim_0_alpha_tween, "target_handle",	bmp_clone_0)
	vint_set_property(anim_0_scale_tween, "target_handle",	bmp_clone_0)
	
	--ANIMATION: Small To Large
	local anim_1 = vint_object_find("noto_add_up_anim");
	local anim_clone_1 = vint_object_clone(anim_1)

	--Target Tweens
	local anim_1_alpha_tween = vint_object_find("noto_alpha_1", anim_clone_1)
	local anim_1_scale_tween = vint_object_find("noto_scale_1", anim_clone_1)
	vint_set_property(anim_1_alpha_tween, "target_handle",	bmp_clone_1)
	vint_set_property(anim_1_scale_tween, "target_handle",	bmp_clone_1)
	
	--ANIMATION: BASIC FADE IN
	local anim_2 = vint_object_find("noto_fade_in_anim")
	local anim_clone_2 = vint_object_clone(anim_2)
	
	--Target Tweens
	local anim_2_alpha_tween = vint_object_find("noto_alpha_2", anim_clone_2)
	vint_set_property(anim_2_alpha_tween, "target_handle",	icon_h)
	
	--Reset Properties to current value
	local alpha_val = vint_get_property(icon_h, "alpha")
	vint_set_property_typed("float", anim_2_alpha_tween, "start_value", alpha_val)

	--Setup callback
	vint_set_property(anim_0_scale_tween, "end_event",		"hud_noto_icon_add_end")
	
	--play anims
	lua_play_anim(anim_clone_0, 0);
	lua_play_anim(anim_clone_1, 0);
	lua_play_anim(anim_clone_2, 0);

	icon.bmp_clone_0 = bmp_clone_0
	icon.bmp_clone_1 = bmp_clone_1
	icon.anim_0 = anim_clone_0
	icon.anim_1 = anim_clone_1
	icon.anim_2 = anim_clone_2
	icon.anim_3 = 0
	icon.tween_end = anim_0_scale_tween
end

function hud_noto_icon_add_end(tween_h, event_name)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_end == tween_h then

				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)

				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_VISIBLE)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Starts decaying looping animation on specific icon.
--
function hud_noto_icon_decay(icon_h, icon)

	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", true)

	--This one is a little bit different because we want the tweens to stay in sync... so we just clone the tween.
	--Animation is already playing, cloning the tweens will keep them in sync.
	local decaying_anim_h = vint_object_find("noto_decaying_anim")
	local decay_twn_h = vint_object_find("noto_decaying_twn", decaying_anim_h)
	local decay_clone_twn_h = vint_object_clone(decay_twn_h)
	vint_set_property(decay_clone_twn_h, "state", VINT_TWEEN_STATE_RUNNING)
	vint_set_property(decay_clone_twn_h, "target_handle",	icon_h)
	
	--Store options to globals...
	icon.bmp_clone_0 = 0
	icon.bmp_clone_1 = 0
	icon.anim_0 = decay_clone_twn_h
	icon.anim_1 = 0
	icon.anim_2 = 0
	icon.anim_3 = 0
	icon.tween_end = 0
end

-------------------------------------------------------------------------------
-- Pleys pulse up animation on icon
--
function hud_noto_icon_pulse(icon_h, icon)

	--make sure we aren't already playing an animation, nuke it...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)
	
	--make sure our notoriety icon is visible.
	vint_set_property(icon_h, "visible", true)
	vint_set_property(icon_h, "alpha", 1)

	--Create bitmap clones for animation
	local bmp_clone_0 = vint_object_clone(icon_h)
	vint_set_property(bmp_clone_0, "depth",	-1)

	--Clone the notoriety anim and adjust the childs targets

	--ANIMATION: Small To Large
	local anim_0 = vint_object_find("noto_add_up_anim");
	local anim_clone_0 = vint_object_clone(anim_0)

	--Target Tweens
	local anim_0_alpha_tween = vint_object_find("noto_alpha_1", anim_clone_0)
	local anim_0_scale_tween = vint_object_find("noto_scale_1", anim_clone_0)
	vint_set_property(anim_0_alpha_tween, "target_handle",	bmp_clone_0)
	vint_set_property(anim_0_scale_tween, "target_handle",	bmp_clone_0)

	--Setup callback
	vint_set_property(anim_0_scale_tween, "end_event",		"hud_noto_icon_pulse_end")
	
	--play anims
	lua_play_anim(anim_clone_0, 0);

	icon.bmp_clone_0 = bmp_clone_0
	icon.anim_0 = anim_clone_0
	icon.tween_end = anim_0_scale_tween
end

function hud_noto_icon_pulse_end(tween_h, event)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_end == tween_h then
				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)

				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_VISIBLE)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Force show icon...
--
function hud_noto_icon_visible(icon_h, icon)
	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", true)
	vint_set_property(icon_h, "alpha", 1)
end

-------------------------------------------------------------------------------
-- Force hide icon.
--
function hud_noto_icon_hide(icon_h, icon)
	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", false)
	vint_set_property(icon_h, "alpha", 0)
end



-------------------------------------------------------------------------------
-- Expand notoriety bars...
-- 
function hud_player_notoriety_show()
	if Hud_notoriety.is_expanded ~= true then
		vint_set_property(vint_object_find("map_noteriety_contract"), "is_paused", true)
		lua_play_anim(vint_object_find("map_noteriety_expand"))
		Hud_notoriety.is_expanded = true
	end
end


-------------------------------------------------------------------------------
-- Retract notoriety bars...
-- 
function hud_player_notoriety_hide()
	if Hud_notoriety.is_expanded ~= false then
		vint_set_property(vint_object_find("map_noteriety_expand"), "is_paused", true)
		lua_play_anim(vint_object_find("map_noteriety_contract"))
		Hud_notoriety.is_expanded = false
	end
end