INVITE_SPAM = {}
FACTION = {}
RANG = { 
    [ 1 ] = "Рядовой",
    [ 2 ] = "Менеджер",
    [ 3 ] = "Лидер" 
}


function createFaction( faction_id, faction_name )                    --UPD: убрал систему команд, фракции - отдельная тблица
    FACTION[ faction_id ] = { 
        name = faction_name, 
        leader = nil,
        members = {}
    }
end

createFaction( "city_mayor", "Мэрия города" )

addCommandHandler( "create_new_faction", function( player, command, faction_id, faction_name)  -- админ может создать новую фракцию
    user_name = getAccountName( getPlayerAccount( player ) )                           -- /create_new_faction [id] [Имя]
    if isObjectInACLGroup("user."..user_name, aclGetGroup( "Admin" ) ) then
        if not FACTION[ faction_id ] then                                                 -- UPD:(3) проверка на сущестование фракции   
            createFaction( faction_id, faction_name )                            
        else
            outputChatBox( "Такая фракция уже существует!", player )
        end
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

function getFactionIDByName( name )
    for faction_id, faction in pairs( FACTION ) do
        if faction.name == name then
            return faction_id
        end
    end 
end

function getFactionName( faction_id )                  -- UPD: функции фракций
    return FACTION[ faction_id ].name
end

function getFactionLeader( faction_id )
    return FACTION[ faction_id ].leader
end

function getFactionMembers( faction_id )
    if FACTION[ faction_id ] then 
        members = {}
        for member, rang in pairs( FACTION[ faction_id ].members ) do 
            table.insert( members, member )
        end
        return members
    end
end

function getPlayerFaction( player )
    faction_id = getElementData( player, "faction" )
    return faction_id
end

function deletePlayerFromFaction( selected_player )
    local selected_faction = FACTION[ getPlayerFaction( selected_player ) ]
    if selected_faction then 
        if selected_faction.leader == selected_player then
            selected_faction.leader = nil 
        end
        for member, rang in pairs( selected_faction.members ) do
            if member == selected_player then 
                member = nil 
                removeElementData( selected_player, "faction" )
                outputChatBox( "Вы уволены!", selected_player )
            end
        end
    end
end


function setPlayerFaction( player_id, faction_id , player )
    local selected_player = getPlayerByID( player_id )
    if faction_id then
        if FACTION[ faction_id ] then                                   
            local selected_faction = FACTION[ faction_id ]
            local faction_name = selected_faction.name 
            selected_faction.members[ selected_player ] = RANG[ 1 ]
            setElementData( selected_player, "faction", faction_id )
            sendFactionData( faction_id, selected_player )
            outputChatBox( "Вы приняты во фракцию "..faction_name, selected_player )
        else 
            outputChatBox( "id фракции не найден", player )
        end
    else
        deletePlayerFromFaction( selected_player )       
    end
end


function setPlayerFactionLeader( player_id, faction_id , player )
    local selected_player = getPlayerByID( player_id )
    local selected_faction = FACTION[ faction_id ]
    local player_faction = FACTION[ getPlayerFaction( selected_player ) ]
    if  player_faction == selected_faction then
        selected_faction.leader = selected_player
        selected_faction.members[ selected_player ] = RANG[ 3 ]
        outputChatBox( "Вы назначены лидером фракции!", selected_player )
    elseif selected_faction == nil then 
        outputChatBox( "Такой фракции не существует!", player )
    else
        outputChatBox( "Этот игрок не состоит во фракции!", player )
    end
end

function sendInvite( player_id, faction_name, sender )
    local player = getPlayerByID( player_id )
    local faction_id = getFactionIDByName( faction_name )
    local faction = FACTION[ faction_id ]
    local current_time = getTickCount()
    if getPlayerTeam( player ) ~= faction then                      -- UPD: (6)  таблицу и проверку последнего инвайта перенес на сервер
        if INVITE_SPAM[ player_id ] and current_time - INVITE_SPAM[ player_id ] < 60000 then    -- если инвайт был менее минуты назад
            local time_left = string.format( "%d", ( 60000 - ( current_time - INVITE_SPAM[ player_id ] ) ) / 1000 )
            outputChatBox( "Этого игрока можно пригласить через "..time_left.." сек.", getPlayerFromName( sender ) )
        else
            INVITE_SPAM[ player_id ] = getTickCount() -- сохраняем время последнего инвайта для данного игрока
            triggerClientEvent( player, "invitePlayerToTeam", resourceRoot, player_id, faction_name, sender )
        end
    else
        outputChatBox( "Игрок уже во фракции!", getPlayerFromName( sender ) ) 
    end

    addEvent( "acceptInvite", true )                    -- UPD: (5) -- перенес ивент внутрь функции, данные от клиента теперь не требуются
    addEventHandler( "acceptInvite", root, function()
        setPlayerFaction( player_id, faction_id )
    end )
end


function sendFactionData( player )
    local fact_data = nil
    local faction_id = getPlayerFaction( player )
    if faction_id then  -- UPD: отправка клиенту информации о фракции
        fact_data = FACTION[ faction_id ]
    end
    triggerClientEvent( player, "setFactionData", resourceRoot, fact_data )
end


addCommandHandler( "set_player_faction_leader", function( player, command, player_id, faction_id ) 
    setPlayerFactionLeader( player_id, faction_id, player)
end )

addCommandHandler( "set_player_faction", function( player, command, player_id, faction_id )
    setPlayerFaction( player_id, faction_id, player )
end )

addCommandHandler( "f", function( player, command, ... ) -- чат
    local faction_id = getPlayerFaction( player )
    if FACTION[ faction_id ] then
        local faction = FACTION[ faction_id ]
        local player_name = getPlayerName( player )
        local members = getFactionMembers( faction_id )
        local message = table.concat( { ... }, " " )
        outputChatBox( "("..faction.name..") "..player_name..": "..message, members, 200, 255, 100 )
        
    end
end )

addEvent( "deletePlayerFromTeam", true )
addEventHandler( "deletePlayerFromTeam", resourceRoot, setPlayerFaction ) -- UPD: (8)  resourceRoot вместо root

addEvent( "inviteToTeam", true )
addEventHandler( "inviteToTeam", resourceRoot, sendInvite ) -- (8)


addEvent( "refreshFactionData", true )
addEventHandler( "refreshFactionData", resourceRoot, sendFactionData )