local SCREEN_W, SCREEN_H = guiGetScreenSize()

function DrawTextOnElement( player, text )
	local x, y, z = getElementPosition( player )
	local x2, y2, z2 = getCameraMatrix()
	local max_distance = 30
	local height = 1.1
	local size = 1.5
	if isLineOfSightClear( x, y, z, x2, y2, z2 ) then -- если между игроком и камерой ничего нет
		local label_x, label_y = getScreenFromWorldPosition( x, y, z + height ) -- позиция id над игроком
		local dist_between = getDistanceBetweenPoints3D( x, y, z, x2, y2, z2 ) -- получаем расстояние между игроком и камерой
		if label_x and label_y then 
			if dist_between < max_distance then 
				dxDrawText( text, label_x, label_y, label_x, label_y,
							tocolor( 255, 250, 0, 255 ),
							size - ( dist_between / max_distance ), "default" ) -- изменяем размер текста в зависимости от расстояния
			end			
		end
	end
end

addEventHandler( "onClientRender", getRootElement(), function()
    for _, player in pairs( getElementsByType( "player" ) ) do
        player_id = getElementData( player, "player_id" )
        local_player_id = getElementData( getLocalPlayer(), "player_id" )
        if player ~= getLocalPlayer() then 
		    DrawTextOnElement( player, player_id )
        end
        dxDrawText( "ID: "..local_player_id, 10, SCREEN_H - 30, SCREEN_W, SCREEN_H, 
					tocolor ( 255, 250, 0, 255 ), 1.5, "default" )
	end
end )

