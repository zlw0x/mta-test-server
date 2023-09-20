local FACTION = {}
FACTION[ "city_mayor" ] = createTeam( "Мэрия Города" )

addCommandHandler( "create_new_faction", function( player, command, team_id, team_name)  -- админ может создать новую фракцию
    user_name = getAccountName( getPlayerAccount( player ) )                           -- /create_new_faction [id] [Имя]
    if isObjectInACLGroup("user."..user_name, aclGetGroup( "Admin" ) ) then
        FACTION[ team_id ] = createTeam( team_name )
    end
end )


function getPlayerByID( id ) 
    for _, player in pairs( getElementsByType( "player" ) ) do
        local player_id = getElementData( player, "player_id" )
        if player_id == tonumber( id ) then
            return player
        end
    end 
end

function getTeamIDByName( name )
    for team_id, team in pairs( FACTION ) do
        local team_name = getTeamName( team )
        if team_name == name then
            return team_id
        end
    end 
end

function setPlayerFaction( player_id, team_id , player )
    local selected_player = getPlayerByID( player_id )
    if team_id then
        if FACTION[ team_id ] then                                   
            local selected_team = FACTION[ team_id ]
            local team_name = getTeamName( selected_team )
            setPlayerTeam( selected_player, selected_team )
            outputChatBox( "Вы приняты во фракцию "..team_name, selected_player )
        else 
            outputChatBox( "id фракции не найден", player )
        end
    else                                                                        -- если id фракции не указан удаляем
        local selected_team = getPlayerTeam( selected_player )
        if selected_team then 
            if getElementData( selected_team, "leader" ) == selected_player then
                setElementData( selected_team, "leader", nil )
            end
            setPlayerTeam( selected_player, nil )
            outputChatBox( "Вы уволены!", selected_player )
        end
    end
end

function setPlayerFactionLeader( player_id, team_id , player )
    local selected_player = getPlayerByID( player_id )
    local selected_team = FACTION[ team_id ]
    if getPlayerTeam( selected_player ) == selected_team then
        setElementData( selected_team, "leader", selected_player )
        outputChatBox( "Вы назначены лидером фракции!", selected_player )
    else
        outputChatBox( "Этот игрок не состоит во фракции!", player )
    end
end

function sendInvite( player_id, team_name, sender )
    local player = getPlayerByID( player_id )
    local team = getTeamFromName( team_name )
    if getPlayerTeam( player ) ~= team then
        triggerClientEvent( player, "invitePlayerToTeam", resourceRoot, player_id, team_name, sender )
    else
        outputChatBox( "Игрок уже во фракции!", getPlayerFromName( sender ) )
    end
end

addCommandHandler( "set_player_faction_leader", function( player, command, player_id, team_id ) 
    setPlayerFactionLeader( player_id, team_id)
end )

addCommandHandler( "set_player_faction", function( player, command, player_id, team_id )
    setPlayerFaction( player_id, team_id )
end )

addCommandHandler( "f", function( player, command, ... ) -- чат
    local team = getPlayerTeam( player )
    if team then
        local name = getPlayerName( player )
        local team_name = getTeamName( team )
        local message = table.concat( { ... }, " " )
        outputChatBox( "("..team_name..") "..name..": "..message, getPlayersInTeam( team ), 200, 255, 100 )
    end
end )

addEvent( "deletePlayerFromTeam", true )
addEventHandler( "deletePlayerFromTeam", root, setPlayerFaction )

addEvent( "inviteToTeam", true )
addEventHandler( "inviteToTeam", root, sendInvite )


addEvent( "acceptInvite", true )
addEventHandler( "acceptInvite", root, function( player_id, team_name )
    local team_id = getTeamIDByName( team_name )
    setPlayerFaction( player_id, team_id )
end )
