local SCREEN_W, SCREEN_H = guiGetScreenSize()
local MAX_DISTANCE = 30


function DrawTextOnElement( player, text )
	local x, y, z = getElementPosition( player )
	local x2, y2, z2 = getCameraMatrix()
	local height = 1.1
	local size = 1.5
	if isLineOfSightClear( x, y, z, x2, y2, z2 ) then 		-- если между игроком и камерой ничего нет
		local label_x, label_y = getScreenFromWorldPosition( x, y, z + height ) 	-- позиция id над игроком
		local dist_between = getDistanceBetweenPoints3D( x, y, z, x2, y2, z2 ) 		-- получаем расстояние между игроком и камерой
		if label_x and label_y then 
			if dist_between < MAX_DISTANCE then 
				dxDrawText( text, label_x, label_y, label_x, label_y,
							tocolor( 255, 250, 0, 255 ),
							size - ( dist_between / MAX_DISTANCE ), "default" ) 	-- изменяем размер текста в зависимости от расстояния
			end			
		end
	end
end

addEventHandler( "onClientRender", getRootElement(), function()
	local local_player = getLocalPlayer()
	local x, y, z = getElementPosition( local_player )
    for _, player in pairs( getElementsWithinRange(x, y, z, MAX_DISTANCE, "player" ) ) do 	-- UPD: (6)  получаем игроков в радиусе
        player_id = getElementData( player, "player_id" )
        local_player_id = getElementData( local_player, "player_id" )
        if player ~= local_player then 
		    DrawTextOnElement( player, player_id )
        end
        dxDrawText( "ID: "..local_player_id, 10, SCREEN_H - 30, SCREEN_W, SCREEN_H, 
					tocolor ( 255, 250, 0, 255 ), 1.5, "default" )
	end
end )
