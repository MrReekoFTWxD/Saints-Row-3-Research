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
