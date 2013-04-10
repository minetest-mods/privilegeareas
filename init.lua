privilegeareas = {

	players = {},

	areas = {
		{
			type="radius",
			location = {x=0,y=0,z=0,radius=10},
			sets = {
				privs = {shout},
				grant_on_enter = true;
				take_on_exit = true;
			},

		}
	},

	createPlayerTable = function(player)
		if not player or not player:get_player_name() then
			print("Player does not exist!")
			return;
		end

		local name = player:get_player_name()

		print("writing player table for "..name)
		
		if (name=="") then
			return;
		end
		
		privilegeareas.players[name] = {}
		privilegeareas.players[name].player = player

		if not privilegeareas.players[name].areas then
			privilegeareas.players[name].areas = {}
		end

		privilegeareas.calculate_current_areas(player)
	end,
	
	calculate_current_areas = function(player)
		local name = player:get_player_name()
		print("calculating current areas for "..name)

		if (name=="") then
			return;
		end

		if (not privilegeareas.players[name]) then
			createPlayerTable(player)
		end

		for i=1,# privilegeareas.areas do
			if privilegeareas.areas[i].type == "radius" then
				if distance(player:getpos(),privilegeareas.areas[i].location) < privilegeareas.areas[i].location.radius then
					print ("is in area "..i)
					if  (not privilegeareas.players[name].areas or not privilegeareas.players[name].areas[i] or privilegeareas.players[name].areas[i]==false) then
						print ("running function enter area")
						privilegeareas.enter_area(player,i)
					end
				else
					print ("is not in area "..i)
					if  (privilegeareas.players[name].areas[i]==true) then
						print ("running function leave area")
						privilegeareas.leave_area(player,i)
					end
				end
			end
		end
	end,

	enter_area = function(player,i)
		local name = player:get_player_name()
		privilegeareas.players[name].areas[i]=true
		minetest.chat_send_player(name, "You have entered area "..i)
		for a=1,# privilegeareas.areas[i].sets do
			if privilegeareas.areas[i].sets[a].grant_on_enter == true then
				local privs = minetest.get_player_privs(name)
				minetest.chat_send_player(name, "You have been given: ")

				for b=1,# privilegeareas.areas[i].sets[a].privs do
					privs[privilegeareas.areas[i].sets[a].privs[b]]=true;
					minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].sets[a].privs[b])
				end
				
				minetest.set_player_privs(name, privs)
			end
		end
	end,
	
	leave_area = function(player,i)
		local name = player:get_player_name()
		privilegeareas.players[name].areas[i]=false
		minetest.chat_send_player(name, "You have left area "..i)
		for a=1,# privilegeareas.areas[i].sets do
			if privilegeareas.areas[i].sets[a].grant_on_enter == true then
				local privs = minetest.get_player_privs(name)
				minetest.chat_send_player(name, "You have been given: ")
				
				for b=1,# privilegeareas.areas[i].sets[a].privs do
					privs[privilegeareas.areas[i].sets[a].privs[b]]=true;
					minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].sets[a].privs[b])
				end
				
				minetest.set_player_privs(name, privs)
			end
		end
	end
}

function vector_is_in(hay,needle)
	if (needle.x > hay.x and needle.x < hay.x+hay.w) then
		if (needle.y > hay.y and needle.y < hay.y+hay.h) then
			if (needle.z > hay.z and needle.z < hay.z+hay.d) then
				return true
			end
		end
	end
	return false
end

function distance(v, w)
	return math.sqrt(
		math.pow(v.x - w.x, 2) +
		math.pow(v.y - w.y, 2) +
		math.pow(v.z - w.z, 2)
	)
end

local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 10 then
		timer=0
		print("Updating")

		for i=1,# privilegeareas.players do
			print("player "..i)
			privilegeareas.calculate_current_areas(privilegeareas.players[i].player)
		end

	end
end)

minetest.register_on_joinplayer(function(player)
	privilegeareas.createPlayerTable(player)
end)