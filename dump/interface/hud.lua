HUD_DOC_HANDLE = -1


Hud_process_thread = -1

--Globals
MP_enabled = false

INVALID_HANDLE = -1
HUD_KILL_ICON = 0
HUD_DEFEND_ICON = 1
HUD_USE_ICON = 2
HUD_REVIVE_ICON = 3
HUD_LOCATION_ICON = 4  
HUD_COOP_ICON = 4 

local HUD_SPRINT_COLOR = { R = 246/255, G = 187/255, B = 79/255}

local HUD_MAP_OBJECTIVE_ICONS = {
	[HUD_KILL_ICON] = "uhd_ui_hud_gsi_obj_kill",
	[HUD_DEFEND_ICON] = "uhd_ui_hud_gsi_obj_protect",
	[HUD_USE_ICON] = "uhd_ui_hud_gsi_obj_use",
	[HUD_LOCATION_ICON] = "uhd_ui_hud_gsi_obj_goto",
}

local HUD_INTERACT_USE 			= 0
local HUD_INTERACT_VEHICLE 	= 1
local HUD_INTERACT_EQUIP		= 2
local HUD_INTERACT_PICKUP		= 2

HUD_DIVERSION_METER = 0
HUD_DIVERSION_METER = 1
HUD_DIVERSION_METER = 2




local INTERACT_TYPE_STRINGS = {
	[HUD_INTERACT_USE] = "Use",
	[HUD_INTERACT_VEHICLE] = "Hijack",
	[HUD_INTERACT_EQUIP] = "Equip",
	[HUD_INTERACT_PICKUP] = "Pickup",
}

Hud_notoriety = {
	is_expanded = true,
}

Hud_player_status = {
	cash = 0,
	bleed_out_health_pct = 1.0,
	is_in_satellite_mode = false,
	is_controlling_missile = false,
	health_recovering = false,
	respect_pct = -1,
	total_respect = -1,
	respect_level = -1,
	respect_show_upgrades = false,
	respect_is_hidden = false,
	orientation = 0,
	inventory_disabled = false,
	cruise_control_active = -1,
	cruise_control_h = -1,
	cruise_control_anim = -1,
	health_screen_is_fading = false,
}

			
Hud_cruise_control_hint_data = {
	{CTRL_BUTTON_DPAD_DOWN, "HUD_CRUISE_CONTROL_NO_BUTTON", game_get_key_name_for_action("CBA_VDC_CRUISE_CONTROL_B")},
}

--Bar for health around the minimap
local Hud_health_bar = {
	percent = -1,
	bg_h = 0, fill_h = 0, fill_1_h = 0,
	health_decay_anim_h 		= 0,
	health_flash_anim_h 		= 0,
	health_bg_angle_twn_h 	= 0,
	health_fill_angle_twn_h = 0,
	level_angles = {
		[0] = {fill_start_angle = 6.3, fill_end_angle = 3.142, angle_offset = 0.035}, --180
		[1] = {fill_start_angle = 6.3, fill_end_angle = 2.6774, angle_offset = 0.035}, 
		[2] = {fill_start_angle = 6.3, fill_end_angle = 2.2128, angle_offset = 0.035}, 
		[3] = {fill_start_angle = 6.3, fill_end_angle = 1.2836, angle_offset = 0.035},
		[4] = {fill_start_angle = 6.3, fill_end_angle = 0.819, angle_offset = 0.035}, --360
	},
	level = -1,
	is_flashing = false,
	is_decaying = false,
	is_expanded = true,			--Whether the meter is expanded or not
	timer_fade_out_anim_h = 0,	--Animation for waiting for the timer to retract...
}

--Bar for sprint around the minimap
local Hud_sprint_bar = {
	percent = -1,
	sprint_enabled = true,
	is_sprinting = -1,	
	bg_h = 0, fill_h = 0,
	level_angles = {
		[0] = {fill_start_angle = 6.3, fill_end_angle = 3.142, angle_offset = 0.035}, --180
		[1] = {fill_start_angle = 6.3, fill_end_angle = 2.6774, angle_offset = 0.035}, 
		[2] = {fill_start_angle = 6.3, fill_end_angle = 2.2128, angle_offset = 0.035}, 
		[3] = {fill_start_angle = 6.3, fill_end_angle = 1.2836, angle_offset = 0.035},
		[4] = {fill_start_angle = 6.3, fill_end_angle = 0.819, angle_offset = 0.035}, --360
	},
	level = -1,
	is_flashing = false,
	is_expanded = true,
	timer_fade_out_anim_h = 0, --Animation for waiting for the meter to retract...
}

--Respect VDO Object
Hud_respect = {}

Hud_enemy_status = {
	respect = -1,
	respect_needed = -1,
	respect_bar =	{ bg_h = 0, fill_0_h = 0, fill_1_h = 0, txt_grp = 0, txt = 0,
							start_angle = 0, end_angle = 3.14						
						}
}

Hud_weapon_status = {
	wpn_ready = true,
	wpn_bmp_name = -1,
	grenade_bmp_name = -1,
	fine_aim_transition = 0,
	sniper_visible = -1,
	show_reticule = false,
	weapon_ammo_string = -1,
	grenade_ammo_string = -1,
	weapon_is_hidden = -1,
	categories = {
		["WPNCAT_MELEE"] = "",
		["WPNCAT_PISTOL"] = "uhd_ui_menu_ammo_pistol",
		["WPNCAT_SHOTGUN"] = "uhd_ui_menu_ammo_shtgn",
		["WPNCAT_SUB_MACHINE_GUN"] = "uhd_ui_menu_ammo_smg",
		["WPNCAT_RIFLE"] = "uhd_ui_menu_ammo_rifle",
		["WPNCAT_SPECIAL"] = "uhd_ui_hud_ammo_sniper",
		["WPNCAT_THROWN"] = "",
		["WPNCAT_HAVOK"] = "uhd_ui_hud_ammo_missile",
	}
}

Hud_followers = {
	slot_arrange = {1, 2, 3},
	slot_objects = { {}, {}, {} },
	follower_data = {
		[1] = { head_img_name = "" },
		[2] = { head_img_name = "" },
		[3] = { head_img_name = "" },
	},
}

Hud_balance_status = {
	active = -1, 
	position = 0,
	balance_grp_h = 0,
	base_image_h = 0,
	arrow_image_h = 0,
	min_angle = -0.466,
	max_angle = 0.466,
	color_base = {43/255, 208/255, 0/255},
	color_alarm = {220/255, 40/255, 0/255},
	ls_btn = 0
}

Hud_vignettes = {
	health = {
		grp_h = -1,
		fade_anim_h = -1,
		fade_twn_h = -1,
		tint_anim_h = -1,
		tint_twn_h = -1
	},
	fine_aim_dim = {
		grp_h = -1,
	},
	tunnel_vision = {
		grp_h = -1,
		amount = 0
	}
}

Reticule_hits = {}

Hud_camera = {}

Hud_hit_elements = {
	main = -1,
	minor = -1,
	major = -1,
	anim = -1,
}

Hud_mp_snatch_elements = {
	main_grp_h = -1,
	head_img_bg_h = -1,
	recruitment_fill_h = -1,
}


Hud_smoked_busted = {}

local Hud_camera_screenshot_enabled = -1		--screenshot mode enabled?

Hud_current_veh_logo = 0
Hud_current_radio_station = 0
Hud_radio_show = false
Hud_map = {}

Hud_lockon = {
	color_locked = {r=.7,g=0,b=0},
	color_unlocked = {r=0,g=.8,b=0},
	color_ufo_locked = {r=.8,g=.23,b=.59},
	color_ufo_unlocked = {r=.8,g=.75,b=.33},
	base_pixel_size_hor = 94 * 3,
	base_pixel_size_vert = 94 * 3
}

local Hud_weapon_radial
Hud_gsi = -1
Hud_inventory = {
	stick_mag = 0,
	is_pressed = false,
}

Hud_radio_elements = {
	image_h = -1,
	arrow_left_h = -1,
	arrow_right_h = -1,
	anim = -1,
}

local Hud_cheat_elements = {
	image_grp_h = -1,
	image_h = -1,
	image_2_h = -1,
	image_anim_h = -1,
	images = {
		[1] = "uhd_ui_hud_icon_cheat_swap",
		[2] = "uhd_ui_hud_icon_cheat_shrink",
		[3] = "uhd_ui_hud_icon_cheat_lag",
		[4] = "uhd_ui_hud_icon_cheat_gimpy",
		[5] = "uhd_ui_hud_icon_cheat_slow",
	}
}

local Hud_sniper_hint_bar = -1
local Hud_sniper_button_hints = {
	{CTRL_BUTTON_Y, "HUD_SNIPER_ZOOM_IN", game_get_key_name_for_action("CBA_OFC_ZOOM_IN")},
	{CTRL_GAMEPLAY_BUTTON_A, "HUD_SNIPER_ZOOM_OUT", game_get_key_name_for_action("CBA_OFC_ZOOM_OUT")},
}

local Hud_vtol_button_hints = {
	{CTRL_GAMEPLAY_BUTTON_B, "SWITCH_MODE", game_get_key_name_for_action("CBA_VDC_VTOL_TRANSITION")},
}

local INV_WEAPON_SLOT_LAST_EQUIPPED = 12
local HUD_INVENTORY_DELAY = 0.15
	
--enums for genki
HUD_GENKI_ETHICAL = 1
HUD_GENKI_UNETHICAL = 2
HUD_GENKI_NONE = 3

Hud_genki_anims = {}
Hud_genki_images = {}

function hud_init()
		
	--Store document handle
	HUD_DOC_HANDLE = vint_document_find("hud")
	
	MP_enabled = mp_is_enabled()
	
	--Pause all animations
	vint_set_property(vint_object_find("vehicle_logo_anim_1"), "is_paused", true)
		
	vint_set_property(vint_object_find("map_objective_anim"), "is_paused", true)
	
	Hud_sniper_hint_bar = Vdo_hint_bar:new("sniper_btn_hints")
	hud_sniper_set_hints()
	
	--Map
	Hud_map.base_grp_h = vint_object_find("map_grp")
	
	--Respect
	Hud_respect = Vdo_respect_meter:new("respect_obj", 0, 0, "hud.lua", "Hud_respect")

	--Health Meter Setup
	local bar = Hud_health_bar
	bar.bg_h = vint_object_find("health_bar_bg")
	bar.fill_h = vint_object_find("health_bar")
	bar.fill_1_h = vint_object_find("health_bar_2")

	bar.health_decay_anim_h 		= vint_object_find("health_decay_anim")
	bar.health_flash_anim_h 		= vint_object_find("health_flash_anim")
	bar.health_bg_angle_twn_h 		= vint_object_find("health_bg_angle_twn")
	bar.health_fill_angle_twn_h 	= vint_object_find("health_fill_angle_twn")

	
	local fill_start_angle =  bar.level_angles[0].fill_start_angle
	local fill_end_angle =  bar.level_angles[0].fill_end_angle
	local angle_offset =  bar.level_angles[0].angle_offset
	
	vint_set_property(bar.bg_h, 		"start_angle", fill_start_angle + angle_offset)
	vint_set_property(bar.bg_h, 		"end_angle", 	fill_end_angle - angle_offset)
	vint_set_property(bar.fill_h,		"start_angle",	fill_start_angle)
	vint_set_property(bar.fill_h, 	"end_angle", 	fill_end_angle)
	vint_set_property(bar.fill_1_h,	"start_angle",	fill_start_angle)
	vint_set_property(bar.fill_1_h, 	"end_angle", 	fill_end_angle)

	--set callbacks for tweens...
	--Flash event callback...
	local health_flash_tween_complete_h = vint_object_find("health_flash_tween_complete")
	vint_set_property(health_flash_tween_complete_h, "end_event", "hud_health_flash_complete")
	
	--Start event for decay and end event for decay...
	vint_set_property(bar.health_bg_angle_twn_h, "start_event", "hud_health_decay_start")
	vint_set_property(bar.health_bg_angle_twn_h,	"end_event", 	"hud_health_decay_end")

	--Meter retraction animation and callbacks
	bar.timer_fade_out_anim_h = vint_object_find("map_health_timer_anim")
	local timer_twn_h = vint_object_find("health_timer_twn")
	vint_set_property(timer_twn_h, "end_event", "hud_player_health_hide")
	local timer_twn_h = vint_object_find("new_tween4_1_1")
	vint_set_property(timer_twn_h, "end_event", "hud_player_health_hide_alpha")
	
	--Sprint Meter Setup 
	bar = Hud_sprint_bar
	bar.bg_h = vint_object_find("sprint_bar_bg")
	bar.fill_h = vint_object_find("sprint_bar")
	
	local fill_start_angle =  bar.level_angles[0].fill_start_angle
	local fill_end_angle =  bar.level_angles[0].fill_end_angle
	local angle_offset =  bar.level_angles[0].angle_offset
	
	vint_set_property(bar.bg_h, 		"start_angle", fill_start_angle + angle_offset)
	vint_set_property(bar.bg_h, 		"end_angle", 	fill_end_angle - angle_offset)
	vint_set_property(bar.fill_h,		"start_angle",	fill_start_angle)
	vint_set_property(bar.fill_h, 	"end_angle", 	fill_end_angle)
	
	--Meter retraction animation and callbacks
	bar.timer_fade_out_anim_h = vint_object_find("map_sprint_timer_anim")
	local timer_twn_h = vint_object_find("sprint_timer_twn")
	vint_set_property(timer_twn_h, "end_event", "hud_player_sprint_hide")
	
	--Respect Timeout
	Hud_player_status.respect_timer_h = vint_object_find("respect_timer_anim")
	local timer_twn_h = vint_object_find("respect_timer_twn")
	vint_set_property(timer_twn_h, "end_event", "hud_player_respect_hide")

	--Weapon Timeout timer...
	local h = vint_object_find("weapon_timer_twn")
	vint_set_property(h, "end_event", "hud_weapon_fade_out")
	
	--Cash and hide it
	Hud_player_status.cash_h = vint_object_find("cash")
	vint_set_property(Hud_player_status.cash_h, "alpha", 0)
	
	--Ammo/Weapons
	Hud_weapon_status.weapon_base_h = vint_object_find("weapons_grp")								--Group containing weapon/grenade icons and count
	Hud_weapon_status.weapon_grp_h = vint_object_find("weapon_icons_grp")								--Group containing weapon/grenade icons and count
	
	Hud_weapon_status.weapon_ammo_txt_h = vint_object_find("weapon_ammo_txt")
	Hud_weapon_status.single_wpn_icon_h = vint_object_find("weapon_icon")
	Hud_weapon_status.dual_wpn_icon_1_h = vint_object_find("dual_weapon_1")
	Hud_weapon_status.dual_wpn_icon_2_h = vint_object_find("dual_weapon_2")
	
	Hud_weapon_status.sniper_ammo_txt_h = vint_object_find("sniper_ammo_txt")
	Hud_weapon_status.sniper_reload_txt_h = vint_object_find("sniper_reload_text")
	Hud_weapon_status.sniper_ammo_anim = vint_object_find("sniper_reload_anim", 0, HUD_DOC_HANDLE)
	
	Hud_weapon_status.grenade_ammo_txt_h = vint_object_find("grenade_ammo_txt")
	Hud_weapon_status.grenade_icon_h = vint_object_find("grenade_icon")

	Hud_weapon_status.grenade_holster_h = vint_object_find("grenade_holster")						--Bitmap for behind the grenade ammo text
	Hud_weapon_status.grenade_holster_extra_h = vint_object_find("grenade_holster_extra")		--Bitmap for extra holster extenstion (goes behind the grenade ammo text)
	
	--Balance Meter
	local balance_meter = vint_object_find("balance_meter")
	Hud_balance_status.balance_grp_h = balance_meter
	Hud_balance_status.base_grp_h = vint_object_find("base_grp", balance_meter)
	Hud_balance_status.arrow_image_h = vint_object_find("arrow_grp", balance_meter)
	Hud_balance_status.fade_out_anim_h = vint_object_find("balance_ls_fade_out")		-- Animation fades out left stick button
	
	Hud_balance_status.ls_btn = Vdo_hint_button:new("ls_btn", 0, HUD_DOC_HANDLE)
	Hud_balance_status.ls_btn:set_button(CTRL_BUTTON_LS)
	if game_is_active_input_gamepad() == false then
		Hud_balance_status.ls_btn:set_button(CTRL_BUTTON_LS, game_get_key_name_for_action("CAA_WALK_TURN_LEFT_RIGHT"))
	end
	
	--cheat icons
	Hud_cheat_elements.image_grp_h = vint_object_find("cheats_grp")
	Hud_cheat_elements.image_h = vint_object_find("cheat_icon")
	Hud_cheat_elements.image_2_h = vint_object_find("cheat_icon_2")
	Hud_cheat_elements.image_anim_h = vint_object_find("cheat_in_anim")
	
	--Vignette
	local h = vint_object_find("vignettes")
	Hud_vignettes.health.grp_h = vint_object_find("vignette_health", h )
	Hud_vignettes.health.fade_anim_h = vint_object_find("vignette_fade_anim")
	Hud_vignettes.health.fade_twn_h = vint_object_find("vignette_alpha_twn")
	Hud_vignettes.tunnel_vision.grp_h = vint_object_find("tunnel_vision", h)
	
	vint_set_property(Hud_vignettes.health.fade_twn_h, "end_event", "hud_health_screen_fade_complete")

	--Followers
	local master_follower_anim_0 = vint_object_find("follow_anim_0")
	local master_follower_anim_1 = vint_object_find("follow_anim_1")
	local master_count_tween_alpha = vint_object_find("follow_rev_count_alpha_0")

	for i = 1, 3 do
		local slot_object = Hud_followers.slot_objects[i]
		local grp = vint_object_find("follower_grp_" .. i)
		slot_object.name = i
		slot_object.head_img_h = vint_object_find("follower_head", grp)
		slot_object.frame_img_h = vint_object_find("follower_frame", grp)
		slot_object.revive_timer_h = vint_object_find("follower_count", grp)
		slot_object.visible = -1
		slot_object.group_h = grp

		--clone animations into slots
		local anim_0 = vint_object_clone(master_follower_anim_0)
		local anim_1 = vint_object_clone(master_follower_anim_1)
		slot_object.anim_0 = anim_0
		slot_object.anim_1 = anim_1
		vint_set_property(anim_0, "target_handle", grp)
		vint_set_property(anim_1, "target_handle", grp)

		--Duplicate Tweens for Counting Anim
		local count_tween_alpha_h = vint_object_clone(master_count_tween_alpha)
		vint_set_property(count_tween_alpha_h, "target_handle", slot_object.revive_timer_h)
	end
	
	--Hit Indicator 
	Hud_hit_elements.main_h = vint_object_find("hits")
	h = Hud_hit_elements.main_h 
	Hud_hit_elements.minor_h = vint_object_find("major", h)
	Hud_hit_elements.major_h = vint_object_find("major", h)
	Hud_hit_elements.anim_h = vint_object_find("hit_anim")

	--Cruise Control
	Hud_player_status.cruise_control_h = vint_object_find("cruise_control_grp")
	Hud_player_status.cruise_control_obj = Vdo_hint_bar:new("cruise_control_hint_bar", 0, HUD_DOC_HANDLE)
	Hud_player_status.cruise_control_anim = vint_object_find("cruise_control_fade_anim")

	--Hud Lockon
	
	Hud_lockon.lock_h = vint_object_find("lockon")
	Hud_lockon.lock1_h = vint_object_find("lockon_1", Hud_lockon.lockon_h )
	Hud_lockon.lock2_h = vint_object_find("lockon_2", Hud_lockon.lockon_h )
	Hud_lockon.lock3_h = vint_object_find("lockon_3", Hud_lockon.lockon_h )
	Hud_lockon.lock4_h = vint_object_find("lockon_4", Hud_lockon.lockon_h )
	
	Hud_lockon.lock_ufo_h = vint_object_find("lockon_ufo")
	
	Hud_lockon.lock_txt_grp_h = vint_object_find("lockon_txt_grp")
	Hud_lockon.lock_text_h = vint_object_find("lockon_txt", Hud_lockon.lock_txt_grp_h)
	Hud_lockon.lock_lock_h = vint_object_find("scan_lock", Hud_lockon.lock_txt_grp_h)
	Hud_lockon.lock_spinner_h = vint_object_find("scan_spinner", Hud_lockon.lock_txt_grp_h)
	Hud_lockon.lock_anim_h = vint_object_find("lockon_anim")
	
	lua_play_anim(Hud_lockon.lock_anim_h, 0, HUD_DOC_HANDLE)
	
	--lockon base screensize
	Hud_lockon.lock_base_hor_width, Hud_lockon.lock_base_hor_height = vint_get_property(Hud_lockon.lock2_h, "scale")
	Hud_lockon.lock_base_vert_width, Hud_lockon.lock_base_vert_height = vint_get_property(Hud_lockon.lock1_h, "scale")
	
	
	--initialize the radio elements
	Hud_radio_elements.image_h = vint_object_find("radio_station_image")
	Hud_radio_elements.arrow_left_h = vint_object_find("radio_left_arrow")
	Hud_radio_elements.arrow_right_h = vint_object_find("radio_right_arrow")
	Hud_radio_elements.hint_left_h = Vdo_hint_button:new("radio_hint_left", 0, HUD_DOC_HANDLE)
	Hud_radio_elements.hint_right_h = Vdo_hint_button:new("radio_hint_right", 0, HUD_DOC_HANDLE)
	Hud_radio_elements.anim = vint_object_find("radio_station_anim_1")
	
	--Initialize Gameplay Status Indicator
	Hud_gsi = Vdo_gsi:new("gsi")
	vint_datagroup_add_subscription("sr2_local_player_gameplay_indicator_status", "insert", "hud_gsi_vdo_update")
	vint_datagroup_add_subscription("sr2_local_player_gameplay_indicator_status", "update", "hud_gsi_vdo_update")
	
	--Find Genki anims and images
	Hud_genki_anims = {
		[HUD_GENKI_ETHICAL] = vint_object_find("genki_ethical_anim"),
		[HUD_GENKI_UNETHICAL] = vint_object_find("genki_unethical_anim"),
		[HUD_GENKI_NONE] = -1,
	}
	
	Hud_genki_images = {
		[HUD_GENKI_ETHICAL] = vint_object_find("ethical_img"),
		[HUD_GENKI_UNETHICAL] = vint_object_find("unethical_img"),
	}
	
	--Setup Camera hint for taking screenshots.
	-- Set Control Image...
	Hud_camera.hint_icon = Vdo_hint_button:new("camera_hint_button")
	Hud_camera.hint_button = CTRL_BUTTON_DPAD_DOWN
	Hud_camera.hint_key = game_get_key_name_for_action( "CBA_GAC_TAKE_SCREENSHOT" )

	--vint_set_property(camera_hint_icon_bmp_h, "image", get_dpad_down_image())
	
	--Initialize Mayhem Hud
	hud_mayhem_init()
	
	--Initialize Object Indicators
	--object_indicators_init()
	
	--Initialize Floating Healthbars (sewage version)
	hud_healthbars_init()
	
	--Initialize reticule related stuff,
	hud_reticules_init()
	
	hud_busted_init()
	
	--DISABLE Vehicle logo...
	local h = vint_object_find("vehicle_logo")
	vint_set_property(h, "visible", false)

	--Init VDO Objects
	--Weapon Radial VDO Initialize and Hide
	Hud_weapon_radial = Vdo_weapon_radial:new("radial_grp")
	Hud_weapon_radial:show(false)
		
	--Radial Menu Subscriptions
	vint_datagroup_add_subscription("sr2_local_player_inventory", "insert", "hud_radial_menu_update")
	vint_datagroup_add_subscription("sr2_local_player_inventory", "update", "hud_radial_menu_update")
	
	--Subscribe to datagroups and dataitems
	
	--Respect
	vint_dataitem_add_subscription("sr2_local_player_respect", "update", "hud_player_respect_change")
	
	--Initialize notoriety...
	hud_noto_init()
	--Hood
	vint_dataitem_add_subscription("sr2_local_player_hood", "update", "hud_player_hood_change")
	vint_dataitem_add_subscription("sr2_local_player_status", "update", "hud_player_status_change")

	--Followers
	vint_datagroup_add_subscription("sr2_local_player_followers", "insert", "hud_player_followers_change")
	vint_datagroup_add_subscription("sr2_local_player_followers", "update", "hud_player_followers_change")

	--Infrequent
	--..moving below followers, hopefully solves homie update issues (Derik)
	vint_dataitem_add_subscription("sr2_local_player_status_infrequent", "update", "hud_player_status_inf_change")
	
	--Weapons
	vint_dataitem_add_subscription("sr2_local_player_weapons", "update", "hud_player_weapon_change")
	vint_dataitem_add_subscription("sr2_local_player_frequent_weapon", "update", "hud_player_weapon_freq_change")
	vint_dataitem_add_subscription("sr2_local_player_satellite_weapon", "update", "hud_player_satellite_weapon")
	
	--Lockon
	vint_dataitem_add_subscription("sr2_local_player_lockon", "update", "hud_player_lockon_update")
	
	--Balance Meter
	vint_dataitem_add_subscription("sr2_balance_meter", "update", "hud_balance_meter_change")
	
	--Cheat icons
	vint_dataitem_add_subscription("hud_cheat_icons", "update", "hud_cheat_icon_update")

	--HUD Process Thread
	Hud_process_thread = thread_new("hud_process")
	
	--Giant Minimap Icon
	vint_dataitem_add_subscription("minimap_giant_icon", "update", "hud_map_objective_icon")
	
	--Hud collection init... (Flashpoint, Chopshop, Hitman, etc...)
	hud_collection_init()
end

function hud_cleanup()
	--kill threads

	--VDOWEAPON
	hud_inventory_hide()
	
	--unload vehicle logo
	game_peg_unload(Hud_current_veh_logo)
	
end

function hud_hide_map()
	vint_set_property(Hud_map.base_grp_h, "visible", false)
end

function hud_show_map()
	vint_set_property(Hud_map.base_grp_h, "visible", true)
end

--Updates the Hud Radial Menu VDO
function hud_radial_menu_update(di_h)
	Hud_weapon_radial:slots_update(di_h)
	
	--Make sure we have the right slot selected...
	if Hud_weapon_radial.equipped_grenade_slot > 0 then
		Hud_weapon_radial:weapon_highlight(Hud_weapon_radial.equipped_grenade_slot, true)
	end
	
	--Make sure we have the right slot selected...
	if Hud_weapon_radial.equipped_weapon_slot ~= -1 and Hud_weapon_radial.selected_weapon_slot == -1 then
		Hud_weapon_radial:weapon_highlight(Hud_weapon_radial.equipped_weapon_slot, true)
	end
end

--Inventory Control Mapping
function hud_inventory_input(event, value)
	if event == "inventory" then
--[[		if value > 0.4 then
			-- We're doing a fast weapon switch if you tap the button
			if Hud_inventory.is_pressed == false then
				if Hud_inventory.tap_thread == nil then
					Hud_inventory.tap_thread = thread_new( "hud_inventory_delayed_show" )
				end	
			end
		else
			if Hud_inventory.tap_thread == nil then
				--Normal inventory select...
				--Select Weapon
				Hud_weapon_radial:game_equip_selected_slots()
			
				--Hide Inventory
				hud_inventory_hide()
				Hud_inventory.is_pressed = false
			else
				--Tap thread style select.
				
				--only switch if the inventory is enabled
				if Hud_player_status.inventory_disabled == false then
					--Equip last equipped weapon...
					local success = game_use_radial_menu_item(INV_WEAPON_SLOT_LAST_EQUIPPED)
					if success then
						Hud_weapon_radial.equipped_weapon_slot = Hud_weapon_radial.selected_weapon_slot 
					end
				end
		
				thread_kill( Hud_inventory.tap_thread )
				Hud_inventory.tap_thread = nil
			end
		end--]]
	elseif event == "inventory_x" then
		--Move Analog Stick X
		Hud_inventory.x = value
		Hud_inventory.stale = true
		
	elseif event == "inventory_y" then
		--Move Analog Stick Y
		Hud_inventory.y = value
		Hud_inventory.stale = true

	elseif event == "inventory_up" and value > INVENTORY_DPAD_THRESHOLD then
		Hud_weapon_radial:weapon_highlight(8)
	elseif event == "inventory_right" and value > INVENTORY_DPAD_THRESHOLD then
		Hud_weapon_radial:weapon_highlight(9)
	elseif event == "inventory_down" and value > INVENTORY_DPAD_THRESHOLD then
		Hud_weapon_radial:weapon_highlight(10)
	elseif event == "inventory_left" and value > INVENTORY_DPAD_THRESHOLD then	
		Hud_weapon_radial:weapon_highlight(11)
	end
end

--Show Hud Inventory!!
function hud_inventory_show()

	game_hud_update_inventory()
	
	hud_weapon_hide()

	if Hud_inventory.thread == nil then
		game_UI_audio_play("UI_HUD_Open_Weapon_Radial")
		
		--TODO: Show Inventory
		Hud_weapon_radial:show(true)
		
		--Subscribe to input
		Hud_inventory.extra_buttons = {
		--	vint_subscribe_to_input_event("alt_select", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("select", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("exit", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("back", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("white", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("black", "hud_inventory_input"),
			vint_subscribe_to_input_event("map", "hud_inventory_input"),
			vint_subscribe_to_input_event("pause", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("scroll_up", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("scroll_down", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("scroll_left", "hud_inventory_input"),
		--	vint_subscribe_to_input_event("scroll_right", "hud_inventory_input"),
		}

		Hud_inventory.subs_x = vint_subscribe_to_raw_input("inventory_x", "hud_inventory_input")
		Hud_inventory.subs_y = vint_subscribe_to_raw_input("inventory_y", "hud_inventory_input")
		Hud_inventory.subs_up = vint_subscribe_to_raw_input("inventory_up", "hud_inventory_input")
		Hud_inventory.subs_right = vint_subscribe_to_raw_input("inventory_right", "hud_inventory_input")
		Hud_inventory.subs_down = vint_subscribe_to_raw_input("inventory_down", "hud_inventory_input")
		Hud_inventory.subs_left = vint_subscribe_to_raw_input("inventory_left", "hud_inventory_input")

		--Reset visual analog stick and get the proper text tag on it.
		Hud_inventory.x = 0
		Hud_inventory.y = 0
		
		--Highlight Currently equipped slots
		Hud_weapon_radial:weapon_highlight(Hud_weapon_radial.equipped_weapon_slot, true)
		if Hud_weapon_radial.equipped_grenade_slot > 0 then
			Hud_weapon_radial:weapon_highlight(Hud_weapon_radial.equipped_grenade_slot, true)
		end
		
		Hud_weapon_radial:stick_update_position(0, 0)
		Hud_weapon_radial:stick_update_tag()	
		Hud_weapon_radial:stick_arrow_reset()	

		Hud_inventory.thread = thread_new("hud_inventory_process")			
	end
end

function hud_inventory_hide(aborted)
	if Hud_inventory.thread ~= nil then
	
		if aborted == false then
			Hud_weapon_radial:game_equip_selected_slots()
		end
		
		--Hide Radial Menu
		Hud_weapon_radial:show(false)
		
		--Show weapon
		hud_weapon_show()
		
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_x)
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_y)
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_up)
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_right)
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_down)
		vint_unsubscribe_to_raw_input(Hud_inventory.subs_left)
		
		for idx, val in pairs(Hud_inventory.extra_buttons) do 
			vint_unsubscribe_to_input_event(val)
		end
		
		Hud_inventory.extra_buttons = nil				
		thread_kill(Hud_inventory.thread)
		Hud_inventory.thread = nil
		
	end
end


function hud_inventory_process()
	while true do 
		if Hud_inventory.stale == true then
		
			local x = Hud_inventory.x
			local y = Hud_inventory.y
			local selected_weapon_index = 0
			local mag = sqrt((x * x) + (y * y))
			local pi = 3.14159
			
			if mag > 0.5 then
				
				-- Y resolves out so don't bother with it
				x = x/mag
				local radians = acos(x)
				
				if y < 0.0 then
					radians = pi + (pi - radians)
				end
	
				local eighth = pi / 8
				local fourth = pi / 4
				local selected_weapon_index = 0
				
				if radians < eighth then
					selected_weapon_index = 2;
				elseif radians < (fourth + eighth) then
					selected_weapon_index = 1
				elseif radians < (2.0 * fourth + eighth) then
					selected_weapon_index = 0
				elseif radians < (3.0 * fourth + eighth) then
					selected_weapon_index = 7
				elseif radians < (4.0 * fourth + eighth) then
					selected_weapon_index = 6
				elseif radians < (5.0 * fourth + eighth) then
					selected_weapon_index = 5
				elseif radians < (6.0 * fourth + eighth) then
					selected_weapon_index = 4;
				elseif radians < (7.0 * fourth + eighth) then				
					selected_weapon_index = 3;
				else
					selected_weapon_index = 2;
				end

				--Change selected item in the menu
				--Hud_radial_menu_change_select(selected_weapon_index)	
				Hud_weapon_radial:weapon_highlight(selected_weapon_index)
				Hud_weapon_radial:stick_update_arrow(radians)
				
			end
	
			--Update Stick location on radial menu
			Hud_weapon_radial:stick_update_position(Hud_inventory.x, Hud_inventory.y)
			Hud_inventory.stick_mag = mag
			Hud_inventory.stale = false
		end
		thread_yield()
	end
end

function hud_gsi_vdo_update(di_h)
	if Hud_gsi ~= -1 then
		Hud_gsi:update(di_h)
	end
end
	
function hud_process()

	local display_cash = Hud_player_status.cash - 1 --Subtract one so it gets formatted in the loop.
	local hud_had_focus = nil
	
	while true do
		thread_yield()
		
		-- Animate Cash
		if display_cash ~= Hud_player_status.cash then
			local diff_cash = Hud_player_status.cash - display_cash
			
			if diff_cash > 5 or diff_cash < -5 then
				diff_cash = floor(diff_cash * 0.5)
			end
			
			display_cash = display_cash + diff_cash
			vint_set_property(Hud_player_status.cash_h, "text_tag", "$" .. format_cash(display_cash))
		end
		
		-- check to see if the hud has lost focus
		if hud_had_focus ~= Hud_has_focus then
			hud_had_focus = Hud_has_focus
		end
		
		local hud_msg_doc_h = vint_document_find("hud_msg")
		if hud_msg_doc_h ~= 0 then
			hud_msg_process()
		end
	end
end

function hud_player_hood_change(data_item_handle, event_name)
	local hood_name, cur_hood_owner, orig_hood_owner, is_contested = vint_dataitem_get(data_item_handle)

	-- this will become relevant for pushbacks and display of notoriety since we always will show
	-- gang noto for mission/activity gang or hood owner if hood is contested
end

function hud_player_status_inf_change(di_h, event_name)
	
	local cash, max_followers, inventory_disabled, vehicle_logo, radio_station, cruise_control_active, camera_screenshot_enabled, force_show_cash, show_vtol_hints	= vint_dataitem_get(di_h)
		
	local floored_cash = floor(cash)
	if cash ~= Hud_player_status.cash or force_show_cash then
		--Start up the cash display animation if the players cash updates
		local cash_anim_h = vint_object_find("cash_anim")

		--set first frame of animation to current alpha value of cash
		local cash_alpha = vint_get_property(Hud_player_status.cash_h, "alpha")
		local cash_anim_first_tween_h = vint_object_find("cash_anim_first_tween", cash_anim_h)
		vint_set_property(cash_anim_first_tween_h, "start_value", cash_alpha)
		
		lua_play_anim(cash_anim_h)
	end
	
	--Update cash (this gets read through hud_process() so it counts up nicely)
	Hud_player_status.cash = floored_cash
	
	if vehicle_logo == nil then
		vehicle_logo = 0
	end
	
	if radio_station == nil then
		radio_station = 0
	end
	
	-- Display a new vehicle logo
	if Hud_current_veh_logo ~= vehicle_logo then
	
		if Hud_current_veh_logo ~= "__unloaded" and Hud_current_veh_logo ~= 0 then
			game_peg_unload(Hud_current_veh_logo)
		end

		Hud_current_veh_logo = vehicle_logo		
		
		if vehicle_logo == "__unloaded" or vehicle_logo == 0 then				
			local o = vint_object_find("vehicle_logo")
			vint_set_property(o, "visible", false)			
		else		
			-- Load vehicle logo peg
			game_peg_load_with_cb("hud_set_vehicle_logo", 1, vehicle_logo)
		end
	end
		
	-- Display a new radio station
	if Hud_current_radio_station ~= radio_station then
		if radio_station ~= 0 then
			local radio_station_small
			if radio_station ~= "" then
				--build the radio image name
				radio_station_small = radio_station.."_sm"
				vint_set_property(Hud_radio_elements.image_h, "scale", 1.25, 1.25)
			else
				radio_station_small = "uhd_ui_menu_none"
				vint_set_property(Hud_radio_elements.image_h, "scale", 0.8, 0.8)
			end
			vint_set_property(Hud_radio_elements.image_h, "image", radio_station_small)
			local arrow_pad = 20 * 3
			local radio_w,radio_h = element_get_actual_size( Hud_radio_elements.image_h )
			local radio_x,radio_y = vint_get_property( Hud_radio_elements.image_h, "anchor" )
			local arrow_x,arrow_y = vint_get_property( Hud_radio_elements.arrow_left_h, "anchor" )
			
			local left_arrow_adjusted_x = radio_x - ((radio_w * 0.5) + arrow_pad)
			vint_set_property(Hud_radio_elements.arrow_left_h, "anchor", left_arrow_adjusted_x, arrow_y)
			
			local right_arrow_adjusted_x = radio_x + ((radio_w * 0.5) + arrow_pad)
			vint_set_property(Hud_radio_elements.arrow_right_h, "anchor", right_arrow_adjusted_x, arrow_y)
			
			if game_is_active_input_gamepad() == false then
				Hud_radio_elements.hint_right_h:set_visible( true )
				Hud_radio_elements.hint_left_h:set_visible( true )
				
				Hud_radio_elements.hint_right_h:set_button( nil, game_get_key_name_for_action( "CBA_VDC_NEXT_RADIO" ), false, true)
				Hud_radio_elements.hint_left_h:set_button( nil, game_get_key_name_for_action( "CBA_VDC_PREV_RADIO" ) , false, true)
				
				local hint_right_x,hint_right_y = 	Hud_radio_elements.hint_right_h:get_property( "anchor" )
				local hint_left_x,hint_left_y = 		Hud_radio_elements.hint_left_h:get_property( "anchor" )
				local hint_right_w,hint_right_h = 	Hud_radio_elements.hint_right_h:get_property( "screen_size" )
				local hint_left_w,hint_left_h = 		Hud_radio_elements.hint_left_h:get_property( "screen_size" )
				
				local new_hint_right_x = right_arrow_adjusted_x + (hint_right_w * 0.5)
				local new_hint_left_x = left_arrow_adjusted_x - (hint_left_w * 0.5)
				
				Hud_radio_elements.hint_right_h:set_property( "anchor", new_hint_right_x, hint_right_y )
				Hud_radio_elements.hint_left_h:set_property( "anchor", new_hint_left_x, hint_left_y )
			else
				Hud_radio_elements.hint_right_h:set_visible( false )
				Hud_radio_elements.hint_left_h:set_visible( false )
			end
			
			lua_play_anim( Hud_radio_elements.anim )
		end
	end
	
	Hud_current_radio_station = radio_station
	
	hud_cruise_control_update(cruise_control_active)
	
	if show_vtol_hints then
		hud_vtol_set_hints()
		Hud_sniper_hint_bar:set_visible(true)
	else
		Hud_sniper_hint_bar:set_visible(false)
	end
	
	if camera_screenshot_enabled ~= Hud_camera_screenshot_enabled then
		--show or hide screenshot hint... this is always on.
		local h = vint_object_find("screenshot_camera_hint_grp")
		vint_set_property(h, "visible", camera_screenshot_enabled)
		
		Hud_camera.hint_key = game_get_key_name_for_action( "CBA_GAC_TAKE_SCREENSHOT" )
		Hud_camera.hint_icon:set_button( Hud_camera.hint_button, Hud_camera.hint_key, false, false)
		
		Hud_camera_screenshot_enabled = camera_screenshot_enabled
	end
	
	local hint_icon_w,hint_icon_h = Hud_camera.hint_icon:get_size()
	local adjusted_hint_x = hint_icon_w * 0.5
	
	Hud_camera.hint_icon:set_property( "anchor", adjusted_hint_x, 0 )
	
	local camera_hint_icon_bmp_h = vint_object_find( "camera_hint_icon_bmp" )
	vint_set_property( camera_hint_icon_bmp_h, "anchor", hint_icon_w + (15 * 3), 0 )

end

function hud_set_vehicle_logo()
	local o = vint_object_find("vehicle_logo")
	vint_set_property(o, "image", Hud_current_veh_logo)
	lua_play_anim(vint_object_find("vehicle_logo_anim_1"), 0)
	vint_set_property(o, "visible", true)
end

function hud_player_status_change(di_h, event_name)
	--HUD dataitem is special and doesn't need any comments. FML. :/
	local sprint_enabled, health_pct, health_level, is_dbno, bleed_out_health_pct, sprint_pct, sprint_level, is_sprinting, orientation, is_mp_invulnerable, tunnel_vision_amount, is_in_satellite_mode, is_controlling_missile = vint_dataitem_get(di_h)
	
	local unhide_weapons = false

	-- Get health difference...
	local health_pct_diff = abs(Hud_health_bar.percent - health_pct)
	
	if health_pct_diff ~= 0 or health_level ~= Hud_health_bar.level then

		local bar = Hud_health_bar
		local level = health_level
	
		--get start/end angles depending on level...
		local start_angle_static	 = bar.level_angles[level].fill_start_angle
		local end_angle_static		 = bar.level_angles[level].fill_end_angle
		local angle_offset_static	 = bar.level_angles[level].angle_offset
		
		--Calculate current angles...
		local fill_end_angle =  (end_angle_static - start_angle_static) * health_pct + start_angle_static
		local bg_end_angle = fill_end_angle - angle_offset_static
		
		--if new health pct is less than current then do the animation of it dropping
		if health_pct < Hud_health_bar.percent then
			if bar.is_expanded == false then
				hud_player_health_show()
			end
			
			--Decrease the health meter
			hud_player_health_decrease_anim(bar, fill_end_angle, bg_end_angle)

			if health_pct < .3 then
				--Full screen health effect gets even heavier if it drops below .3
				local vignette_alpha = .70 - health_pct
				hud_health_screen_fade(vignette_alpha)

			elseif health_pct < .5 then
				--Full screen health effect if drops below .5
				local vignette_alpha = .5 - health_pct
				hud_health_screen_fade(vignette_alpha)
			end
			Hud_player_status.health_recovering = false
		elseif health_pct >= Hud_health_bar.percent then
			--Increase the health meter
			hud_player_health_increase_anim(bar, fill_end_angle, bg_end_angle)
			
			if Hud_player_status.health_recovering == false then
				hud_health_screen_fade(0)
				Hud_player_status.health_recovering = true
			end
		end
			
		if health_pct == 1 and bar.is_expanded == true then
			--Start to hide the bar.
			lua_play_anim(bar.timer_fade_out_anim_h)
		else
			vint_set_property(bar.timer_fade_out_anim_h, "is_paused", true)
		end

		--Make sure we can see the healthbar... 
		unhide_weapons = true
		
		Hud_health_bar.percent = health_pct
		Hud_health_bar.level = health_level
	end

	Hud_player_status.bleed_out_health_pct = bleed_out_health_pct
	Hud_player_status.is_in_satellite_mode = is_in_satellite_mode
	Hud_player_status.is_controlling_missile = is_controlling_missile

	local unhide_sprint = false 
	
	--Sprint
	-- Get Sprint difference...
	local sprint_pct_diff = abs(Hud_sprint_bar.percent - sprint_pct)

	if sprint_enabled == true and (sprint_pct_diff > .001 or sprint_level ~= Hud_sprint_bar.level) then
		local bar = Hud_sprint_bar
		local level = sprint_level
		
		--get start/end angles depending on level...
		local start_angle_static	 = bar.level_angles[level].fill_start_angle
		local end_angle_static		 = bar.level_angles[level].fill_end_angle
		local angle_offset_static	 = bar.level_angles[level].angle_offset
		
		--Calculate current angles...
		local fill_end_angle =  (end_angle_static - start_angle_static) * sprint_pct + start_angle_static
		local bg_end_angle = fill_end_angle - angle_offset_static
		
		
		unhide_sprint = true
		
		--Update angles for the sprint meter
		vint_set_property(bar.bg_h, "end_angle", bg_end_angle)
		
		--Hide bg of meter if sprint is empty.
		if sprint_pct == 0 then
			vint_set_property(bar.bg_h, "visible", false)
		else
			vint_set_property(bar.bg_h, "visible", true)
		end
		
		vint_set_property(bar.fill_h, "end_angle", fill_end_angle)

		--Make sure we can see the sprintbar... 
		unhide_weapons = true
		
		Hud_sprint_bar.sprint_percent = sprint_pct
		Hud_sprint_bar.level = sprint_level
	end
	
	if is_sprinting ~= Hud_player_status.is_sprinting then
		local sprint_anim_h = vint_object_find("sprint_pulse_anim")
		if is_sprinting == false then
			--Stop pulse animation and reset...
			vint_set_property(sprint_anim_h, "is_paused", true)
			vint_set_property(Hud_sprint_bar.fill_h, "tint", HUD_SPRINT_COLOR.R, HUD_SPRINT_COLOR.G, HUD_SPRINT_COLOR.B)
		else 
			lua_play_anim(sprint_anim_h)		
		end
	
		unhide_sprint = true
		
		--Store to global...
		Hud_player_status.is_sprinting = is_sprinting
	end

	
	if unhide_sprint == true then
		--Should we hide the sprint bar...
		local bar = Hud_sprint_bar
		
		if sprint_pct == 1 and bar.is_expanded == true then
			--Start to hide the bar.
			lua_play_anim(bar.timer_fade_out_anim_h)
		else
			vint_set_property(bar.timer_fade_out_anim_h, "is_paused", true)
		end
		
		--Attempt to show the sprint bar...
		hud_player_sprint_show()
		
		--Make sure we can see the sprintbar... 
		unhide_weapons = true
	end
	
	--If we updated the health or sprint... we unhide the weapons...
	if unhide_weapons == true then
		--fade in...
		hud_weapon_fade_in()
	end
	
	if orientation ~= Hud_player_status.orientation then
		--Rotate Hit Indicators to player rotation
		orientation = 3.14 - orientation
		vint_set_property(Hud_hit_elements.main_h, "rotation", orientation)
		Hud_player_status.orientation = orientation
	end
	
	--Sets the amount of tunnel vision for the player
	if tunnel_vision_amount ~= Hud_vignettes.tunnel_vision then--and
		vint_set_property(Hud_vignettes.tunnel_vision.grp_h, "alpha", tunnel_vision_amount)
	end
end

function hud_player_sprint_show()
	if Hud_sprint_bar.is_expanded == false then
		vint_set_property(vint_object_find("map_sprint_contract"), "is_paused", true)
		lua_play_anim(vint_object_find("map_sprint_expand"))
		Hud_sprint_bar.is_expanded = true
	end
end

--Plays the animation which retracts the sprint bar.
--This is triggered by a callback setup in the init()
function hud_player_sprint_hide()
	vint_set_property(vint_object_find("map_sprint_expand"), "is_paused", true)
	lua_play_anim(vint_object_find("map_sprint_contract"))
	Hud_sprint_bar.is_expanded = false
end

function hud_player_health_show()
	vint_set_property(vint_object_find("map_health_contract"), "is_paused", true)
	vint_set_property(vint_object_find("health_grp"), "alpha", 1.0)
	lua_play_anim(vint_object_find("map_health_expand"))
	Hud_health_bar.is_expanded = true
end

--Plays the animation which retracts the health bar.
--This is triggered by a callback setup in the init()
function hud_player_health_hide()
	vint_set_property(vint_object_find("map_health_expand"), "is_paused", true)
	lua_play_anim(vint_object_find("map_health_contract"))
	Hud_health_bar.is_expanded = false
end

function hud_player_health_hide_alpha()
	vint_set_property(vint_object_find("health_grp"), "alpha", 0.0)
end

function hud_player_health_decrease_anim(bar, fill_end_angle, bg_end_angle)


	--Flash the bar if we are not already flashing.
	if Hud_health_bar.is_flashing == false then
		lua_play_anim(bar.health_flash_anim_h, 0)
		Hud_health_bar.is_flashing = true
	end


	--Decay animation...
	if Hud_health_bar.is_decaying == false then
		--We aren't already decaying so its safe to replay the animation...
	
		--update the start values if we aren't decaying...
		local current_start_value = vint_get_property(bar.fill_1_h, "end_angle")
		local bg_start_angle = vint_get_property(bar.bg_h, "end_angle")
		
		vint_set_property(bar.health_bg_angle_twn_h, "start_value", bg_start_angle)
		vint_set_property(bar.health_fill_angle_twn_h, "start_value", current_start_value)
		
		lua_play_anim(bar.health_decay_anim_h, 0)
		-- The decaying flag will get set to true when the tween actually starts. until then we won't update that.
	end

	--change the state of the end tweens regardless if we are decaying or not...
	--Pop start of second bar to first
	vint_set_property(bar.fill_h, "end_angle", fill_end_angle)
	vint_set_property(bar.fill_1_h, "start_angle", fill_end_angle)

	--Set values for fill angle	
	vint_set_property(bar.health_fill_angle_twn_h, "end_value", fill_end_angle)
	
	--set values for bg end angle...
	vint_set_property(bar.health_bg_angle_twn_h, "end_value", bg_end_angle)
end

function hud_player_health_increase_anim(bar, fill_end_angle, bg_end_angle)
	--update the values directly...
	vint_set_property(bar.fill_h, "end_angle", fill_end_angle)
	vint_set_property(bar.fill_1_h, "end_angle", fill_end_angle)
	vint_set_property(bar.bg_h, "end_angle", bg_end_angle)
end

--Callbacks for health animations...
function hud_health_decay_start(twn_h)
	--set our decaying status to true
	Hud_health_bar.is_decaying = true
end

function hud_health_decay_end(twn_h)
	--set our decaying status to false...
	Hud_health_bar.is_decaying = false
end

function hud_health_flash_complete(twn_h)
	Hud_health_bar.is_flashing = false
end


--#####################################################
--Weapon Changes
--#####################################################

function hud_player_weapon_change(di_h, event_name)
--[[
		di->set_element(0, wpn_bmp_name);						// weapon image name
		di->set_element(1, ammo_ready);							// current ammo or < 0 if ammoless weapon
		di->set_element(2, ammo_reserve);						// ammo capacity
		di->set_element(3, grenade_bmp_name);					// greande image name
		di->set_element(4, grenade_ammo);						// current grenade ammo
		di->set_element(5, wpn_ready);							// weapon ready
		di->set_element(6, dual_wield);							// secondary weapon
		di->set_element(7, ammoless_wpn);						// infinite ammo
		di->set_element(8, ammo_infinite);						// infinite ammo
		di->set_element(9, grenade_ammo_infinite);			// infinite ammo
		di->set_element(10, continuous_fire);					// infinite ammo
		di->set_element(11, no_magazine);						// continuous fire (like water gun or flame thrower)
		di->set_element(12, pp->pflags.is_zoomed != 0);		// is the player vp zoomed (ala sniper rifle)
		di->set_element(13, cur_wpn_name);						// name of weapon
		di->set_element(14, cur_wpn_category_name);			// weapon category name
		di->set_element(15, reticle_highlight);				// enemy / friendly / none 
		di->set_element(16, cur_wpn_spread);					// weapon spread
		di->set_element(17, slot);									// slot the current weapon is in.
		di->set_element(18, grenade_slot);						// slot the current grenade is in.
		di->set_element(19, show_reticle);						// Show the reticle when in cover and aiming or in fine aim.
		di->set_element(20, overheat_pct);						// Overheat percentage
		di->set_element(21, is_overheated);						// Is overheated... (is the reticule overheated?)
		heat_pct, is_overheated 
		di->set_element(22, bullet_hit);							// bool did the shot hit something valid
		di->set_element(23, genki_target);						// genki target type (HUD_GENKI_NONE, HUD_GENKI_ETHICAL, HUD_GENKI_UNETHICAL)
		di->set_element(24, reloading);							// player is reloading
		
]]--
	local wpn_bmp_name, rdy_ammo, rsv_ammo, grenade_bmp_name, grenade_ammo, wpn_rdy, dual_wield, no_ammo, inf_ammo, gnd_inf_ammo, cont_fire, no_mag, sniper_visible, wpn_name, wpn_category, reticule_highlight, wpn_spread, wpn_slot, grenade_slot, show_reticule, overheat_pct, is_overheated, bullet_hit, genki_target, reloading  = vint_dataitem_get(di_h)	

	--Debug Ammo Dataitem...
	--dataitem_to_debug(di_h, "wpn_bmp_name", "rdy_ammo", "rsv_ammo", "grenade_bmp_name", "grenade_ammo", "wpn_rdy", "dual_wield", "no_ammo", "inf_ammo", "cont_fire", "no_mag", "sniper_visible", "wpn_name", "wpn_category", "reticule_highlight", "wpn_spread", "wpn_slot", "grenade_slot", "show_reticule", "overheat_pct", "is_overheated")
	
	--Set flag to determine if we should attemp to unhide the weapons...
	local unhide_weapons = false
	
	--Update weapon area...
	if wpn_bmp_name == nil then
		wpn_bmp_name = "uhd_ui_hud_inv_fist"
	end

	if dual_wield ~= Hud_weapon_status.dual_wield or wpn_bmp_name ~= Hud_weapon_status.wpn_bmp_name then
		if dual_wield == true then
			vint_set_property(Hud_weapon_status.dual_wpn_icon_1_h, "image", wpn_bmp_name)
			vint_set_property(Hud_weapon_status.dual_wpn_icon_2_h, "image", wpn_bmp_name)
		else
			vint_set_property(Hud_weapon_status.single_wpn_icon_h, "image", wpn_bmp_name)
		end
		unhide_weapons = true
		Hud_weapon_status.wpn_bmp_name = wpn_bmp_name
	end

	if dual_wield ~= Hud_weapon_status.dual_wield then
		vint_set_property(Hud_weapon_status.dual_wpn_icon_1_h, "visible", dual_wield)
		vint_set_property(Hud_weapon_status.dual_wpn_icon_2_h, "visible", dual_wield)
		vint_set_property(Hud_weapon_status.single_wpn_icon_h, "visible", not dual_wield)
		
		unhide_weapons = true
		Hud_weapon_status.dual_wield = dual_wield
	end
	
	-- Hide\Show grenade holster
	if grenade_bmp_name ~= Hud_weapon_status.grenade_bmp_name then
		if grenade_bmp_name ~= nil then
			--Set weapon bitmap...
			vint_set_property(Hud_weapon_status.grenade_icon_h, "image", grenade_bmp_name)		--Weapon Bitmap
			
			--Show objects...
			vint_set_property(Hud_weapon_status.grenade_icon_h, "visible", true)						--Weapon Bitmap
			vint_set_property(Hud_weapon_status.grenade_holster_h, "visible", true)					--Area for ammo...
			vint_set_property(Hud_weapon_status.grenade_holster_extra_h, "visible", true)			--Extra area for ammo
			vint_set_property(Hud_weapon_status.grenade_ammo_h, "visible", true)						--Ammo text
			
		else
			--Hide objects...
			vint_set_property(Hud_weapon_status.grenade_icon_h, "visible", false)					--Weapon Bitmap
			vint_set_property(Hud_weapon_status.grenade_holster_h, "visible", false)      		--Area for ammo...
			vint_set_property(Hud_weapon_status.grenade_holster_extra_h, "visible", false)		--Extra area for ammo
			vint_set_property(Hud_weapon_status.grenade_ammo_h, "visible", false)         		--Ammo text
		end
		
		unhide_weapons = true
		Hud_weapon_status.grenade_bmp_name = grenade_bmp_name
	end
	
	--Update Ammo Count
	local ammo_string = ""
	if no_ammo == false then
		if no_mag == true then
			if inf_ammo == false then
				if cont_fire == false then
					ammo_string = "" .. rdy_ammo + rsv_ammo
				else
					ammo_string = "" .. rdy_ammo + rsv_ammo
				end
			else
				ammo_string = "[image:uhd_ui_hud_base_smcirc_infinite]"
			end
		else
			if inf_ammo == false then
				if cont_fire == false then
					ammo_string = rdy_ammo .. "/" .. rsv_ammo
				else
					--debug_print("vint", "this should fire for grenade")
					ammo_string = floor(rdy_ammo / 100) .. "/" .. floor(rsv_ammo / 100)
				end
			else
				if cont_fire == false then
					ammo_string = rdy_ammo .. "/[image:uhd_ui_hud_base_smcirc_infinite]"
				else
					ammo_string = floor(rdy_ammo / 100) .. "/[image:uhd_ui_hud_base_smcirc_infinite]"
				end
			end
		end
	end

	--
	local grenade_ammo_string = ""
	if grenade_ammo > 0 then
		if gnd_inf_ammo == false then
			grenade_ammo_string = grenade_ammo
		else
			grenade_ammo_string = "[format][scale:1.0][image:uhd_ui_hud_base_smcirc_infinite][/format]"
		end
	end	
	
	vint_set_property(Hud_weapon_status.weapon_ammo_txt_h, "text_tag", ammo_string)
	vint_set_property(Hud_weapon_status.sniper_ammo_txt_h, "text_tag", ammo_string)
	vint_set_property(Hud_weapon_status.grenade_ammo_txt_h, "text_tag", grenade_ammo_string)
	Hud_weapon_status.show_reticule = show_reticule
	
	if reloading then
		vint_set_property(Hud_weapon_status.sniper_reload_txt_h, "visible", true)
		lua_play_anim(Hud_weapon_status.sniper_ammo_anim, 0, HUD_DOC_HANDLE)
	else
		vint_set_property(Hud_weapon_status.sniper_reload_txt_h, "visible", false)
	end

	--Unhide weapons if the ammo string has changed...
	if ammo_string ~= Hud_weapon_status.ammo_string then
		unhide_weapons = true
		Hud_weapon_status.ammo_string = ammo_string
	end

	if grenade_ammo_string ~= Hud_weapon_status.grenade_ammo_string then
		unhide_weapons = true
		Hud_weapon_status.grenade_ammo_string = grenade_ammo_string
	end
		
	--Dim Weapon if not ready
	if wpn_rdy ~= Hud_weapon_status.wpn_rdy then
		if wpn_rdy == true then
			--Show Weapon
			vint_set_property(Hud_weapon_status.weapon_grp_h, "alpha", 1)
						
			--TODO: Show and hide reticule need to be pulled out of here and moved into a function that stacks the reticule visibility.
			
			if Hud_weapon_status.sniper_visible == false and Hud_weapon_status.show_reticule == true then
				--Show reticule
				vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", true)
			else
				vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", false)
			end
		else
			--Dim Weapon
			vint_set_property(Hud_weapon_status.weapon_grp_h, "alpha", 0.67)
			
			--Hide reticule
			vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", false)
		end
		
		-- do not un hide weapons on weapon ready change... (JMH 10/14/2010)
		-- unhide_weapons = true
		Hud_weapon_status.wpn_rdy = wpn_rdy
	else
		-- Make sure we hide the reticule if it changes but weapon ready doesn't.
		vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", show_reticule)
	end
	
	--If sniper rifle is on then show the sniper rifle and not the standard reticule
	if sniper_visible ~= Hud_weapon_status.sniper_visible then
		if sniper_visible == true then
			vint_set_property(Hud_reticules.elements.sniper_h, "visible", true)
			vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", false)
			hud_sniper_set_hints()
			Hud_sniper_hint_bar:set_visible(true)
		else
			vint_set_property(Hud_reticules.elements.sniper_h, "visible", false)
			vint_set_property(Hud_reticules.elements.reticule_base_h, "visible", true)
			Hud_sniper_hint_bar:set_visible(false)
		end
		Hud_weapon_status.sniper_visible = sniper_visible
	end	

	--Change reticules if we have a different weapon
	if wpn_name ~= Hud_reticules.status.wpn_name or reticule_highlight ~= Hud_reticules.status.highlight  then
		Hud_reticule_update(wpn_name, wpn_category, reticule_highlight)
	end
	
	--Process a hit every frame
	Hud_reticule_process_hit(bullet_hit)

	--Do Weapon Spread
	if wpn_spread ~= Hud_reticules.status.wpn_spread then
		hud_reticule_spread_update(wpn_spread, Hud_reticules.configs[Hud_reticules.status.config].spread)
	end
	
	--Update current selections in the radial menu
	if wpn_slot ~= Hud_weapon_radial.equipped_weapon_slot then
		Hud_weapon_radial:weapon_highlight(wpn_slot, true)
		--unhide_weapons = true
	end
	if grenade_slot ~= Hud_weapon_radial.equipped_grenade_slot then
		Hud_weapon_radial:weapon_highlight(grenade_slot, true)
		--unhide_weapons = true
	end
	
	if grenade_slot == 0 then
		Hud_weapon_radial.equipped_grenade_slot = 0
	end
	
	hud_reticule_overheat_update(overheat_pct, is_overheated)
	
	if unhide_weapons == true then
		--fade in...
		hud_weapon_fade_in()
	end	

	-- Genki Ethical weapon stuff...
	-- ( Moved 7/28/2011 JMH ) - (This was setup as a Duplicate dataitem ignoring all 
	-- previous values except for this one not good considering this one gets called every time there is an ammo update)

	if genki_target ~= HUD_GENKI_NONE then
		vint_set_property(Hud_genki_images[HUD_GENKI_ETHICAL], "visible", true)
		vint_set_property(Hud_genki_images[HUD_GENKI_UNETHICAL], "visible", true)
		if genki_target == HUD_GENKI_ETHICAL then
			vint_set_property(Hud_genki_images[HUD_GENKI_UNETHICAL], "visible", false)
			vint_set_property(Hud_genki_anims[HUD_GENKI_UNETHICAL], "is_paused", true)
		elseif genki_target == HUD_GENKI_UNETHICAL then
			vint_set_property(Hud_genki_images[HUD_GENKI_ETHICAL], "visible", false)
			vint_set_property(Hud_genki_anims[HUD_GENKI_ETHICAL], "is_paused", true)
		end
		lua_play_anim(Hud_genki_anims[genki_target])
	end
end

function hud_sniper_set_hints()
	local Hud_sniper_button_hints = {
		{CTRL_BUTTON_Y, "HUD_SNIPER_ZOOM_IN", game_get_key_name_for_action("CBA_OFC_ZOOM_IN")},
		{CTRL_GAMEPLAY_BUTTON_A, "HUD_SNIPER_ZOOM_OUT", game_get_key_name_for_action("CBA_OFC_ZOOM_OUT")},
	}
	Hud_sniper_hint_bar:set_hints(Hud_sniper_button_hints)
	local width, height = Hud_sniper_hint_bar:get_size()
	local Hud_sniper_hint_bar_x,Hud_sniper_hint_bar_y = Hud_sniper_hint_bar:get_property("anchor")
	local x = -1*(width*0.5)
	vint_set_property(Hud_sniper_hint_bar.handle, "anchor", x, Hud_sniper_hint_bar_y)
	vint_set_property(Hud_sniper_hint_bar.handle, "alpha", 1.0)
	Hud_sniper_hint_bar:enable_text_shadow(false)
end

function hud_vtol_set_hints()

	Hud_vtol_button_hints = {
		{CTRL_GAMEPLAY_BUTTON_B, "SWITCH_MODE", game_get_key_name_for_action("CBA_VDC_VTOL_TRANSITION")},
	}
	Hud_sniper_hint_bar:set_hints(Hud_vtol_button_hints)
	local width, height = Hud_sniper_hint_bar:get_size()
	local Hud_sniper_hint_bar_x,Hud_sniper_hint_bar_y = Hud_sniper_hint_bar:get_property("anchor")
	local x = -1*(width*0.5)
	vint_set_property(Hud_sniper_hint_bar.handle, "anchor", x, Hud_sniper_hint_bar_y)
	vint_set_property(Hud_sniper_hint_bar.handle, "alpha", 0.67)
	Hud_sniper_hint_bar:enable_text_shadow(true)
end

function hud_weapon_fade_in()
	--Fade in only if we aren't hidden...
	if Hud_weapon_status.weapon_is_hidden == true then
		--Get alpha of weapon group so we don't fade in from nothing... if it is partially shown...
		local weapon_base_alpha = vint_get_property(Hud_weapon_status.weapon_base_h, "alpha")
		local weapon_fade_in_anim_h = vint_object_find("weapon_fade_in_anim")
		local weapon_fade_in_twn_h = vint_object_find("weapon_fade_in_twn", weapon_fade_in_anim_h)
		vint_set_property(weapon_fade_in_twn_h, "start_value", weapon_base_alpha)

		--Play the fade in anim...
		lua_play_anim(weapon_fade_in_anim_h)
		Hud_weapon_status.weapon_is_hidden = false
		
		
		local h = vint_object_find("weapon_fade_out_anim")
		vint_set_property(h, "is_paused", true)
	end
	
	lua_play_anim(vint_object_find("weapon_timer_anim"))
end
	

function hud_weapon_fade_out()
	lua_play_anim(vint_object_find("weapon_fade_out_anim"))
	Hud_weapon_status.weapon_is_hidden = true
end

function hud_weapon_show()
	--vint_set_property(Hud_weapon_status.weapon_base_h,"visible",true)	
end

function hud_weapon_hide()
	--vint_set_property(Hud_weapon_status.weapon_base_h,"visible",false)	
end

function hud_player_weapon_freq_change(di_h)
	local ammo_ready, reticle_highlight, cur_wpn_spread, fine_aim_transition, water_pressure, x_screen_coord, y_screen_coord, reticule_opacity = vint_dataitem_get(di_h)
	if fine_aim_transition ~= Hud_weapon_status.fine_aim_transition then
		hud_reticule_spread_update(cur_wpn_spread, Hud_reticules.configs[Hud_reticules.status.config].spread)
		if fine_aim_transition == nil then
			fine_aim_transition  = 0
		end
		
		--Fine aim minimap off...
		local tranny = 1.2 - fine_aim_transition
		tranny = limit(tranny, 0, 1)
		vint_set_property(Hud_map.base_grp_h, "alpha", tranny)
		Hud_weapon_status.fine_aim_transition = fine_aim_transition
	end
	
	--Update pressure
	hud_reticule_update_pressure(water_pressure)
		
	--Change x y screen coords of reticule
	hud_reticule_change_position(x_screen_coord, y_screen_coord)
	
	--Update x y coords of predator reticule...
	hud_predator_change_position(x_screen_coord, y_screen_coord)
	
	--Update Reticle Opacity
	hud_reticule_opacity_update(reticule_opacity)
end

function hud_player_satellite_weapon(di_h)
	-- TODO: finish
end


function hud_player_respect_change(di_h)
	--[[
		respect_total		= total respect earned
		respect_needed		= respect % to reach next level
		respect_level		= current respect level
		show_upgrades		= should we show the "upgrade ready" indication
	]]--
	local total_respect, respect_pct, respect_level, show_upgrades, force_show_respect = vint_dataitem_get(di_h)
	
--	debug_print("vint", "total_respect" .. var_to_string(total_respect) .. "\n")
--	debug_print("vint", "respect_pct" .. 	var_to_string(respect_pct) .. "\n")
--	debug_print("vint", "respect_level" .. var_to_string(respect_level) .. "\n")
--	debug_print("vint", "show_upgrades" .. var_to_string(show_upgrades) .. "\n")
	
	local respect_meter_show_upgrade = false	--Flag to determine if we want to actually show upgrades...
	if Hud_player_status.respect_show_upgrades ~= show_upgrades then
		-- Upgrade flag changed... so we need to do something...
		
		--We are done showing upgrades...
		if show_upgrades == false then
			--Have respect animate back to normal...
			Hud_respect:game_is_finished_showing_upgrades()
			--Reset Fade out timer. :)
			lua_play_anim(Hud_player_status.respect_timer_h)
		else
			--We actually need to show upgrades on for this update...
			respect_meter_show_upgrade = true
		end
		Hud_player_status.respect_show_upgrades = show_upgrades
	end
	
	if Hud_player_status.total_respect ~= total_respect or Hud_player_status.respect_pct ~= respect_pct or respect_level ~= Hud_player_status.respect_level then
		Hud_respect:update_respect(total_respect, respect_pct, respect_level, respect_meter_show_upgrade)
		Hud_player_status.total_respect = total_respect
		Hud_player_status.respect_pct = respect_pct
		Hud_player_status.respect_level = respect_level
	end
	
	-- force_show_respect causes respect to be shown.  no condition check is needed.
	if Hud_player_status.respect_is_hidden == true then
		lua_play_anim(vint_object_find("respect_fade_in_anim"))
		Hud_player_status.respect_is_hidden = false
	end
	
	lua_play_anim(Hud_player_status.respect_timer_h)
end

--Plays the animation which hides the respect bar...
--This is triggered by a callback setup in the init()
function hud_player_respect_hide()
	if Hud_player_status.respect_is_hidden ~= true then
		if Hud_respect:can_hide() then
			--Check if we can hide first...
			lua_play_anim(vint_object_find("respect_fade_out_anim"))
			Hud_player_status.respect_is_hidden = true
		else
			--If we can't hide then restart start the timer tween...
			lua_play_anim(Hud_player_status.respect_timer_h)
		end
	end
end

-- Plays the animation which hides the respect bar...
-- Hides the respect but immediatly... triggered by flashpoint complete..
function hud_player_respect_force_hide()
	if Hud_respect:can_hide() then
		--Check if we can hide first...
		Hud_respect:set_alpha(0)
		Hud_player_status.respect_is_hidden = true
	else
		--If we can't hide then restart start the timer tween...
		lua_play_anim(Hud_player_status.respect_timer_h)
	end
end

function hud_player_followers_change(di_h)
	local slot, head_img_name, hlth_pct, revive_time, slot_visible = vint_dataitem_get(di_h)

	--No slots other than 1 to 3 allowed.
	if slot < 1 or slot > 3 then
		return
	end
	
	--Show or hide slot
	if slot_visible ~= Hud_followers.slot_objects[slot].visible then
		vint_set_property(Hud_followers.slot_objects[slot].group_h, "visible", slot_visible)
		Hud_followers.slot_objects[slot].visible = slot_visible
	end
	
	local data = Hud_followers.follower_data[slot]
	local objects = Hud_followers.slot_objects[slot]
	
	if head_img_name ~= data.head_img_name then
		if head_img_name == nil then
			--No homie head
			--hide the icon in the homie slot by playing the close animation
			vint_set_property(objects.anim_0, "is_paused", true)
			
			--match alpha level of our tween to current value.
			local alpha_level = vint_get_property(objects.head_img_h, "alpha")
			local twn_h = vint_object_find("follow_head_alpha_tween_1", objects.anim_1)
			vint_set_property(twn_h, "start_value", alpha_level)
			
			--Play fade out anim...
			lua_play_anim(objects.anim_1, 0)
			
			--Be sure the timer is hidden too
			vint_set_property(objects.revive_timer_h, "visible", false)
		else
			if data.head_img_name == nil then
				vint_set_property(objects.anim_1, "is_paused", true)
				lua_play_anim(objects.anim_0, 0)
			end
			
			--Reset the head image 
			vint_set_property(objects.head_img_h, "image", head_img_name)
			
			end
		data.head_img_name = head_img_name
	end

	--take damage only if health changed..
	if hlth_pct ~= data.hlth_pct then
		--make sure we've inited already...
		if data.hlth_pct ~= nil then
			local target_alpha = 1
			if hlth_pct < .33 then
				target_alpha = hlth_pct + .33
				if hlth_pct == 0 then
					target_alpha = 0.5
				end
			end	
			vint_set_property(objects.head_img_h, "alpha", target_alpha )
		end
		--Store data...
		data.hlth_pct = hlth_pct
	end
	
	--Revives (This is the counter that shows up over the homie heads)
	revive_time = floor(revive_time)
	if revive_time ~= data.revive_time then
		if revive_time == 0 and data.revive_time ~= 0 then
			vint_set_property(objects.revive_timer_h, "visible", false)
			vint_set_property(vint_object_find("follow_rev_anim"),"is_paused", true)
		elseif revive_time ~= 0 and data.revive_time == 0 then
			vint_set_property(objects.revive_timer_h, "visible", true)
			--vint_set_property(vint_object_find("follow_rev_anim"),"is_paused", false)
			lua_play_anim(vint_object_find("follow_rev_anim"))
		end
		if revive_time ~= 0 then
			lua_play_anim(vint_object_find("follow_rev_anim"))
		end
		--Update Revive Time
		vint_set_property(objects.revive_timer_h, "text_tag", revive_time)
		data.revive_time = revive_time
	end
end

function hud_balance_meter_change(di_h)

	--	active		bool		is the meter active?
	--	position		float		-1 to 1 indicating the position on the meter	
	local active, position = vint_dataitem_get(di_h)
	local force_update = false
	

	
--	debug_print("vint", "active: " .. var_to_string(active) .. "| position: " .. position .. "\n")
	
	--Update visibility
	if Hud_balance_status.active ~= active then
		if active == true then
			vint_set_property(Hud_balance_status.balance_grp_h, "visible", true)
			
			--Fade out left stick after a little while...
			lua_play_anim(Hud_balance_status.fade_out_anim_h)
		else
			vint_set_property(Hud_balance_status.balance_grp_h, "visible", false)
		end
		force_update = true
		Hud_balance_status.active = active
	end
	
	--Update Position and Color
	if Hud_balance_status.position ~= position or force_update == true then
		
		--Calculate Angle
		local angle = position * Hud_balance_status.max_angle
		
		--Calculate Color
		local color_r, color_g, color_b
		local p_val = abs(position)
		
		
		
		color_r = Hud_balance_status.color_base[1] - p_val * (Hud_balance_status.color_base[1] - Hud_balance_status.color_alarm[1])
		color_g = Hud_balance_status.color_base[2] - p_val * (Hud_balance_status.color_base[2] - Hud_balance_status.color_alarm[2])
		color_b = Hud_balance_status.color_base[3] - p_val * (Hud_balance_status.color_base[3] - Hud_balance_status.color_alarm[3])
			
		--Set Props
		vint_set_property(Hud_balance_status.arrow_image_h, "rotation", angle)
		vint_set_property(Hud_balance_status.base_grp_h, "tint", color_r, color_g, color_b)
		
		Hud_balance_status.position = position 
	end
end

--Health Vignette
function hud_health_screen_fade(target_alpha)
	if Hud_player_status.health_screen_is_fading == true then
		--screen is already fading... just update the end alpha...
		vint_set_property(Hud_vignettes.health.fade_twn_h, "end_value", target_alpha)
	else
		--screen is not fading so we need to restart the animation...
		local current_alpha = vint_get_property(Hud_vignettes.health.grp_h, "alpha")
		vint_set_property(Hud_vignettes.health.fade_twn_h, "start_value", current_alpha)
		vint_set_property(Hud_vignettes.health.fade_twn_h, "end_value", target_alpha)
		lua_play_anim(Hud_vignettes.health.fade_anim_h, 0)
		Hud_player_status.health_screen_is_fading = true
	end
end

function hud_health_screen_fade_complete()
	Hud_player_status.health_screen_is_fading = false
end


--========================================================
--HUD Hits
--Things around the reticule
--========================================================
function Hud_hit_add(di_h)
	local hit_index = di_h
	local direction, strength = vint_dataitem_get(di_h)
	local hit_bmp_h, hit_anim_h, hit_twn_h, fade_time, stick_time

	--Check if major/minor hit
	if strength > .3 then
		hit_bmp_h = vint_object_clone(Hud_hit_elements.major_h)
		stick_time = .5
		fade_time = .5
	else
		hit_bmp_h = vint_object_clone(Hud_hit_elements.minor_h)
		stick_time = .25
		fade_time = .25
	end
	
	vint_set_property(hit_bmp_h, "visible", true)
	vint_set_property(hit_bmp_h, "rotation", direction)
	
	--Tween Fade out, Set Callback
	hit_anim_h = vint_object_clone(Hud_hit_elements.anim_h)	
	hit_twn_h =  vint_object_find("hit_twn", hit_anim_h)
	vint_set_property(hit_twn_h, "target_handle", hit_bmp_h)
	vint_set_property(hit_twn_h, "duration", fade_time)
	vint_set_property(hit_twn_h, "end_event", "hud_hit_fade_end")
	
	lua_play_anim(hit_anim_h, stick_time)
	
	--Store Reticule Information for further processing
	Reticule_hits[hit_index] = {
		hit_bmp_h = hit_bmp_h,
		hit_twn_h = hit_twn_h,
		hit_anim_h = hit_anim_h,
		direction = direction,
		strength = strength,
	}
end

function hud_hit_fade_end(twn_h, event_name)
	--Clean up reticule hits
	for index, value in pairs(Reticule_hits) do
		if value.hit_twn_h == twn_h then
			vint_object_destroy(value.hit_anim_h)
			vint_object_destroy(value.hit_twn_h)
			vint_object_destroy(value.hit_bmp_h)
			Reticule_hits[index] = nil
		end
	end
end

function hud_hits_updates_pos(x_screen_coord, y_screen_coord)
	--y screen coordinate
	local x, y = vint_get_property(Hud_hit_elements.main_h, "anchor")
	vint_set_property(Hud_hit_elements.main_h, "anchor", x_screen_coord, y_screen_coord)
end

--Clears all indicators if called, designed to be called via C++
function hud_hit_clear_all()
	for index, value in pairs(Reticule_hits) do
		vint_object_destroy(value.hit_anim_h)
		vint_object_destroy(value.hit_twn_h)
		vint_object_destroy(value.hit_bmp_h)
	end
	Reticule_hits = {}
end


--##################################################################### 
--Showing/Hiding the hud
--#####################################################################

local HUD_ELEM_GSI = 0

Hud_elements = {
	[0] = { 	-- HUD_ELEM_GSI
		target_doc = nil,
		grp_name = "base_gsi",				
	},
	[1] = { 	-- HUD_ELEM_MINIMAP
		target_doc = nil,
		grp_name = "base_mini_map",	
	},
	[2] = {	-- HUD_ELEM_RETICLE
		target_doc = nil,
		grp_name = "base_reticle",				
	},
	[3] = {	-- HUD_ELEM_HIT_INDICATORS
		target_doc = nil,
		grp_name = "base_reticle_hits",
	},
	[4] = {	-- HUD_ELEM_WEAPONS
		target_doc = nil,
		grp_name = "base_weapons",
	},
	[5] = {	-- HUD_ELEM_CASH_RESPECT_HOMEY
		target_doc = nil,
		grp_name = "base_cash_respect_homey", 
	},
	[6] = {	--	HUD_ELEM_WEAPON_SWAP_MESSAGE
		target_doc = nil,
		grp_name = "base_weapon_swap_message",
	},
	[7] = {	-- HUD_ELEM_RADIO_STATION
		target_doc = nil,
		grp_name = "base_radio_station",		
	},
	[8] = {	-- HUD_ELEM_VEHICLE_NAME
		target_doc = nil,
		grp_name = "base_vehicle_name",
	},
	[9] = { -- HUD_ELEM_DIVERSIONS
		target_doc = "hud_diversion",
		grp_name = nil,
	},
	[10] = { -- HUD_ELEM_MESSAGES,
		target_doc = "hud_msg",
		grp_name = "messages_grp",
	},
	[11] = { -- HUD_ELEM_TUTORIAL_HELP,
		target_doc = "tutorial",
		grp_name = "tutorial_base_grp",
	},
	[12] = { -- HUD_ELEM_FULL_SCREEN_EFFECT
		target_doc = nil,
		grp_name = "base_full_screen_effect",
	},
	[13] = { -- HUD_ELEM_SUBTITLES
		target_doc = "hud_msg",
		grp_name = "subtitles_grp",
	},
	[14] = { -- HUD_ELEM_OI
		target_doc = "object_indicator",
		grp_name = "oi_base_grp",		
	},
}

Hud_element_tweens = {}

-- hud fade parameters
-- transparency
local HUD_FADE_HIDDEN 		= 0
local HUD_FADE_TRANSPARENT = 1
local HUD_FADE_VISIBLE 		= 2
-- fade duration
local HUD_FADE_DURATION_FADE 			= 0
local HUD_FADE_DURATION_IMMEDIATE 	= 1

local Hud_tween_fade_duration = 0.25

--Fades a particular element
function hud_element_fade(element_id, fade, duration)
	if duration == nil then
		duration = HUD_FADE_DURATION_FADE
	end
	--fade: 0 = hidden,	1 = transparent, 2 = visible
	local element_group
	local target_document_name
	local grp_name
	
	if element_id == HUD_ELEM_GSI and horde_mode_is_active() then
		target_document_name = "hud_whored"
		grp_name = "base_gsi"
	else 
		target_document_name = Hud_elements[element_id].target_doc
		grp_name = Hud_elements[element_id].grp_name
	end
	
	--Set alpha based on fade
	local target_alpha
	if fade == HUD_FADE_HIDDEN then
		target_alpha = 0
	elseif fade == HUD_FADE_TRANSPARENT then
		target_alpha = .35
	else
		target_alpha = 1
	end

	-- Set the actual duration
	local actual_duration
	if (duration == HUD_FADE_DURATION_FADE) then
		actual_duration = Hud_tween_fade_duration
	else 
		actual_duration = 0
	end
	
	local grp_h, current_alpha, twn_h
	
	--Figure out which document the elements exist in
	local target_doc_h = HUD_DOC_HANDLE
	if target_document_name ~= nil then
		target_doc_h = vint_document_find(target_document_name)
		if target_doc_h == 0 then
			--This document is not loaded for whatever reason exit
			return
		end
	end

	if grp_name ~= nil then
		--get the group object to fade
		grp_h = vint_object_find(grp_name, nil, target_doc_h)
	else 
		grp_h = vint_object_find("safe_frame", nil, target_doc_h)
	end
			
	--Verify that we aren't already fading something
	for idx, val in pairs(Hud_element_tweens) do
		if grp_h == val.grp_h then
			--tween exist so delete the tween
			vint_object_destroy(idx)
			Hud_element_tweens[idx] = nil
		end
	end
			
	--Get Current Alpha of object
	current_alpha = vint_get_property(grp_h, "alpha")
			
	local hud_root_animation =  vint_object_find("root_animation", nil, target_doc_h)
			
	--Create Tween and set values
	twn_h = vint_object_create("hud_fade_tweens", "tween", hud_root_animation, target_doc_h)

	vint_set_property(twn_h, "duration", actual_duration)	--Fade time
	vint_set_property(twn_h, "target_handle", grp_h)
	vint_set_property(twn_h, "target_property", "alpha")
	vint_set_property(twn_h, "start_value", current_alpha)
	vint_set_property(twn_h, "end_value", target_alpha)
	vint_set_property(twn_h, "start_time",	vint_get_time_index(target_doc_h))
	vint_set_property(twn_h, "is_paused", false)
			
	--Set callback
	vint_set_property(twn_h, "end_event", "hud_element_fade_end")
		
	--Store for cleanup
	Hud_element_tweens[twn_h] = {
		grp_h = grp_h
	}
end

function hud_element_fade_end(tween_h, event_name)
	--Delete all fade tweens and references
	vint_object_destroy(tween_h)
	Hud_element_tweens[tween_h] = nil
end

---------[ BUSTED/SMOKED ]---------

function hud_busted_init()
	Hud_smoked_busted.handles = {}
	
	Hud_smoked_busted.handles.grp = vint_object_find("smoked_busted")
	vint_set_property(Hud_smoked_busted.handles.grp, "visible", false)
	
	--Fade In animations
	Hud_smoked_busted.handles.fade_in_anim = vint_object_find("sb_fade_in")
	vint_set_property(Hud_smoked_busted.handles.fade_in_anim , "is_paused", true)
end

function hud_busted_complete()
end

function hud_busted_fade_in(smoked, delay, fade_time)
	local msg, effect, color
	if smoked == true then
		msg = "GAMEPLAY_SMOKED"
		effect = "smoked"
		color = {r = .9, g = .9, b = .9}
	else
		msg = "GAMEPLAY_BUSTED"
		effect = "busted"
		color = {r = .9, g = .9, b = .9}
	end
	
	--Show Smoked busted text
	vint_set_property(Hud_smoked_busted.handles.grp, "visible", true)
	vint_set_property(Hud_smoked_busted.handles.grp, "alpha", 0)
	vint_set_property(Hud_smoked_busted.handles.grp, "tint", color.r, color.g, color.b)
	
	--Busted/Smoked text fade in
	--JM: Removing "You're Smoked" and "Busted" text.
	vint_set_property(vint_object_find("sb_text"), "text_tag", " ") --msg)
	lua_play_anim(Hud_smoked_busted.handles.fade_in_anim)
	
	--Start Interface effect
	game_interface_effect_begin(effect, 1, .5, true)
end

function hud_effect_smoked()
	game_interface_effect_begin("smoked", 1, 1, true)
end

function hud_effect_busted()
	game_interface_effect_begin("busted", 1, 1, true)
end

function hud_effect_pause()
	game_interface_effect_begin("pause", 1, 1)
end

function hud_effect_end()
	game_interface_effect_end()
end

function hud_player_reset_complete()
	--Reset the busted state
	game_interface_effect_end(0)
	--Hide Smoked busted text
	vint_set_property(Hud_smoked_busted.handles.grp, "visible", false)
end

---------[ COLLECTION MESSAGES ]---------

--Hud_collection_msgs = { num_msgs = 0 }

-- you can also call this to clear any existing messages
function hud_collection_msg_init()
--[[
	Hud_collection_msgs = { num_msgs = 0 }
	vint_set_property(vint_object_find("collection_msg"), "alpha", 0)
	vint_set_property(vint_object_find("collection_msg"), "visible", true)
	vint_set_property(vint_object_find("collection_anim"), "is_paused", true)
	vint_set_property(vint_object_find("collection_msg_alpha_twn_2"), "end_event", "hud_collection_msg_end")
	]]
end

function hud_collection_msg_show(m)
--[[
	local header_text_h = vint_object_find("collection_header_text")
	local body_text_h = vint_object_find("collection_body_text")
	
	vint_set_property(header_text_h , "text_tag", m.header)
	
	local y_ornate_offset = 0
	if m.body ~= nil then
		vint_set_property(body_text_h, "text_tag", m.body)
		vint_set_property(body_text_h, "visible", true)
	else
		vint_set_property(body_text_h, "visible", false)	
		--No body text so adjust the ornate
		y_ornate_offset = -10
	end

	-- Hide the stuff about getting smoked like Thanksgiving turkey
	vint_set_property(Hud_smoked_busted.handles.fade_in_anim , "is_paused", true)
	vint_set_property(Hud_smoked_busted.handles.grp, "visible", false)
	vint_set_property(Hud_smoked_busted.handles.grp, "alpha", 0)
	
	lua_play_anim(vint_object_find("collection_anim"))

	if m.audio >= 0 then
		game_UI_audio_play(m.audio)
	end
	]]
end

function hud_collection_msg_end()
--[[
	if Hud_collection_msgs.num_msgs > 0 then
		-- remove element 0 and push others up
		for i = 0, Hud_collection_msgs.num_msgs - 2 do
			Hud_collection_msgs[i] = Hud_collection_msgs[i + 1]
		end
		
		Hud_collection_msgs[Hud_collection_msgs.num_msgs - 1] = nil
		Hud_collection_msgs.num_msgs = Hud_collection_msgs.num_msgs - 1
		
		if Hud_collection_msgs.num_msgs > 0 then
			hud_collection_msg_show(Hud_collection_msgs[0])
		end
	end
	]]
end

function hud_collection_msg_new(header, body, audio, win_status)
--[[
	--TODO: ADD Header/Body/Win Status support (the body can be nil)

	local m = { header = header, body = body, win_status = win_status, audio = audio }
	Hud_collection_msgs[Hud_collection_msgs.num_msgs] = m
	Hud_collection_msgs.num_msgs = Hud_collection_msgs.num_msgs + 1

	if Hud_collection_msgs.num_msgs == 1 then
		hud_collection_msg_show(m)
	end
	]]
end


--===================================================
--Cruise Control
--===================================================
function hud_cruise_control_update(is_active)
	if is_active ~= Hud_player_status.cruise_control_active then
		if is_active == true then
			--Show Cruise Control Status and let it fade with the animation.
			vint_set_property(Hud_player_status.cruise_control_h, "visible", true)
			vint_set_property(Hud_player_status.cruise_control_h, "alpha", .8)
			lua_play_anim(Hud_player_status.cruise_control_anim, 0)

			Hud_cruise_control_hint_data = {
				{CTRL_BUTTON_DPAD_DOWN, "HUD_CRUISE_CONTROL_NO_BUTTON", game_get_key_name_for_action("CBA_VDC_CRUISE_CONTROL_B")},
			}
			Hud_player_status.cruise_control_obj:set_hints(Hud_cruise_control_hint_data)
			local width, height = Hud_player_status.cruise_control_obj:get_size()
			local x, y = vint_get_property(Hud_player_status.cruise_control_obj.handle, "anchor")
			vint_set_property(Hud_player_status.cruise_control_obj.handle, "anchor",  - (width * 0.5), y)
		else
			--Hide status
			vint_set_property(Hud_player_status.cruise_control_h, "visible", false)
		end
	Hud_player_status.cruise_control_active = is_active
	end
end

function hud_cruise_control_update_pos(x_pos, y_pos)
	local x, y = vint_get_property(Hud_player_status.cruise_control_h, "anchor")
	vint_set_property(Hud_player_status.cruise_control_h, "anchor", x_pos, y_pos)
end


--===================================================
--Player Lockon
--===================================================

function hud_player_lockon_update(di_h)
	
	local x, y, width, rotation, is_locked, is_visible, is_ufo = vint_dataitem_get(di_h)
	
	if is_visible == false then
		vint_set_property(Hud_lockon.lock_ufo_h, "visible", false)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "visible", false)
		vint_set_property(Hud_lockon.lock_h, "visible", false)
		return
	end
	
	-----------------
	--for ufo vehicle
	-----------------
	if is_ufo == true then
		vint_set_property(Hud_lockon.lock_ufo_h, "anchor", x, y)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "anchor", x, y)
		
		--Scale (avoid getting really big)
		local scale = width/100
		
		
		if scale > 1 then
			scale = 1 + (scale-1)/5
		end
		
		if scale > 3 then
			scale = 3
		end
		
		vint_set_property(Hud_lockon.lock_ufo_h, "anchor", x, y)
		vint_set_property(Hud_lockon.lock_ufo_h, "scale", scale, scale)
		vint_set_property(Hud_lockon.lock_ufo_h, "rotation", rotation)
		
		--Tint lockon
		local color
		if is_locked == true then
			color = Hud_lockon.color_ufo_locked
		else
			color = Hud_lockon.color_ufo_unlocked	
		end
		vint_set_property(Hud_lockon.lock_ufo_h, "tint", color.r, color.g, color.b)
			
		--Show lockon
		vint_set_property(Hud_lockon.lock_ufo_h, "visible", true)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "visible", false)
	
	--------------------
	--for other vehicles
	--------------------
	else
		vint_set_property(Hud_lockon.lock_h, "anchor", x, y)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "anchor", x, y)
		
		--Scale
		local scale = width/100
		local scale_hor = width/100--Hud_lockon.base_pixel_size_hor
		local scale_vert = width/100--Hud_lockon.base_pixel_size_vert
			
		vint_set_property(Hud_lockon.lock_h, "anchor", x, y)
		vint_set_property(Hud_lockon.lock_h, "scale", scale, scale)
		vint_set_property(Hud_lockon.lock_h, "rotation", rotation)
			
		vint_set_property(Hud_lockon.lock_txt_grp_h, "scale", scale, scale)
				
		local lock_vert_height = Hud_lockon.lock_base_vert_height / scale_vert
		local lock_hor_height = Hud_lockon.lock_base_hor_height / scale_hor
			
		--Rescale Innards
		vint_set_property(Hud_lockon.lock1_h, "scale",Hud_lockon.lock_base_vert_width, lock_vert_height)
		vint_set_property(Hud_lockon.lock2_h, "scale", Hud_lockon.lock_base_hor_width, lock_hor_height)
		vint_set_property(Hud_lockon.lock3_h, "scale", Hud_lockon.lock_base_hor_width, lock_hor_height)
		vint_set_property(Hud_lockon.lock4_h, "scale", Hud_lockon.lock_base_vert_width, lock_vert_height)
			
		if is_locked then
			vint_set_property(Hud_lockon.lock_lock_h,"visible",true)
			vint_set_property(Hud_lockon.lock_spinner_h,"visible",false)
			vint_set_property(Hud_lockon.lock_text_h,"text_tag","HUD_LOCKON_TARGET_LOCKED")
		else
			vint_set_property(Hud_lockon.lock_lock_h,"visible",false)
			vint_set_property(Hud_lockon.lock_spinner_h,"visible",true)
			vint_set_property(Hud_lockon.lock_text_h,"text_tag","HUD_LOCKON_SCANNING")
		end
		--Tint lockon
		local color
		if is_locked == true then
			color = Hud_lockon.color_locked
		else
			color = Hud_lockon.color_unlocked	
		end
		vint_set_property(Hud_lockon.lock_h, "tint", color.r, color.g, color.b)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "tint", color.r, color.g, color.b)
		
		--Show lockon
		vint_set_property(Hud_lockon.lock_h, "visible", true)
		vint_set_property(Hud_lockon.lock_txt_grp_h, "visible", true)
	end
end



function hud_cheat_icon_update(di_h)
	--	active	bool	is the cheat active?
	--	icon		int	0: INVALID, 1: Inverted controls, 2: Size reduction, 3: Lag, 4: Lame weapon, 5: Slow
	local active, icon = vint_dataitem_get(di_h)
	
	vint_set_property(Hud_cheat_elements.image_grp_h, "visible", active)
	vint_set_property(Hud_cheat_elements.image_h, "image", Hud_cheat_elements.images[icon])
	vint_set_property(Hud_cheat_elements.image_2_h, "image", Hud_cheat_elements.images[icon])
	if active then
		lua_play_anim(Hud_cheat_elements.image_anim_h, 0, HUD_DOC_HANDLE)
	end
end

-------------------------------------------------------------------------------
-- Updates and Plays the Icon Objective Over the minimap.
-------------------------------------------------------------------------------
function hud_map_objective_icon(di_h)
	
	--[[
			Making it a data vacuum. Be advised.
	
	local objective_enum, count = vint_dataitem_get(di_h)
	local icon_name

	if objective_enum == INVALID_HANDLE then
		return
	end
	
	if HUD_MAP_OBJECTIVE_ICONS[objective_enum] ~= nil then
		icon_name = HUD_MAP_OBJECTIVE_ICONS[objective_enum]
	else
		icon_name = HUD_MAP_OBJECTIVE_ICONS[HUD_KILL_ICON]
	end
	
	local map_bmp = vint_object_find("map_objective_icon")
	vint_set_property(map_bmp, "image", icon_name)
	vint_set_property(map_bmp, "visible", true)
	
	local anim_h = vint_object_find("map_objective_anim")
	lua_play_anim(anim_h)
	
	]]
end

--[[
-------------------------------------------------------------------------------
-- Displays on the HUD that the player can interact with objects
-- (Y) ENTER VEHICLE
-------------------------------------------------------------------------------
function hud_game_interact_update(di_h)
	-- button_is_visible		is the button visible? determined by game_audio_play
	-- interact_type			an enum based on the type of player interaction  [INTERACT_TYPE_STRINGS]
	local button_is_visible, interact_type = vint_dataitem_get(di_h)
	local interact_grp = vint_object_find("interact_grp")
	
	if button_is_visible == true then
		vint_set_property(interact_grp, "visible", true)
		
		--Set Text
		local interact_button_bmp = vint_object_find("interact_button")
		local interact_text = vint_object_find("interact_text")
		local interact_string = INTERACT_TYPE_STRINGS[interact_type]
		vint_set_property(interact_text, "text_tag", interact_string)
		
		--Set Size of Background
		local bg = vint_object_find("bg", interact_grp)
		local x, y = vint_get_property(interact_text, "anchor")
		local width, height = element_get_actual_size(interact_text)
		
		--Resize teh background
		local bg_width, bg_height = element_get_actual_size(bg)
		element_set_actual_size(bg, (width + x + 30), height)
	else
		vint_set_property(interact_grp, "visible", false)
	end
end
]]--
E_
--Constants...	
local MAYHEM_DISPLAY_TYPE_CASH	 	= 0
local MAYHEM_DISPLAY_TYPE_POINTS 	= 1
local MAYHEM_DISPLAY_TYPE_SEC 		= 2
local MAYHEM_DISPLAY_TYPE_SEC_2 		= 3
local MAYHEM_DISPLAY_TYPE_CUSTOM 	= 4

Hud_mayhem_elements = {
	in_game_grp_h = -1,
	bonus_grp_h = -1,
	bonus_item_grp_h = -1,
	bonus_grp_start_x = -1,
	bonus_grp_start_y = -1,
}

Hud_mayhem_anims = {
	rise_anim_h = -1,
	bonus_item_grp_anim_h = -1
}

Hud_mayhem_world_cash_status = {
	depth = 0,
	text_intensity = 0,
	color_r = .89,
	color_g = .749,
	color_b = .05,
}
Hud_mayhem_world_cash = {}

Hud_mayhem_bonus_mod_status = {
	current_index = 0,
	cleared_index = 0,
	line_height = 25 * 3,
} 

Hud_mayhem_bonus_mods = {}


Hud_mayhem_world_cash_colors = {
	["WHITE"] 		= { ["r"] = .898,			 ["g"] = .894,				 ["b"] = .874}, 	--White
	["YELLOW"] 		= { ["r"] = 246/255, 	["g"] = 173/255,	 ["b"] = 40/255}, 	--Yellow
	["ORANGE"]		= { ["r"] = 235/255, 	["g"] = 98/255, 	["b"] = 5/255}, 	--Orange
	["RED"]			= { ["r"] = 220/255, 	["g"] = 47/255, 	["b"] = 9/255}, 	--Red
	["BLUE"]			= { ["r"] = .26,	["g"] = .501, 	["b"] = .835}, 
	["MID_BLUE"]	= { ["r"] = .145,	["g"] = .419, 	["b"] = .811}, 
	["DARK_BLUE"]	= { ["r"] = .027,	["g"] = .341, 	["b"] = .788},
}

--object handles...
local Hud_mayhem_combo_total_item_h = 0

-- Local player combo hud data
local HUD_COMBO_OFFESET_X = 100 * 3
local HUD_COMBO_OFFESET_Y = 0

local HUD_PLAYER_INVALID_ID	= 0

local HP_TEXT	= 0
local HP_VALUE	= 1

-- Player combo hud data
-- NOTE: It is not local because this hud has been opened to LUA and these defines are shared.
HPT_NONE				= 0
HPT_POINTS			= 1
HPT_DISTANCE		= 2
HPT_TIME				= 3
HPT_MONEY			= 4
HPT_DEGREES			= 5
HPT_MULTIPLIER		= 6
HPT_MESSAGE_ONLY	= 7
HPT_SECONDS			= 8

HPS_NONE				= 0
HPS_MINUS			= 1
HPS_PLUS				= 2
HPS_MULTIPLIER		= 3

-- Player combo hud skin types
HP_SKIN_DEFAULT 	= 0

-- Player combo hud skin data
local Hud_player_skins = {
	[HP_SKIN_DEFAULT]	= {
		[HP_TEXT]	= { 0.898, 0.894, 0.874 }, -- White
		[HP_VALUE]	= { 0.898, 0.894, 0.874 }, -- White
	},
}

function hud_mayhem_init()
	--Find and store elements
	local h = vint_object_find("mayhem_grp")
	
	--In world cash
	Hud_mayhem_elements.in_game_grp_h = vint_object_find("mayhem_cash_grp")		-- in world cash
	Hud_mayhem_anims.rise_anim_h = vint_object_find("mayhem_rise_anim")			-- in world cash
	Hud_mayhem_combo_total_item_h = vint_object_find("combo_total_item")		--combo totals
	
	-- hide base elements
	vint_set_property(Hud_mayhem_elements.in_game_grp_h, "visible", false)
	vint_set_property(Hud_mayhem_combo_total_item_h, "visible", false)
	
	--Subscribe to data items
	vint_dataitem_add_subscription("local_player_combohud", "update", "hud_mayhem_combo_total_update")
	
	autil_hud_mayhem_init( )
end

function hud_mayhem_world_cash_update(di_h)
	--[[
		VINT_PROP_TYPE_FLOAT          - World position (x)
		VINT_PROP_TYPE_FLOAT          - World position (y)
		VINT_PROP_TYPE_FLOAT          - World position (z)
		VINT_PROP_TYPE_VECTOR2F    	- Screen position
		VINT_PROP_TYPE_INT            - Cash value
		VINT_PROP_TYPE_FLOAT          - Text intensity
		VINT_PROP_TYPE_INT        	- Multiplier value
		VINT_PROP_TYPE_INT			- Type 0 = $$, 1 = Points, 2 = Seconds, 3 = Seconds added, 4 = Custom text
		VINT_PROP_TYPE_ING	  		- Line offset
		VINT_PROP_TYPE_FLOAT		- Text scale
		VINT_PROP_TYPE_STRING		- Custom text string
		
	]]
	local world_x, world_y, world_z, screen_pos_x, screen_pos_y, cash_value, text_intensity, multiplier, display_type, line_offset, scale, custom_text = vint_dataitem_get(di_h)
								
	--debug_print("vint", "hud_mayhem_world_cash_update: di_h " .. di_h .. "\n")
	--debug_print("vint", "hud_mayhem_world_cash_update: cash_value $" .. cash_value .. "\n")

	if display_type == nil then
		display_type = 0
	end

	--Don't do anything else if this is a dummy object.
	if cash_value == 0 then
		--reset text color
		hud_mayhem_text_color_change(text_intensity)
		return
	end

	--If this item has't been created, make a new one and set it up
	if Hud_mayhem_world_cash[di_h] == nil then
		--Reset text color
		hud_mayhem_text_color_change(text_intensity)
		
		--Clone New item
		local grp_h = vint_object_clone(Hud_mayhem_elements.in_game_grp_h)
		local sub_grp_h = vint_object_find("cash_sub_grp", grp_h)
		local cash_txt_h = vint_object_find("cash_txt", grp_h)
		local multiplier_txt_h = vint_object_find("multiplier_txt", grp_h)
		local anim_h = vint_object_clone(Hud_mayhem_anims.rise_anim_h)

		--show gombo cash...
		vint_set_property(grp_h, "visible", true)
		
		--Set the scale
		local base_scale_x, base_scale_y = vint_get_property(grp_h, "scale")
		vint_set_property(grp_h, "scale", base_scale_x * scale, base_scale_y * scale)

		--Rotate and set depth
		vint_set_property(grp_h, "rotation", rand_float(-0.249, 0.249))
		vint_set_property(grp_h, "depth", Hud_mayhem_world_cash_status.depth)
	
		--Hide the group for the first frame since it takes a frame for tweens to play.
		vint_set_property(sub_grp_h, "alpha", 0)
		
		--Retarget Tweens
		vint_set_property(anim_h, "target_handle", grp_h)
		
		--Randomize Tween Direction
		local twn_h = vint_object_find("txt_anchor_twn_1", anim_h)
		vint_set_property(twn_h, "end_value", rand_int(-20 * 3, 20 * 3), rand_int(-0,-30 * 3))
		
		--Callback tween to kill objects and stuff
		local callback_twn_h = vint_object_find("txt_anchor_twn_1", anim_h)
		vint_set_property(callback_twn_h, "end_event", "hud_mayhem_cash_destroy")
						
		--Tint Cash Text
		vint_set_property(cash_txt_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		
		-- +{0}sec   HUD_AMT_SECS
		-- +{0}points   HUD_AMT_POINTS
		
		--HUD_AMT_POINTS
		local insertion_text = { [0] = floor(cash_value) }
		local amt = ""

		if display_type == MAYHEM_DISPLAY_TYPE_CASH then
			--Cash
			amt =  "$" .. cash_value
		elseif display_type == MAYHEM_DISPLAY_TYPE_POINTS then
			--Points
			amt = vint_insert_values_in_string("HUD_AMT_POINTS", insertion_text)
		elseif display_type == MAYHEM_DISPLAY_TYPE_SEC then
			--Seconds
			amt = vint_insert_values_in_string("HUD_AMT_SECS", insertion_text)
		elseif display_type == MAYHEM_DISPLAY_TYPE_SEC_2 then
			--seconds + green
			amt = vint_insert_values_in_string("HUD_AMT_SECS", insertion_text)
			--Force green text
			vint_set_property(cash_txt_h, "tint", 0, 1, 0.25)
		elseif display_type == MAYHEM_DISPLAY_TYPE_CUSTOM then
			amt = custom_text

			--Override default tween end position and rotation
			vint_set_property(twn_h, "end_value", rand_int(-25 * 3, 25 * 3), rand_int(0,10 * 3))
			vint_set_property(grp_h, "rotation", 0)
		end
		
		vint_set_property(cash_txt_h, "text_tag", amt)	
		

		--Format Text with or without multiplier
		if multiplier ~= 0 then
			--Show Multiplier and Align text
			
			--Set MultiplierText Value
			vint_set_property(multiplier_txt_h, "text_tag", "X" .. multiplier)
			
			--Alignment
			local spacing = 5 * 3
			local c_w, c_h = vint_get_property(cash_txt_h, "screen_size")
			local c_x, c_y = vint_get_property(cash_txt_h, "anchor")
			local m_w, m_h = vint_get_property(multiplier_txt_h, "screen_size")
			local m_x, m_y = vint_get_property(multiplier_txt_h, "anchor")
			local half_w = (c_w + m_w + spacing) / 2
			local c_x = 0 - half_w 
			local m_x = c_x + c_w + spacing
			
			--Set Properties
			vint_set_property(cash_txt_h, "anchor", c_x, c_y)
			vint_set_property(multiplier_txt_h, "anchor", m_x, m_y)
		else
			--Hide multiplier and center text
			
			vint_set_property(multiplier_txt_h, "visible", false)
			
			--Alignment
			local c_w, c_h = vint_get_property(cash_txt_h, "screen_size")
			local c_x, c_y = vint_get_property(cash_txt_h, "anchor")
			local c_x = 0 - (c_w / 2)
			
			--Set Properties
			vint_set_property(cash_txt_h, "anchor", c_x, c_y)
		end

		--play tween in animation
		lua_play_anim(anim_h, 0)
		
		--Decrement depth
		Hud_mayhem_world_cash_status.depth = Hud_mayhem_world_cash_status.depth - 1
		
		--Store values and handles to process later
		Hud_mayhem_world_cash[di_h] = {
			di_h = di_h,
			grp_h = grp_h,
			sub_grp_h = sub_grp_h,
			anim_h = anim_h,
			twn_h = callback_twn_h
		}
		
	end

	--Calculate and set the position
	local size_x, size_y = vint_get_property(Hud_mayhem_world_cash[di_h].grp_h, "screen_size")
	screen_pos_y = screen_pos_y + (line_offset * (size_y - (10 * 3)))
	vint_set_property(Hud_mayhem_world_cash[di_h].grp_h, "anchor", screen_pos_x, screen_pos_y)

end

function hud_mayhem_text_color_change(text_intensity)
	--Combo Color update
	--Prepare color morphing based on intensity
	local color1, color2, morph_value
	if text_intensity < 0.5 then
		if MP_enabled == true then
			color1 = Hud_mayhem_world_cash_colors["BLUE"]
			color2 = Hud_mayhem_world_cash_colors["MID_BLUE"]
		else
			color1 = Hud_mayhem_world_cash_colors["YELLOW"]
			color2 = Hud_mayhem_world_cash_colors["ORANGE"]
		end
		morph_value = text_intensity / 0.5
	else
		if text_intensity > 1 then 
			morph_value = (text_intensity -1) -- 1..2
			color1 = Hud_mayhem_world_cash_colors["MID_BLUE"]
			color2 = Hud_mayhem_world_cash_colors["DARK_BLUE"]
		elseif MP_enabled == true then
			color1 = Hud_mayhem_world_cash_colors["MID_BLUE"]
			color2 = Hud_mayhem_world_cash_colors["DARK_BLUE"]
		else
			color1 = Hud_mayhem_world_cash_colors["ORANGE"]
			color2 = Hud_mayhem_world_cash_colors["RED"]
		end
		morph_value = (text_intensity - 0.5) / 0.5
	end
	
	Hud_mayhem_world_cash_status.color_r = color1.r - ((color1.r - color2.r) * morph_value)
	Hud_mayhem_world_cash_status.color_g = color1.g - ((color1.g - color2.g) * morph_value)
	Hud_mayhem_world_cash_status.color_b = color1.b - ((color1.b - color2.b) * morph_value)
	Hud_mayhem_world_cash_status.text_intensity = text_intensity
end

function hud_mayhem_world_cash_remove(di_h)
	--Destroy objects, animation and values
	if Hud_mayhem_world_cash[di_h] ~= nil then
		--Destroy animation
		vint_object_destroy(Hud_mayhem_world_cash[di_h].anim_h)
		--Destroy group object
		vint_object_destroy(Hud_mayhem_world_cash[di_h].grp_h)
		--Destroy stored values
		Hud_mayhem_world_cash[di_h] = nil	
	end
end

--Destroys world cash text
function hud_mayhem_cash_destroy(twn_h, event)
	for idx, val in pairs(Hud_mayhem_world_cash) do
		if val.twn_h == twn_h then
		
			--Destroy animation, text object and Data item
			vint_object_destroy(val.anim_h)
			vint_object_destroy(val.grp_h)
			if val.di_h ~= -1 then
				vint_datagroup_remove_item("mayhem_local_player_world_cash", val.di_h)
			end
			
			--Destroy stored values
			Hud_mayhem_world_cash[idx] = nil	
		end
	end
	
	--reset values if this is the last cash item
	local cash_item_count = 0
	local is_last_item = true
	for idx, val in pairs(Hud_mayhem_world_cash) do
		cash_item_count = cash_item_count + 1
		is_last_item = false
		break
	end
end

local Combo_totals = {}
local Combo_totals_cleanup_data = {}
local Combo_total_last_update_id = -2

function hud_mayhem_combo_total_update(di_h)
	--[[
		VINT_PROP_TYPE_UINT  - Message ID
		VINT_PROP_TYPE_FLOAT - World position (x)
		VINT_PROP_TYPE_FLOAT - World position (y)
		VINT_PROP_TYPE_UINT  - Message crc (can be nil/invalid crc)
		VINT_PROP_TYPE_FLOAT - Message display value (can be nil)
		VINT_PROP_TYPE_FLOAT - Message meter value (can be nil)
		VINT_PROP_TYPE_FLOAT - Text intensity.  -1.0 is off.  Otherwise a 0.0 - 1.0 scale
		VINT_PROP_TYPE_INT   - The message type id
		VINT_PROP_TYPE_INT   - The symbol id
		VINT_PROP_TYPE_INT   - The skin id
		VINT_PROP_TYPE_BOOL  - Play animations
		VINT_PROP_TYPE_BOOL  - Show the meter
		VINT_PROP_TYPE_BOOL  - If the meter is flashing
	]]
	local id, x, y, desc_crc, display_value, meter_value, text_intensity, value_type, value_symbol, skin, do_animation, show_meter, meter_flashing = vint_dataitem_get(di_h)
	
	-- When the data item is first initialized, nil values are passed.  Catch this and exit.
	if id == nil then
		return
	end
	
	if Combo_totals[id] == nil then
		--New ID
		
		--Fade out anim... and set to cleanup...
		local old_combo_total = Combo_totals[Combo_total_last_update_id]
		if old_combo_total ~= nil then
			--Play anim out, the callback will handle the rest of cleanup...
			lua_play_anim(old_combo_total.anim_out_h)
			Combo_total_last_update_id = HUD_PLAYER_INVALID_ID
		end
		
		if id == HUD_PLAYER_INVALID_ID then
			--just needed to destroy the old one
			return
		end
		
		local item_h = vint_object_clone(Hud_mayhem_combo_total_item_h)
		
		vint_set_property(item_h, "visible", true)
		
		--Play animation in, only if we need to...
		local anim_in_h = vint_object_find("combo_total_in_anim")
		
		if do_animation ~= true then
			--smooth fade in...
			anim_in_h = vint_object_find("combo_total_smooth_in_anim")
		end
		
		--Clone animation and target item...
		anim_in_h = vint_object_clone(anim_in_h)
		vint_set_property(anim_in_h, "target_handle", item_h)

		--Clone out animation and target item...
		local anim_out_h = vint_object_find("combo_total_out_anim")
		anim_out_h = vint_object_clone(anim_out_h)
		vint_set_property(anim_out_h, "target_handle", item_h)
		
		--Set callback and data for animation to hide item and clean up the data...
		local twn_h = vint_object_find("combot_total_out_twn", anim_out_h)
		vint_set_property(twn_h, "end_event", "hud_mayhem_combo_total_cleanup")
		Combo_totals_cleanup_data[twn_h] = id
		
		-- Set the skin and colors for the message
		if skin == nil or skin < 0 then
			skin = HP_SKIN_DEFAULT
		end
		
		local title_color = Hud_player_skins[skin][HP_TEXT]
		local val_color = Hud_player_skins[skin][HP_VALUE]
			
		local title_txt_h = vint_object_find("combo_title_txt", item_h)
		local value_txt_h = vint_object_find("combo_value_txt", item_h)
		vint_set_property(title_txt_h, "tint", title_color[1], title_color[2], title_color[3])
		vint_set_property(value_txt_h, "tint", val_color[1], val_color[2], val_color[3])

		--Configure meter if needed
		local meter = Vdo_gsi_meter:new("combo_total_meter", item_h)
		local combo_total_meter_value_h = vint_object_find("combo_total_meter_value", item_h)
		local meter_val_in_anim_h = vint_object_find("combo_total_meter_val_in_anim")
		meter_val_in_anim_h = vint_object_clone(meter_val_in_anim_h)
		
		if show_meter == true then
			--Show combo meter/hide value text...
			meter:set_visible(true)
			vint_set_property(value_txt_h, "visible", false)
			vint_set_property(combo_total_meter_value_h, "visible", true)
			
			--Creates the meter(initializing values..
			meter:create()
			
			--target animation to combo meter value...
			vint_set_property(meter_val_in_anim_h, "target_handle", combo_total_meter_value_h)
			
			-- Set the default color
			vint_set_property(combo_total_meter_value_h, "tint", val_color[1], val_color[2], val_color[3])
		else
			meter:set_visible(false)
			vint_set_property(value_txt_h, "visible", true)
			vint_set_property(combo_total_meter_value_h, "visible", false)
		end
		
		--Fade in...
		lua_play_anim(anim_in_h)

		--Store off for later...
		Combo_totals[id] = {
			item_h = item_h, 
			meter = meter,
			meter_display_value = display_value - 2, -- Why do it this way?  -1 might be a valid value, but this will always work
			text_intensity = -1, -- Default, means no text intensity is used
			anim_in_h = anim_in_h,
			anim_out_h = anim_out_h,
			meter_val_in_anim_h = meter_val_in_anim_h,
		}
	end
	
	--update!
	local combo_total = Combo_totals[id]
	
	vint_set_property(combo_total.item_h, "anchor", x + HUD_COMBO_OFFESET_X, y + HUD_COMBO_OFFESET_Y)
	local title_txt_h = vint_object_find("combo_title_txt", combo_total.item_h)
	local value_txt_h = vint_object_find("combo_value_txt", combo_total.item_h)
	
	--Set title description...
	if desc_crc ~= nil and desc_crc ~= 0 then
		vint_set_property(title_txt_h, "text_tag_crc", desc_crc)
	end
	
	--Set symbol
	local symbol = ""
	if value_symbol == HPS_MINUS then
		symbol = "-"
	elseif value_symbol == HPS_PLUS then
		symbol = "+"
	elseif value_symbol == HPS_MULTIPLIER then
		symbol = "X"
	end
	
	--Handle the display value being nil
	if display_value == nil then
		display_value = 0
	end
	
	--Set amount...
	local insertion_text = { [0] = symbol .. floor(display_value) }
	local amt = ""
	
	if value_type == HPT_NONE then
		-- Standard integer
		amt = symbol .. floor(display_value)
	elseif value_type == HPT_POINTS then
		-- Points
		amt = vint_insert_values_in_string("HUD_AMT_POINTS", insertion_text)
	elseif value_type == HPT_DISTANCE then
		-- Distance
		amt = symbol .. format_distance(display_value)
	elseif value_type == HPT_TIME then
		-- Seconds . Milliseconds
		amt = symbol .. format_time(display_value, true, true)
	elseif value_type == HPT_SECONDS then
		-- Seconds without milliseconds
		amt = symbol .. format_time(display_value, false, true)
	elseif value_type == HPT_MONEY then
		-- Cash
		amt = symbol .. "$" .. format_cash(floor(display_value))
	elseif value_type == HPT_DEGREES then
		-- Degrees
		amt = vint_insert_values_in_string("HUD_AMT_DEGREES", insertion_text)
	elseif value_type == HPT_MULTIPLIER then
		-- Multiplier, A digit formatted as such: 1.5X
		
		-- Make it show one significant digit
		display_value = display_value * 10
		floor(display_value)
		display_value = display_value / 10
		
		amt = symbol .. display_value .. "X"
	elseif value_type == HPT_MESSAGE_ONLY then
		-- No display value at all
		vint_set_property(value_txt_h, "visible", false)
		vint_set_property(combo_total_meter_value_h, "visible", false)
	end
	
	-- Set the value to the correct place depending on if the meter should show.
	if show_meter == true then
		local combo_total_meter_value_h = vint_object_find("combo_total_meter_value", combo_total.item_h)
		local meter = combo_total.meter
		
		-- First we need to set the color based on if a text_intensity exists and has been changed
		if combo_total.text_intensity ~= text_intensity then
			if text_intensity < 0 then
				local val_color = Hud_player_skins[skin][HP_VALUE]
				vint_set_property(combo_total_meter_value_h, "tint", val_color[1], val_color[2], val_color[3])
			else
				hud_mayhem_text_color_change(text_intensity)
				vint_set_property(combo_total_meter_value_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
			end
			
			combo_total.text_intensity = text_intensity
		end
		
		-- Next update the display value if it has changed
		if combo_total.meter_display_value ~= display_value then
			--Set value of bonus label...
			vint_set_property(combo_total_meter_value_h, "text_tag", amt)
			
			--realign text to size of it so it stays centered for animation but left aligned to the title...
			local width, height = element_get_actual_size(combo_total_meter_value_h)
			local x, y = vint_get_property(combo_total_meter_value_h, "anchor")
			x = width/2
			vint_set_property(combo_total_meter_value_h, "anchor", x, y)

			x, y = vint_get_property(meter.handle, "anchor")
			x = width + (8 * 3) -- half the width of our combo value and 5 for padding...
			vint_set_property(meter.handle, "anchor", x, y)
			
			lua_play_anim(combo_total.meter_val_in_anim_h)
			
			combo_total.meter_display_value = display_value
		end
		
		--Make sure the meter range is valid
		if meter_value < 0 then
			meter_value = 0
		elseif meter_value > 1 then
			meter_value = 1
		end

		--Always update the meter...
		meter:update(true, "Mayhem", 0, meter_value, meter_flashing)
		
	-- No meter, just set it to the regular value text tag.
	else
		-- First we need to set the color based on if a text_intensity exists and has been changed
		if combo_total.text_intensity ~= text_intensity then
			if text_intensity < 0 then
				local val_color = Hud_player_skins[skin][HP_VALUE]
				vint_set_property(value_txt_h, "tint", val_color[1], val_color[2], val_color[3])
			else
				hud_mayhem_text_color_change(text_intensity)
				vint_set_property(value_txt_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
			end
			
			combo_total.text_intensity = text_intensity
		end
		
		vint_set_property(value_txt_h, "text_tag", amt)
	end
	
	if x == 0 and y == 0 then
		vint_set_property(combo_total.item_h, "visible", false)
	else
		vint_set_property(combo_total.item_h, "visible", true)
	end
	
	--Store off update id...
	Combo_total_last_update_id = id
end


-------------------------------------------------------------------------------
-- Cleans up the combo total after the out animation has played...
-------------------------------------------------------------------------------
function hud_mayhem_combo_total_cleanup(twn_h)
	local combo_destroy_data = Combo_totals_cleanup_data[twn_h] 
	if combo_destroy_data ~= nil then
	
		local combo_data = Combo_totals[combo_destroy_data]
	
		--Destroy Objects...
		vint_object_destroy(combo_data.item_h)
		vint_object_destroy(combo_data.anim_in_h)
		vint_object_destroy(combo_data.anim_out_h)
		vint_object_destroy(combo_data.meter_val_in_anim_h)
		
		--Destroy Data in cleanup table...
		Combo_totals_cleanup_data[twn_h] = nil
		
		--Destroy data in  combo totals table...
		Combo_totals[combo_destroy_data] = nil
	end
end
nchHud_healthbars_status = {	
	
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