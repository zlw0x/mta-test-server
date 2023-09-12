local owners = {} -- таблица созданных машин и их владельцев

function createCar ( player, commandName, model )
	local vehicleID = getVehicleModelFromName( model ) -- получаем id модели по названию
	local x, y, z = getElementPosition ( player )
	if ( owners[player] ) then
		destroyElement( owners[player]) -- если машина у игрока есть - уничтожаем
	end
	owners[player] = createVehicle ( vehicleID, x+5, y+5, z+1 ) -- создаем машину и записываем в таблицу владельцев
end
addCommandHandler( "veh", createCar)
addEventHandler ( "onPlayerQuit", root, function()  -- при выходе уничтожаем авто
	destroyElement( owners[source] )
end )


-- Дополнительно
function enterVehicle ( player, seat, jacked, door )
	for k, v in pairs(owners) do
    	if ( v == source and k ~= player) then -- если у машины есть владелец и это не игрок
        	cancelEvent()
        	outputChatBox ( "Эту машину создал другой игрок!", player )
    	end
	end
end
addEventHandler ( "onVehicleStartEnter", root, enterVehicle )