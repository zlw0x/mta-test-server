local ALL_ID = {}

for i = 1, getMaxPlayers() do
	table.insert( ALL_ID, i, true ) -- заполняем таблицу доступных id
end

function setPlayerID( player )
	local cur_id = 1 -- начинаем с единицы 
    while ( ALL_ID[ cur_id ] == false ) do -- если занят пробуем следующий
        cur_id = cur_id + 1
    end
    setElementData( player, "player_id", cur_id ) 
    ALL_ID[ cur_id ] = false -- помечаем занятым
end            

addEventHandler( "onResourceStart", root, function()
	for _, player in pairs( getElementsByType( "player" ) ) do
		setPlayerID( player ) -- присваиваем id всем кто на сервере
	end
end )

addEventHandler( "onPlayerJoin", root, function() -- присваиваем id тому кто подключился
    setPlayerID( source )
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function() -- при выходе освобождаем id и очищаем елементдату
    local cur_id = getElementData( source, "player_id" )
    ALL_ID[ cur_id ] = true
    removeElementData( source, "player_id" ) 
end )

