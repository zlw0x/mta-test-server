ALL_ID = {}

Player.GetID = function( self )
    return self:getData( "player_id" )
end

Player.SetID = function( self )
    local cur_id = 1
    while ALL_ID[ cur_id ] do
        cur_id = cur_id + 1
    end
    self:setData( "player_id", cur_id ) 
    ALL_ID[ cur_id ] = self
end


function getPlayerFactionID( player )
	for faction_id, faction in pairs( FACTION ) do 
		for member in pairs( faction.members ) do 
			if member == player then 
				return faction_id
			end
		end
	end
end

function getPlayerByID( id ) 
    for _, player in pairs( getElementsByType( "player" ) ) do
        local player_id = player:getData( "player_id" )
        if player_id == tonumber( id ) then
            return player
        end
    end 
end


-- Player.getFaction = function( self, player )
--     local email = getAccountName( getPlayerAccount( self ) )
--     DB:query( function( qh ) 
--         local result = qh and qh:poll( -1 )
--         if result then
--             for _, row in ipairs ( result ) do
--                 for column, value in pairs ( row ) do          
--                     outputChatBox( column.." "..value )
--                     return value
--                 end       
--             end
--         else
--             outputDebugString( "getfact query err" )
--         end
--     end, {}, "SELECT faction FROM mta.accounts WHERE email=?", email )
-- end


-- Player.setFaction = function( self, faction )
--     local email = getAccountName( getPlayerAccount( self ) )
--     DB:exec( "UPDATE mta.accounts SET faction=? WHERE email=?", faction, email )
-- end





