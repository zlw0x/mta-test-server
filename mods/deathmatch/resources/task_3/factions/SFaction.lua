loadstring( exports["interfacer"]:extend( "SDB" ) )()
loadstring( exports["interfacer"]:extend( "ShPlayer" ) )()
loadstring( exports["interfacer"]:extend( "ShFaction" ) )()


FACTION = {}

RANG = { 
    [ 1 ] = "Рядовой",
    [ 2 ] = "Менеджер",
    [ 3 ] = "Лидер" 
}


function createFaction( id, fact_name )
	FACTION[ id ] = {
		name = fact_name,
		leader = nil,
		members = {},
	}
end
createFaction("city_mayor", "Мэрия города")




function setFactionLeader( player_id, faction_id )
	if player_id and faction_id then
		local faction = FACTION[ faction_id ]
		local player = getPlayerByID( player_id )
		for member in pairs( faction.members ) do 
			if member == player then
				faction.members[ player ] = RANG[ 3 ]
				faction.leader = player
				outputChatBox( member:getName().." назначен лидером фракции "..faction.name, source )
				sendFactionDataToClient( player, faction )
			end
		end
	else
		return false
	end
end



function setPlayerFaction( player_id, faction_id )
	local player = getPlayerByID( player_id )
	if faction_id then 
		local faction = FACTION[ faction_id ]
		if faction then
    		faction.members[ player ] = RANG[ 1 ] 
			outputChatBox("Вы вступили во фракцию "..faction.name, player )
			sendFactionDataToClient( player, faction )
		else 
			outputChatBox( "фракции не существует", source )
		end
	else
		kickPlayerFromFaction( player_id )
	end
end



function kickPlayerFromFaction( player_id )
	local player = getPlayerByID( player_id )
	local faction_id = getPlayerFactionID( player )
	local faction = FACTION[ faction_id ]
	if faction then 
		for member, rang in pairs( faction.members ) do -- !
			if member == player then 
				if member == faction.leader then
					faction.leader = nil
				end
				faction.members[ player ] = nil
				outputChatBox( "Вы уволены!", player )
				sendFactionDataToClient( player )
			end
		end
	else 
		outputChatBox( "игрок не состоит во фракции", source )
	end
end
addEvent( "deletePlayerFromFaction", true )
addEventHandler( "deletePlayerFromFaction", resourceRoot, kickPlayerFromFaction( player_id ) )




function sendFactionDataToClient( player, faction ) 		-- отправляем клиенту данные фракции
	triggerClientEvent( player, "refreshFactionData", resourceRoot, faction )
end

addEvent( "getFactData", true )							-- ивент для запроса от клиента
addEventHandler( "getFactData", root, function() 
	local faction_id = client:getFaction()
	if faction_id then
		-- faction = FACTION[ faction_id ]
		sendFactionDataToClient( client, faction_id )
	end 
end )

addEventHandler( "onPlayerJoin", root, function()		-- При входе отправляем клиенту его фрак дату
	local faction_id = client:getFaction()
	if faction_id then
		-- faction = FACTION[ faction_id ]
		sendFactionDataToClient( client, faction_id )
	end 
end )



-- Отправка приглашения

local invite_spam = {}

function sendInvite( player_id )
	outputChatBox("send invite to "..getPlayerName(getPlayerByID( player_id )).." from "..getPlayerName( client ))
	local player = getPlayerByID( player_id )
	local faction_id = getPlayerFactionID( client )
	local faction = FACTION[ faction_id ]
	local player_faction = getPlayerFactionID( player )
	local current_time = getTickCount()
	
    if player_faction ~= faction then                     
        if invite_spam[ player_id ] and current_time - invite_spam[ player_id ] < 60000 then   
            local time_left = string.format( "%d", ( 60000 - ( current_time - invite_spam[ player_id ] ) ) / 1000 )
            outputChatBox( "Этого игрока можно пригласить через "..time_left.." сек.", client )
        else
            invite_spam[ player_id ] = getTickCount()
			triggerClientEvent( player, "createInviteWindow", client, faction.name )
			addEvent( "acceptInvite", true )
			addEventHandler( "acceptInvite", resourceRoot, function()
				outputChatBox("accept "..player_id)
				setPlayerFaction( player_id, faction_id )
			end )
        end
    else
        outputChatBox( "Игрок уже во фракции!",  client ) 
    end
end
addEvent( "invitePlayerToFaction", true )
addEventHandler( "invitePlayerToFaction", resourceRoot, sendInvite )



-- Чат

function factionChat( player, command, ... )
    local name = getPlayerName( player )
    local faction_id = getPlayerFaction( player )
    local faction = FACTION[ faction_id ]
    local message = table.concat( { ... } , " " )
    local members = {}
    for member in pairs( faction.members ) do
        table.insert( members, member )
    end         
    outputChatBox( "("..faction.name..") "..name..": "..message, members )
end
addCommandHandler( "f", factionChat )
 

-- Команды 

addCommandHandler( "set_player_faction", function( player, command, player_id, faction_id )
	local username = getAccountName( getPlayerAccount( player ) )                           
    if isObjectInACLGroup("user."..username, aclGetGroup( "Admin" ) ) then
		setPlayerFaction( player_id, faction_id )
	end
end )

addCommandHandler( "set_player_faction_leader", function( player, command, player_id, faction_id )
	local username = getAccountName( getPlayerAccount( player ) )                           
    if isObjectInACLGroup("user."..username, aclGetGroup( "Admin" ) ) then
		setFactionLeader( player_id, faction_id )
	end
end )

addCommandHandler( "create_new_faction", function( player, command, faction_id, faction_name)  
    local username = getAccountName( getPlayerAccount( player ) )                           
    if isObjectInACLGroup("user."..username, aclGetGroup( "Admin" ) ) then
        createFaction( faction_id, faction_name )
    end
end )
