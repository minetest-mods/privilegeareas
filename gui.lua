gui = {}

-- Chat command for opening gui
minetest.register_chatcommand("privareas", {
	params = "",
	description = "PrivAreas: access a formspec from the privilegeareas mod",
	privs = {
		privs = true,
	},
	func = function(name, param)
		add_gui(name)
	end,
})

-- The add gui
function add_gui(name)
	print("Showing add area form to "..name)

	gui[name]={
		type="box"
	}

	minetest.show_formspec(name, "privilegeareas:gui_add", "size[6,5]"..
		"button[2,0;2,1;type;box]"..
		"field[2,2;1,1;x;X;0]"..
		"field[3,2;1,1;y;Y;0]"..
		"field[4,2;1,1;z;Z;0]"..
		"field[2,3;1,1;x2;X;0]"..
		"field[3,3;1,1;y2;Y;0]"..
		"field[4,3;1,1;z2;Z;0]"..
		"button_exit[2,4;2,1;submit;Add]")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if (formname~="privilegeareas:gui_add") then
		return false
	end
		
	if not minetest.check_player_privs(player, "privs") then
		return false
	end

	if fields.submit then
		-- Do addition stuff
		print("submitting")

                if gui[name].type == "box" then
			table.insert(privilegeareas.areas,{
				type = gui[name].type,
				location = {
					x=math.floor(fields.x),
					y=math.floor(fields.y),
					z=math.floor(fields.z),
				},
				location2 = {
					x=math.floor(fields.x2),
					y=math.floor(fields.y2),
					z=math.floor(fields.z2),
				},
				actions = {
					on_enter = {
					},
					on_leave = {
					}
				}
			})
		else
			table.insert(privilegeareas.areas,{
				type = gui[name].type,
				location = {
					x=math.floor(fields.x),
					y=math.floor(fields.y),
					z=math.floor(fields.z),
					radius=math.floor(fields.rad)
				},
				actions = {
					on_enter = {
						grant = {},
						take = {}

					},
					on_leave = {
						grant = {},
						take = {}
					}
				}
			})
		end
		
		gui[name]=nil

		act_gui(name,#privilegeareas.areas)
		
		return
	end

	if fields.type then
		-- Do toggle stuff
		print("toggling")
		if gui[name].type == "box" then
			gui[name].type = "radius"
			minetest.show_formspec(name, "privilegeareas:gui_add", "size[6,5]"..
				"button[2,0;2,1;type;"..gui[name].type.."]"..
				"field[2,2;1,1;x;X;"..fields.x.."]"..
				"field[3,2;1,1;y;Y;"..fields.y.."]"..
				"field[4,2;1,1;z;Z;"..fields.z.."]"..
				"field[2,3;1,1;rad;R;0]"..
				"button_exit[2,4;2,1;submit;Add]")
		else
			gui[name].type = "box"
			minetest.show_formspec(name, "privilegeareas:gui_add", "size[6,5]"..
				"button[2,0;2,1;type;"..gui[name].type.."]"..
				"field[2,2;1,1;x;X;"..fields.x.."]"..
				"field[3,2;1,1;y;Y;"..fields.y.."]"..
				"field[4,2;1,1;z;Z;"..fields.z.."]"..
				"field[2,3;1,1;x2;X;0]"..
				"field[3,3;1,1;y2;Y;0]"..
				"field[4,3;1,1;z2;Z;0]"..
				"button_exit[2,4;2,1;submit;Add]")
		end
	end
end)

function act_gui(name,id)
	print("Showing add action form for area "..id)
	
	print(dump(privilegeareas.areas[id]))

	if not gui[name] or not gui[name].trigger or not gui[name].type or not gui[name].value then
		gui[name]={
			trigger = "on_enter",
			type = "grant",
			value = "",
		}
	end

	gui[name].id = id

	minetest.show_formspec(name, "privilegeareas:gui_act", "size[7,4]"..
		"field[2,1;4,1;name;Data;"..gui[name].value.."]"..
		"button[1,2;2,1;trigger;"..gui[name].trigger.."]"..
		"button[4,2;2,1;type;"..gui[name].type.."]"..
		"button[1,3;2,1;submit;Add]"..
		"button_exit[4,3;2,1;close;Close]")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if (formname~="privilegeareas:gui_act") then
		return false
	end

	local name = player:get_player_name()
	gui[name].value = fields.name
	
	if fields.close then
		return
	end

	if fields.submit then
		-- Do addition stuff
		print("submitting")

		if (gui[name].id and gui[name].trigger and fields.name) then
			-- this will doubtlessly be buggy
			local id = gui[name].id
			local trigger = gui[name].trigger
			local action_type = gui[name].type
			local trigger_action_types = privilegeareas.areas[id].actions[trigger]
			if not trigger_action_types[action_type] then
				trigger_action_types[action_type] = {}
			end
			table.insert(trigger_action_types[action_type],fields.name)

			-- Alert user of success
			minetest.chat_send_player(name, "Added data '"..fields.name.."' to '"..gui[name].type.."' in trigger "..gui[name].trigger.." in area "..gui[name].id)
			
			-- Delete field
			gui[name] = nil

			-- Update
			act_gui(name,id)
			
			return
		end
	end

	if fields.type then
		-- Do toggle stuff
		print("toggling type")
		if gui[player:get_player_name()].type == "grant" then
			gui[player:get_player_name()].type = "take"
		else
			gui[player:get_player_name()].type = "grant"
		end
	end
	
	if fields.trigger then
		-- Do toggle stuff
		print("toggling trigger")
		if gui[player:get_player_name()].trigger == "on_enter" then
			gui[player:get_player_name()].trigger = "on_leave"
		else
			gui[player:get_player_name()].trigger = "on_enter"
		end
	end

	act_gui(name,gui[name].id)
end)
