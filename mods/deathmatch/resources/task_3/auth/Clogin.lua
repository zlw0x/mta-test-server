

function centerWindow( window )
    local scr_w, scr_h = guiGetScreenSize()
    local win_w, win_h = guiGetSize(window, false)
    local x, y = (scr_w - win_w) /2,(scr_h - win_h) /2
    return guiSetPosition(window, x, y, false)
end



login_window = guiCreateWindow( 0, 0, 0.3, 0.4, "Добро пожаловать!", true )
centerWindow( login_window )
tab_panel = guiCreateTabPanel( 0, 0.1, 1, 1, true, login_window )

-- login tab          
login_tab = guiCreateTab( "Авторизация", tab_panel )
log_email_label = guiCreateLabel(0.1, 0.2, 0.5, 0.1, "E-mail", true, login_tab )
log_email = guiCreateEdit(0.35, 0.2, 0.6, 0.1, "", true, login_tab)
log_password_label = guiCreateLabel(0.1, 0.4, 0.5, 0.1, "Пароль", true, login_tab )
log_password = guiCreateEdit(0.35, 0.4, 0.6, 0.1, "", true, login_tab)
guiEditSetMasked( log_password, true )
login_button = guiCreateButton(0.25, 0.65, 0.5, 0.15, "Войти", true, login_tab)

-- reg tab
register_tab = guiCreateTab( "Регистрация", tab_panel )
reg_email_label = guiCreateLabel(0.1, 0.1, 0.5, 0.1, "E-mail:", true, register_tab )
reg_email = guiCreateEdit(0.35, 0.1, 0.6, 0.1, "", true, register_tab)
reg_password_label = guiCreateLabel(0.1, 0.3, 0.5, 0.1, "Пароль:", true, register_tab )
reg_password = guiCreateEdit(0.35, 0.3, 0.6, 0.1, "", true, register_tab)
guiEditSetMasked( reg_password, true )
reg_pass_repeat_label = guiCreateLabel(0.1, 0.48, 0.5, 0.2, "Повторите \nпароль:", true, register_tab )
reg_pass_repeat = guiCreateEdit(0.35, 0.5, 0.6, 0.1, "", true, register_tab)
guiEditSetMasked( reg_pass_repeat, true )
register_button = guiCreateButton(0.2, 0.75, 0.6, 0.15, "Зарегистрироваться", true, register_tab) 

guiSetVisible( login_window, false )


function openLoginWindow()
    guiSetVisible(login_window, true)
    showCursor(true)
    fadeCamera(false)
    guiSetInputEnabled(false)
end
addEvent("openLoginGUI", true)
addEventHandler("openLoginGUI", getRootElement(), openLoginWindow)


function login()
    if (source == login_button) then
        if guiGetText(log_password) and guiGetText(log_email) then
            triggerServerEvent("loginPlayer", root, guiGetText(log_email), guiGetText(log_password))
        else
            outputChatBox("Введите e-mail и пароль!")
        end
    end
end
addEventHandler("onClientGUIClick", resourceRoot, login)


function successfullLogin()
    fadeCamera(true, 1, 255, 0, 0)
    fadeCamera(false)
    guiSetVisible(login_window, false)
    showCursor(false)
    outputChatBox( "Добро пожаловать!" )
end
addEvent("loginSuccess", true)
addEventHandler("loginSuccess", resourceRoot, successfullLogin)



function register()
    local mail =guiGetText( reg_email ) 
    local password = guiGetText( reg_password )
    local pass_repeat = guiGetText( reg_pass_repeat )
    if source == register_button then
        if email and pass then
            if email:match( "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?" ) then 
                if password == pass_repeat then
                    triggerServerEvent( "registerPlayer", root, guiGetText( reg_email ), guiGetText( reg_password ) )
                else
                    outputChatBox( "Ошибка! Проверьте пароль." )
                end
            else 
                outputChatBox("Некорректный email")
            end
        else 
            outputChatBox( "Введите e-mail и пароль" )    
        end
    end
end
addEventHandler("onClientGUIClick", resourceRoot, register)

