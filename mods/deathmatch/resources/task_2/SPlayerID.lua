local ALL_ID = {}


function setPlayerID( player )    -- выдача ид c помощью ipairs
    cur_id = 1                              
    for k, v in ipairs( ALL_ID ) do    
        cur_id = cur_id + 1
    end
    setElementData( player, "player_id", cur_id ) 
    ALL_ID[ cur_id ] = player
end            

addEventHandler( "onResourceStart", root, function()     -- присваиваем id всем кто на сервере
	for _, player in pairs( getElementsByType( "player" ) ) do
		setPlayerID( player )           
	end
end )

addEventHandler( "onPlayerJoin", root, function()      -- присваиваем id тому кто подключился
    setPlayerID( source )
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function()     -- при выходе освобождаем id и очищаем елементдату
    local cur_id = getElementData( source, "player_id" )
    ALL_ID[ cur_id ] = nil
    removeElementData( source, "player_id" ) 
end )
