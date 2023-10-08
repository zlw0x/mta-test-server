loadstring( exports["interfacer"]:extend( "SDB" ) )()
loadstring( exports["interfacer"]:extend( "ShPlayer" ) )()


function loginPlayer( email, password )
    local account = getAccount( email )
    if not account then 
        outputChatBox( "email не зарегистрирован." )
    else
        local user = DB:Query( "SELECT * FROM mta.accounts WHERE email=? AND password=?", email, password )
        if user[1] then
            spawn( client, account, password )
        end
        
    end
end
addEvent( "loginPlayer", true )
addEventHandler( "loginPlayer", resourceRoot, loginPlayer )



function registerPlayer( email, password )
    local serial = client:getSerial()
    local acc_count = 0
    local account = getAccount( email )
    if account == false then
        local count_query = DB:Query( "SELECT COUNT( * ) as count FROM mta.accounts WHERE serial=?", serial )
        if count_query then
            count = count_q[ 1 ].count
        end
        if acc_count >= 3 then 
            outputChatBox( "Вы пытаетесь создать более 3 аккаунтов!", client )
        else 
            DB:exec( "INSERT INTO mta.accounts (email, password, serial) VALUES(?,?,?)", email, password, serial )
            addAccount( email, password )
            outputChatBox( "Вы успешно зарегистрированы!", client )
            spawn( client, account, password ) 
        end
    else 
        outputChatBox( "Данный email уже используется", client )
    end
end
addEvent("registerPlayer", true)
addEventHandler("registerPlayer", resourceRoot, registerPlayer)



function spawn( player, account, password )
    player:SetID()
    logIn( player, account, password )
    spawnPlayer( player, 2500, -1660, 15 )
    triggerClientEvent( player, "loginSuccess", source )
    
end



addEventHandler ( "onPlayerJoin", root, function() 
    triggerClientEvent( source, "openLoginGUI", source )
end )
