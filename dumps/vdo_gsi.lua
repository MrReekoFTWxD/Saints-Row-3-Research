-------------------------------------------------------------------------------
--GSI 
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi = Vdo_base_object:new_base()

-- Standard Init Function
function vdo_gsi_init()
end

-- Standard Cleanup Function
function vdo_gsi_cleanup()
end

-------------------------------------------------------------------------------
--CONSTANTS
-------------------------------------------------------------------------------
--Order of creation is timer, x/y, meter, info
--GSI Indicator Indexes, increment these if there is more than one
local GSI_TIMER 		= 0
local GSI_XY 			= 1
local GSI_METER		= 5
local GSI_INFO 		= 9
local GSI_COMBO 		= 13

--Config Indexes, used to define the arangement of a configuration
local GSI_CONFIG_ROW = 1		--Row Number
local GSI_CONFIG_SKIN = 2		--Skin Type (Indicator Specific)

--Reused enums for special case things...
local GSI_CONFIG_MISSION = 1000
local GSI_CONFIG_RACING1 = 130
local GSI_CONFIG_RACING2 = 131

--local 1 = initializing, 2 = running, 3 = end, 4 = mission change
local GSI_STATE_INITIALIZING			= 1
local GSI_STATE_RUNNING					= 2
local GSI_STATE_END						= 3
local GSI_STATE_MISSION_CHANGE		= 4

HUD_KILL_ICON = 0
HUD_DEFEND_ICON = 1
HUD_USE_ICON = 2
HUD_REVIVE_ICON = 3
HUD_LOCATION_ICON = 4 
HUD_COOP_ICON = 4 

local GSI_OBJECTIVE_ICONS = {
	[HUD_KILL_ICON] = "uhd_ui_hud_gsi_obj_kill",
	[HUD_DEFEND_ICON] = "uhd_ui_hud_gsi_obj_protect",
	[HUD_USE_ICON] = "uhd_ui_hud_gsi_obj_use",
	[HUD_LOCATION_ICON] = "uhd_ui_hud_gsi_obj_goto",
}

GSI_SKIN = {
	["Default"] = 			{ tint = {0.89, 0.749, 0.05}	},		--Default: Yellow			
	["Health"] = 			{ tint = {0.75, 0 , 0} 			},		--Description: Health
	["Damage"] = 			{ tint = {0.89, 0.749, 0.05}	}, 	--Description: Yellow
	["Radioactivity"] =  { tint = {0, 1, 0.25} 			},		--Description: NEON Greeen
	["Media"] =				{ tint = {0, .5, 1 } 			},		--Description: Blue
	["Taunt"] = 			{ tint = {0.89, 0.749, 0.05} 	},		--Description: Yellow
	["Fear"] = 				{ tint = {0.89, 0.749, 0.05}	}, 	--Description: Yellow
	["Pleasure"] = 		{ tint = {1, 0, .5}				}, 	--Description: Pink (Escort)
	["Footage"] = 			{ tint = {0, .5, 1} 				}, 	--Description: Blue (Escort)
	["Mayhem"] =			{ tint = {0.89, 0.749, 0.05}	},		--Description: Mayhem has special properties where it grabs the colors from hud_mayhem.lua
	["TankMayhem"] =		{ tint = {0.89, 0.749, 0.05}	},		--Description: Mayhem has special properties where it grabs the colors from hud_mayhem.lua
	["Fight_Club"] =		{ tint = {0.75, 0 , 0} 			},		--Description: Fight club is basically a red bar but requires special update functionality because the label changes all the time.
	["Nitrous"] =			{ tint = {0, .5, 1 } 			},		--Description: Blue
}

--Enums for activity and other static configurations
local GSI_CONFIGS = {
	--Insurance Fraud
	[0] = { 
		--Row, Column, Indicator Handle, Indicator Type, Skin
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "Cash",						},
		[GSI_METER]			= { 2, "Cash",						},
	},                           
	--Running Man
	[1] = { 
		[GSI_TIMER]			= { 0, "running_man",			},
		[GSI_XY]				= { 1, "Cash",						},
	},
	--Tank Mayhem
	[2] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "Cash",						},
	},
	-- Horde Mode
	[3] = {
		[GSI_INFO]			= { 0, "",							},
		[GSI_INFO + 1]		= { 1, "",							},
		[GSI_INFO + 2]		= { 2, "",							},
		[GSI_INFO + 3]		= { 3, "",							},
		[GSI_TIMER]			= { 4, "negative",				},
	},
	--Fight Club
	[10] = {
		[GSI_XY]				= { 0, "",							},
	},
	--FireTruck
	[20] = {  
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_INFO]			= { 1, "normal",					},
	},
	-- Survival Diversion
	[30] = {
		[GSI_XY]				= { 0, "",							},
		[GSI_XY + 1]		= { 1, "",							},
		[GSI_TIMER]			= { 2, "negative",				},
	},
	--Taxi, Hostage
	[35] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_INFO]			= { 1, "Cash",						},
	},
	--Ambulance
	[40] = { 
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "",							},
	},
	--Tow Truck, Flashing, Streaking, Snatch
	[50] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "normal",					},
	},
	--Heli's alternate
	[51] = {
		[GSI_XY]				= { 0, "normal",					},
	},
	--Heli's Car and XY
	[52] = {
		[GSI_XY]				= { 0, "normal",					},
	},
	--Heli for hire (Standard)
	[53] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "normal",					},
	},
	--Pushback
	[55] = {
		[GSI_XY]				= { 0, "normal",					},
	},
	--Fuzz
	[60] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_METER]			= { 1, "Footage",					},
		[GSI_METER + 1]	= { 1, "Default",					},
	},
	--Trail Blazing
	[70] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "normal",					},
		[GSI_INFO]			= { 2, "TrailBlazing"			},
	},
	--Sewage
	[80] = {
		[GSI_XY]				= { 0, "Cash_Flash_Disabled",	},
		[GSI_METER]			= { 1, "Default",					},
	},
	-- Ho-ing
	[100] = {
		[GSI_METER]			= { 0, "Pleasure",				},
	},
	-- Drug Trafficking, 	
	[110] = {
	--	[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 0, "",							},
	},
	--Demo Derby
	[112] = {
		[GSI_METER]			= { 0, "Nitrous",					},
		[GSI_XY]				= { 1, "Cash",						},
	},
	--Piracy
	[115] = {
		[GSI_TIMER]			= { 0, "negative",				},
	},
	--Crowd Control
	[120] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "Cash",						},
		[GSI_METER]			= { 2, "",							},
	},
	--Racing Solo
	[130] = {
		[GSI_TIMER]			= { 0, "negative",				},
		[GSI_XY]				= { 1, "",							},
	},
	--Racing Competitive
	[131] = {
		[GSI_INFO]			= { 0, "",							},
		[GSI_XY]				= { 1, "",							},
	},
	--Racing Co-op Competitive with AI
	[132] = {
		[GSI_XY]				= { 0, "",							},
	},
	-- Escort
	[140] = {
		[GSI_METER] 		= { 0, "Pleasure",				},
		[GSI_METER + 1]	= { 1, "Footage",					},
	},
	-- Guardian_angel
	[150] = {
		[GSI_INFO]			= { 0, "",							},
		[GSI_METER] 		= { 1, "",							},
	},
	--	Coop Diversions
	[160] = {
		[GSI_INFO]			= { 0, "", 							},
		[GSI_TIMER]			= { 1, "negative", 				},
		[GSI_INFO + 1]		= { 2, "", 							},
	},
	[1000] = {
		--Mission HUD
		--This is just used here as a blank slate...
	},
}

--Audio Constants
GSI_AUDIO_COUNT_POSITIVE = game_audio_get_audio_id("SYS_HUD_CNTDWN_POS")
GSI_AUDIO_TRAIL_BLAZING = game_audio_get_audio_id("SYS_HUD_CNTDWN_POS")
GSI_AUDIO_DIV_COMPLETE = game_audio_get_audio_id("SYS_HUD_CNTDWN_POS")

--Formatting Constants
GSI_TEXT_SPACING = 9

-------------------------------------------------------------------------------
--Initializes GSI
-------------------------------------------------------------------------------
function Vdo_gsi:init()	

	--Setup Core Values for the GSI
	self.status = {
		config_index = -1,
		config = -1,
		indicator_count = 0,
		grid_spacing = 10 * 3,
		state = -1,
		diversion_level = -1,
		is_dirty = false,
		debug_mode = false,
	}

	--Store the vdo copies in memory...
	self.indicators = {}
	
	--What grid the menu is using...
	self.grid = {} 
				
	--References to Animations
	self.anims = {}

	--Store off references to indicators for later mothership cloning...
	self.timer_obj = Vdo_gsi_timer:new("timer", self.handle)
	self.xy_obj = Vdo_gsi_xy:new("xy", self.handle)
	self.meter_obj = Vdo_gsi_meter:new("meter", self.handle)
	self.info_obj = Vdo_gsi_info:new("info", self.handle)
	self.combo_obj = Vdo_gsi_info:new("combo", self.handle)
	self.icon_obj = Vdo_base_object:new("icon", self.handle)
		
	--Hide Mothership indicators
	self.meter_obj:set_visible(false)
	self.info_obj:set_visible(false)
	self.timer_obj:set_visible(false)
	self.xy_obj:set_visible(false)
	self.combo_obj:set_visible(false)
	self.icon_obj:set_visible(false)
	
	self.is_active = false
	self.width, self.height = 0, 0
	
	--Close the GSI
	self:close()
end

-------------------------------------------------------------------------------
-- Updates GSI via Data Item update...
-- **sr2_local_player_gameplay_indicator_status**
--
-- The parameters are varied based on the data_type specified in the first 
-- parameter from the dataitem. 
-------------------------------------------------------------------------------
function Vdo_gsi:update(di_h)
	local data_type, param1, param2, param3, param4, param5, param6, param7, param8, param9 = vint_dataitem_get(di_h)
	
	if self.status.debug_mode == true then
		debug_print("vint", "GSI Update: " .. var_to_string(data_type).. "\n")
	end
	
	--Determine what datatype we are passing through so we can figure out what 
	--to do with the rest of the parameters.	
	if data_type == nil then
		--No specified data_type so don't do anything.
	elseif data_type == "configuration" then
		--Update configuration
		self:update_configuration(param1, param2, param3, param4, param5, param6, param7, param8, param9)	
	else
		--Update Indicators
		self:update_indicators(data_type, param1, param2, param3, param4, param5, param6, param7, param8, param9)	
	end
	
	--TODO: figure out this part of the code...
	
	--Check if the gsi has been re-formatted
	if self.status.is_dirty == true and self.status.state ~= 3 then
		local indicators_created = 0
		for i, val in pairs(self.indicators) do
			indicators_created = indicators_created + 1
		end
		
		--If we have all the data then format it!
		if indicators_created == self.status.indicator_count and self.status.indicator_count ~= 0 then
			if self.status.config_index == GSI_CONFIG_MISSION then
				--Mission config doesn't exist until this is run
				self:reset_config(GSI_CONFIG_MISSION)
			end
			
			--If we are in state 4, it means to do a partial refresh. Otherwise play the opening animation.
			if self.status.state == 4 then
				local width, height = self:update_layout()
			else
				--Open up GSI
				self:open()
			end
			
			self.status.is_dirty = false
		else
			--Exit early since we don't have all the indicators...
			return
		end
	end
	
	--Process the GSI and update it if it or any of its elements are dirty
	local dirty_check = false
	for i, val in pairs(self.indicators) do
		if val.indicator.is_dirty == true then
			dirty_check = true
		end
	end
	
	--Now do the update...
	if dirty_check == true then
		self:update_layout()
	end
end


-------------------------------------------------------------------------------
-- Updates Configuration, data is first processed by Vdo_gsi:update() then
-- sent here for processing.
--
-- @param	gsi_state					1 = initializing, 2 = running, 3 = end, 4 = mission change
-- @param	config						Configuration #
-- @param	icon_bmp_name				Icon Bitmap Name     IGNORED BY THIS SCRIPT!
-- @param	gameplay_title_crc		Title CRC 
-- @param	gameplay_title_string	Title String
-- @param	diversion_level			Diversion Level # string
-- @param	visible						Visible
-- @param	is_diversion				Is it a diversion?
-- @param	indicator_count			Indicator Count, used for missions to 
--												determine how many indicators is needed 
--												before building the ui.
-------------------------------------------------------------------------------
function Vdo_gsi:update_configuration(gsi_state, config, icon_bmp_name, gameplay_title_crc, gameplay_title_string, diversion_level, visible, is_diversion, indicator_count)
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	--Debug Start
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	if self.status.debug_mode == true then	
		debug_print("vint", " gsi state: " .. var_to_string(gsi_state) .. "\n")
		debug_print("vint", " configuration: " .. var_to_string(config) .. "\n")
		debug_print("vint", " icon_bitmap_name: " .. var_to_string(icon_bmp_name) .. "\n")
		debug_print("vint", " gameplay_title crc: " .. var_to_string(gameplay_title_crc) .. "\n")
		debug_print("vint", " gameplay_title string: " .. var_to_string(gameplay_title_string) .. "\n")
		debug_print("vint", " diversion_level: " .. var_to_string(diversion_level) .. "\n")
		debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
		debug_print("vint", " is_diversion: " .. var_to_string(is_diversion) .. "\n")
		debug_print("vint", " indicator_count: " .. var_to_string(indicator_count) .. "\n\n")
	end
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	--Update Diversion Level
	if diversion_level ~= self.status.diversion_level then
		--Diversion Level is no longer used...
	end
	
	if gsi_state ~= self.status.state or gsi_state == GSI_STATE_MISSION_CHANGE then
	
		if gsi_state == GSI_STATE_INITIALIZING or (self.status.is_dirty == true and self.status.state == -1 and gsi_state ~= GSI_STATE_END) or (gsi_state == GSI_STATE_MISSION_CHANGE	 and config == GSI_CONFIG_MISSION and self.status.is_dirty == true ) then
			
			if config ~= GSI_CONFIG_MISSION then
				--Use pre-configuration settings
				
				--Update configuration layout
				local success = self:reset_config(config)
				if success == false then
					return
				end

				--Start out with a fresh number of indicators
				indicator_count = 0	
				
				--Get number of indicators used in configuration
				for idx, val in pairs(self.status.config) do
					indicator_count = indicator_count + 1
				end

			else
				--Use Mission config 
				
				--Clear Indicator and Icon Objects
				for idx, val in pairs(self.indicators) do
					val.indicator:object_destroy()
					val.icon:object_destroy()
				end
				
				--Clear Indicator tables, grid and meter flash data
				self.indicators = {}
				self.grid = {}

				--Use Mission Configuration, then you have to wait until the indicators are setup here.
				self.status.config_index = GSI_CONFIG_MISSION
				self.status.config = GSI_CONFIGS[GSI_CONFIG_MISSION]
				
				if indicator_count > 2 then
					debug_print("", "MISSION GSI ERROR!!! The mission is trying to use more than two indicators at once\n")
				end
			end	
			
			--Set the visual state to dirty so we clean up later
			self.status.is_dirty = true
			
			--Store status data into files
			self.status.indicator_count = indicator_count
	
			--Hide GSI until formatted...
			self:show(false)
			
		elseif gsi_state == GSI_STATE_END then
		
			--Set the flag to unformatted.
			self.status.is_dirty = true
			
			--Reset the diversion level
			self.status.diversion_level = -1
			
			--GSI state should now close
			self:close()

		elseif gsi_state == GSI_STATE_MISSION_CHANGE and config == GSI_CONFIG_MISSION then
			
			--This is used if the hud needs to change configuration midway through a mission
			
			--Set the visual state to dirty so we clean up later
			self.status.is_dirty = true
			
			--Clear Indicator Objects
			for idx, val in pairs(self.indicators) do
				val.indicator:object_destroy()
				val.icon:object_destroy()
			end
			
			--Clear Indicator tables and grid
			self.indicators = {}
			self.grid = {}
			
			--Hide gsi until we can show the indicators...
			self:show(false)
			
			--Use Mission Configuration, you have to wait until the indicators are setup here.
			self.status.config_index = GSI_CONFIG_MISSION
			self.status.config = GSI_CONFIGS[GSI_CONFIG_MISSION]
			
			--Store status data into files
			self.status.indicator_count = indicator_count
			
		end
		self.status.state = gsi_state
	end
end


-------------------------------------------------------------------------------
-- Updates any of the indicators.
--
-- @param 	data_type		Determines what type of indicator we send the other
--									Parameters to. The additional paramters are generic
--									and re-used for all the indicators
--	@param	ind_index		Indicator Index, used to map indicators between game
--									and Interface Lua.
-- @param	visible			Is the indicator Visible?
-- @param	label_crc		Label for the indicator...
-- @param	icon_enum		Icon to use for this widget
-- @param.. param4-9			Generic parameters use for all the other indicators
-------------------------------------------------------------------------------
function Vdo_gsi:update_indicators(data_type, ind_index, visible, label_crc, icon_enum, param5, param6, param7, param8, param9)
	
	--Error checking
	if self.status.config == -1 then
		debug_print("vint", "GSI: No configurations were created, so we do not update shit.\n")
		return
	end

	--Use Mission Configuration, you have to wait until the indicators are setup here.			
	if self.status.config[ind_index] == nil and self.status.config ~= GSI_CONFIGS[GSI_CONFIG_MISSION] then
		debug_print("vint", "GSI: Indicator not supported in current configuration. [element_type = " .. var_to_string(ind_index) .. " ]\n")
		return
	end
	
	--Get skin from the configuration index
	local skin
	if self.status.config ~= GSI_CONFIGS[GSI_CONFIG_MISSION] then
		skin = self.status.config[ind_index][GSI_CONFIG_SKIN]
	else
		skin = ""
	end

	if	data_type == "timer" then
		----------------------------------------------------------------------		
		-- TIMER
		----------------------------------------------------------------------
		if self.status.debug_mode == true then
			debug_print("vint", " timer index: " .. ind_index .. "\n")
			debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
			debug_print("vint", " description crc: " .. var_to_string(label_crc) .. "\n")
			debug_print("vint", " description: " .. var_to_string(param5) .. "\n")
			debug_print("vint", " seconds left: " .. var_to_string(param6) .. " is a positive timer: " .. var_to_string(param7) .. "\n\n")
		end
		
		--Get specific indicator parameters
		local seconds				=	param6	-- Time: seconds left 
		local is_countdown	=	param7		-- Are we counting down or up?
		
		
		
		--Clone the indicator from the mothership
		if self.indicators[ind_index] == nil then
			self.indicators[ind_index] = {}
			self.indicators[ind_index].indicator = Vdo_gsi_timer:clone(self.timer_obj.handle)
			self.indicators[ind_index].indicator:create(skin)
			
			--Also clone and set the icon
			self.indicators[ind_index].icon = Vdo_base_object:clone(self.icon_obj.handle)
		end
		if icon_enum == nil or icon_enum == -1 then
			self.indicators[ind_index].icon:set_visible(false)
		else
			local icon_name = GSI_OBJECTIVE_ICONS[icon_enum]
			self.indicators[ind_index].icon:set_image(icon_name)
			self.indicators[ind_index].icon:set_visible(true)
		end
		
		--Update Indicator
		self.indicators[ind_index].indicator:update(visible, skin, label_crc, seconds, is_countdown)
	elseif data_type == "x_of_y_indicator" then
		----------------------------------------------------------------------		
		-- X of Y
		----------------------------------------------------------------------
		if self.status.debug_mode == true then
			debug_print("vint", " x_of_y_indicator index: " .. ind_index .. "\n")
			debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
			debug_print("vint", " description crc: " .. var_to_string(label_crc) .. "\n")
			debug_print("vint", " description str: " .. var_to_string(param5)  .. "\n")
			debug_print("vint", " current amount: " .. var_to_string(param6) .. " target amount: " .. var_to_string(param7) .. " is it money? " .. var_to_string(param8) .. "\n\n")
		end
						
		--Get specific indicator parameters
		local x_value	=	param6	--Time: seconds left 
		local y_value	=	param7	--Is it a positive timer?
		local is_cash	=	param8	--Is the indicator cash

		--Clone the indicator from the mothership
		if self.indicators[ind_index] == nil then
			self.indicators[ind_index] = {}
			self.indicators[ind_index].indicator = Vdo_gsi_xy:clone(self.xy_obj.handle)
			self.indicators[ind_index].indicator:create(skin)
			
			--Also clone and set the icon
			self.indicators[ind_index].icon = Vdo_base_object:clone(self.icon_obj.handle)
		end
		if icon_enum == nil or icon_enum == -1 then
			self.indicators[ind_index].icon:set_visible(false)
		else
			local icon_name = GSI_OBJECTIVE_ICONS[icon_enum]
			self.indicators[ind_index].icon:set_image(icon_name)
			self.indicators[ind_index].icon:set_visible(true)
		end
		
		--Update Indicator
		self.indicators[ind_index].indicator:update(visible, skin, label_crc, x_value, y_value, is_cash)
	elseif data_type == "meter" then
		----------------------------------------------------------------------		
		--METER
		----------------------------------------------------------------------
		if self.status.debug_mode == true then
			debug_print("vint", " meter index: " .. ind_index .. "\n")
			debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
			debug_print("vint", " description crc:" .. var_to_string(label_crc) .. "\n")
			debug_print("vint", " description: " .. var_to_string(param5) .. "\n")
			debug_print("vint", " current amount: " .. var_to_string(param6) .. "\n\n")
		end
		
		--Get specific indicator parameters
		local meter_percent	=	param6	--Meter Percentage
		local skin = param7					--Skin
		local is_flashing = param8			--Is the meter flashing!? oooohhh
		
		--Override skin if not a mission
		if self.status.config_index ~= GSI_CONFIG_MISSION then
			skin = self.status.config[ind_index][GSI_CONFIG_SKIN]
		end
		
		--Clone the indicator from the mothership
		if self.indicators[ind_index] == nil then
			self.indicators[ind_index] = {}
			self.indicators[ind_index].indicator = Vdo_gsi_meter:clone(self.meter_obj.handle)
			self.indicators[ind_index].indicator:create(skin)
			
			--Also clone and set the icon
			self.indicators[ind_index].icon = Vdo_base_object:clone(self.icon_obj.handle)
		end
		if icon_enum == nil or icon_enum == -1 then
			self.indicators[ind_index].icon:set_visible(false)
		else
			local icon_name = GSI_OBJECTIVE_ICONS[icon_enum]
			self.indicators[ind_index].icon:set_image(icon_name)
			self.indicators[ind_index].icon:set_visible(true)
		end
		
		--Update Indicator
		self.indicators[ind_index].indicator:update(visible, skin, label_crc, meter_percent, is_flashing)
		
	--INFORMATION INDICATOR
	elseif data_type == "information_indicator" then
		----------------------------------------------------------------------		
		--INFORMATION INDICATOR
		----------------------------------------------------------------------
		if self.status.debug_mode == true then
			debug_print("vint", " information_indicator index: " 	.. ind_index .. "\n")
			debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
			debug_print("vint", " description crc: " .. var_to_string(label_crc) .. "\n")
			debug_print("vint", " description: " .. var_to_string(param5) .. "\n")
			debug_print("vint", " information crc: " .. param6 .. "\n")
			debug_print("vint", " information: " .. var_to_string(param7) .. "\n\n")
		end

		local info_crc = param6
		local info_value = param7
		
		--Check if indicator has been created
		if self.indicators[ind_index] == nil then
			--Clone the indicator from the mothership
			self.indicators[ind_index] = {}
			self.indicators[ind_index].indicator = Vdo_gsi_info:clone(self.info_obj.handle)
			self.indicators[ind_index].indicator:create(skin)
			
			--Also clone and set the icon
			self.indicators[ind_index].icon = Vdo_base_object:clone(self.icon_obj.handle)
		end
		if icon_enum == nil or icon_enum == -1 then
			self.indicators[ind_index].icon:set_visible(false)
		else
			local icon_name = GSI_OBJECTIVE_ICONS[icon_enum]
			self.indicators[ind_index].icon:set_image(icon_name)
			self.indicators[ind_index].icon:set_visible(true)
		end
		
		--Update Indicator
		self.indicators[ind_index].indicator:update(visible, skin, label_crc, info_crc, info_value)
	elseif data_type == "combo" then
		----------------------------------------------------------------------		
		--METER
		----------------------------------------------------------------------
		if self.status.debug_mode == true then
			debug_print("vint", " combo index: " .. ind_index .. "\n")
			debug_print("vint", " visible: " .. var_to_string(visible) .. "\n")
			debug_print("vint", " description crc: " .. var_to_string(label_crc) .. "\n")
			debug_print("vint", " description str: " .. var_to_string(param5)  .. "\n")
			debug_print("vint", " combo_value: " .. var_to_string(param6) .. "\n")
			debug_print("vint", " Meter_pct: " .. var_to_string(param7) .. "\n\n")
			debug_print("vint", " is_flashing: " .. var_to_string(param8) .. "\n\n")
		end
		
		--Get specific indicator parameters
		local combo_value	=	param6		--Combo Value
		local meter_percent	=	param7	--Meter Percentage
		local is_flashing = param8			--Is the meter flashing!? oooohhh
		
		--Override skin if not a mission
		if self.status.config_index ~= GSI_CONFIG_MISSION then
			skin = self.status.config[ind_index][GSI_CONFIG_SKIN]
		end
		
		--Clone the indicator from the mothership
		if self.indicators[ind_index] == nil then
			self.indicators[ind_index] = {}
			self.indicators[ind_index].indicator = Vdo_gsi_combo:clone(self.combo_obj.handle)
			self.indicators[ind_index].indicator:create(skin)
			
			--Also clone and set the icon
			self.indicators[ind_index].icon = Vdo_base_object:clone(self.icon_obj.handle)
		end
		if icon_enum == nil or icon_enum == -1 then
			self.indicators[ind_index].icon:set_visible(false)
		else
			local icon_name = GSI_OBJECTIVE_ICONS[icon_enum]
			self.indicators[ind_index].icon:set_image(icon_name)
			self.indicators[ind_index].icon:set_visible(true)
		end
		
		--Update Indicator
		self.indicators[ind_index].indicator:update(visible, skin, label_crc, combo_value, meter_percent, is_flashing)
	end	
end


-------------------------------------------------------------------------------
--	Resets clears our the old configuration and elements. Then sets up the 
-- new configuration to be populated.
--
-- @param	config_index	index of GSI Configuration
-------------------------------------------------------------------------------
function Vdo_gsi:reset_config(config_index)

	local config = GSI_CONFIGS[config_index]

	if config == nil then
		debug_print("vint", "Failed to update config. Config index doesn't exist\n")
		return false
	end
	
	if config_index ~= GSI_CONFIG_MISSION then
		--Standard Configuration	
		
		--Clear Indicator Objects
		for idx, val in pairs(self.indicators) do
			val.indicator:object_destroy()
			val.icon:object_destroy()
		end
		
		--Clear indicator tables and grid
		self.indicators = {}
		self.grid = {}
		
		--Build the new config
		for idx, val in pairs(config) do
			local row = val[GSI_CONFIG_ROW]
			local indicator_index = idx
			
			--Add item to grid
			self:grid_item_add(row, indicator_index)
		end
	else
		--TODO: Mission Configuration
		
		--Oh shit this is all fucking crazy
		local indicator_mess = {}		--Indicator mess will be a table full of indicator indexes and indicator priorities
		local indicator_counter = 0
		local indicator_priority = 1
		

		--Prioritie defines ( 1 is highest priority and displays first...)
		local priority_info 	= 1
		local priority_xy 	= 2
		local priority_meter = 3
		local priority_combo = 3
		local priority_timer = 4
		
		--OK RIGHT HERE.... 
		
		--Store priorities of items into a table... This has to be lined up in order...
		for idx, val in pairs(self.indicators) do
			--Calculate priority
			if idx == GSI_TIMER then
				indicator_priority = priority_timer
			elseif idx < GSI_METER then
				--X of Y...
				indicator_priority = priority_xy
			elseif idx < GSI_INFO then
				--Meter...
				indicator_priority = priority_meter
			elseif idx < GSI_COMBO then
				--info
				indicator_priority = priority_info
			else
				--Combo
				indicator_priority = priority_combo
			end

			indicator_mess[indicator_counter] = {["index"] = idx,	["priority"] = indicator_priority} 
			indicator_counter = indicator_counter + 1
		end

		--Assign priorities to the items
		local temp_indicator_storage
		local flag = false
		while flag == false do
		
			flag = true
			
			for i = 0, self.status.indicator_count - 2 do
				if indicator_mess[i].priority > indicator_mess[i + 1].priority then
					--swap indexes if the priority is greater
					temp_indicator_storage = table_clone(indicator_mess[i])
					indicator_mess[i] = table_clone(indicator_mess[i + 1])
					indicator_mess[i + 1] = temp_indicator_storage  
					flag = false
					break
				end
			end
		end
		
		--Add Grid Items
		if indicator_counter ~= 0 then
			--First Indicator
			for i = 0, indicator_counter - 1 do
				if i >= 2 then
					--no more than two indicators allowd
					break
				end
				if indicator_mess[i].index ~= nil then
					self:grid_item_add(i, indicator_mess[i].index)
				end
			end
		end
	end
	self.status.config_index = config_index
	self.status.config = config
end

function Vdo_gsi:grid_item_add(row, idx)
	if self.grid[row] == nil then
		self.grid[row] = idx
	end
end

-------------------------------------------------------------------------------
-- Opens the GSI, causes the thing to creativly animate in...set_visible. true.
-------------------------------------------------------------------------------
function Vdo_gsi:open()
	debug_print("vint", "hud_gsi_open()\n")
	self:set_visible(true)
end

-------------------------------------------------------------------------------
-- Closes the GSI, rips the heart out bitches. My name is Kano.
-------------------------------------------------------------------------------
function Vdo_gsi:close()
	self.status.is_dirty = true
	self:set_visible(false)
	self.is_active = false
end

-------------------------------------------------------------------------------
-- Show/Hide GSI
-------------------------------------------------------------------------------
function Vdo_gsi:show(visible)
	self:set_visible(visible)
	self.is_active = true
end

-------------------------------------------------------------------------------
-- Updates the layout of the GSI, Puts the indicators on their assigned lines.
-- Updates background...
-------------------------------------------------------------------------------
function Vdo_gsi:update_layout()
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		--Debug Start
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	if self.status.debug_mode == true then
		debug_print("vint", "Updating Layout. Vdo_gsi:update_layout()\n")
	end
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	--Calculate size of box
	local width = 0
	local height = 20 * 3
	local width_padding = 12 * 3
	local scrim_spacing = 4 * 3			--spacing between timer and indicator boxes...
	local skip_indicator_count = 0
	local indicator_x_offset = 8.0 * 3		--Offset from left side of scrim...
	local indicator_y_offset = 18 * 3			--Offset from top side of scrim...
	local indicator_padding_y = 18 * 3
	local indicator_height = 23	* 3		--Height of indicators..
	local indent = 0
	local timer_width = 0
	local timer_height = 0
	local timer_h = -1
	local indicator_count = 0
	local indicator_meter_count = 0 
	local indicator_meters = {}

	for row = 0, 10 do
		--Check to see if we have an item in that position in the grid...
		if self.grid[row] == nil then
			break
		end
	
		local indicator_index = self.grid[row]
		local indicator_table = self.indicators[indicator_index]
		
		if indicator_table == nil then
			return 0, 0
		end
		
		local indicator_obj = indicator_table.indicator
		local icon_obj = indicator_table.icon
		
		--Since items can be hidden we need to be able to skip stuff for layouts
		if indicator_obj.visible == false then
			--Skipping this indicator because it is not visible or is a timer...
			skip_indicator_count = skip_indicator_count + 1
		elseif indicator_index == GSI_TIMER then 
			--Skipping this indicator because it is a timer... but we need to set its visibility to true...
			indicator_obj:set_visible(true)
			timer_width, timer_height = indicator_obj:get_size()
			timer_h = indicator_obj.handle		--Store handle to timer for layout...
			skip_indicator_count = skip_indicator_count + 1
		else 
			--Do processing for layout
			local y = (row - skip_indicator_count) * indicator_height + indicator_y_offset
			
			if icon_obj:get_visible() then
				--indent indicator if icon is visible
				indent = 30 * 3
			end
			
			icon_obj:set_anchor(indicator_x_offset, y -1)
			
			--Offset indicator by half of the indent amount... (because the icon is centered)
			indicator_obj:set_anchor(indicator_x_offset + indent, y)
			
			--Get width for scrim
			local width_test, height_test = indicator_obj:get_size()
			width = max(width_test, width)
			
			--check to see if it is a meter if there is more than two of these we will align their parts...
			if indicator_index >= GSI_METER and indicator_index < GSI_INFO then
				--Increment meter count..
				indicator_meter_count = indicator_meter_count + 1
				
				-- Add meter to our indicator meter object...
				indicator_meters[indicator_meter_count] = indicator_obj
			end
			
			
			--Calculate height for scrim
			height = y
			indicator_count = indicator_count + 1
		end
	end
	
	--Align meters...
	if indicator_meter_count > 1 then
		local max_meter_text_width = 0
		local meter_text_width = 0 
		for i = 1, indicator_meter_count do
			meter_text_width = indicator_meters[i]:get_label_width()
			max_meter_text_width = max(max_meter_text_width, meter_text_width)
		end
		for i = 1, indicator_meter_count do 
			indicator_meters[i]:set_meter_position(max_meter_text_width)
		end
	end
	
	--Position indicator groups...
	local indicators_h = vint_object_find("indicators", self.handle)
	local x, y = vint_get_property(indicators_h, "anchor")
	if timer_width == 0 then
		--No indicator so align box all the way to left...
		x = 0
	else
		--Align box next to timer..
		x = timer_width + scrim_spacing
	end

	vint_set_property(indicators_h, "anchor", x, y)
	
	--Set Size of right scrim
	local scrim_width = timer_width 
	local scrim_height = timer_height
	local timer_bg_width 	= timer_width
	local timer_bg_height 	= height + indicator_padding_y
	
	-- Right background...
	local scrim_h = vint_object_find("bg_indicators", self.handle)
	if indicator_count > 0 then
		element_set_actual_size(scrim_h, width + indent + width_padding,timer_bg_height)
		vint_set_property(scrim_h, "anchor", x, y)		--Move scrim to match indicator background.
		vint_set_property(scrim_h, "visible", true)
	else
		vint_set_property(scrim_h, "visible", false)
	end
	
	-- Timer background...
	local scrim_h = vint_object_find("bg_timer", self.handle)
	element_set_actual_size(scrim_h, timer_bg_width, timer_bg_height)

	-- Position timer so it is inline with the scrim...
	local vertical_center = timer_bg_height/2
	vint_set_property(timer_h, "anchor", 0, vertical_center)

	-- Objects themselves are no longer dirty...
	for i, val in pairs(self.indicators) do
		val.indicator.is_dirty = false
	end
	
	-- Unhide GSI...
	self:show(true)
	
	-- Frame is now not diry...
	self.is_dirty = false
	self.width, self.height = width, timer_bg_height
	return width, height
end

function Vdo_gsi:is_active_set(is_active)
	self.is_active = is_active
end


function Vdo_gsi:is_active_get()
	return self.is_active
end

function Vdo_gsi:get_size()
	return self.width, self.height
end

--[[
#########################################################################
TEST FUNCTIONS
#########################################################################
]]

--Used to show the bounding box of an object. (NOTE: Does not work for offsets that are not 0,0)
Bounds_util_data = {}
function element_bounds_debug(element_handle)
	local h
	if Bounds_util_data[element_handle] == nil then
		h = vint_object_create("bounds_util", "bitmap", element_handle)
		vint_set_property(h, "image", "ui_blank")
		vint_set_property(h, "tint", rand_float(.3,1),rand_float(.3,1),rand_float(.3,1))
		vint_set_property(h, "alpha", .5)
		vint_set_property(h, "depth", -5000)
		Bounds_util_data[element_handle] = h
	else
		h = Bounds_util_data[element_handle]
	end
	vint_set_property(h, "anchor", 0,0)
	local element_width, element_height = element_get_actual_size(element_handle)
	element_set_actual_size(h, element_width, element_height)
end

function element_bounds_debug_clear()
	for key, val in pairs(Bounds_util_data) do
		vint_object_destroy(val)
	end
end
