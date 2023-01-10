local HUD_RETICULE_OVERHEAT_RED 		= { R = 230/255, G = 5/255, B = 5/255}
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
end--]]