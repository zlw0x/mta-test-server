DB = dbConnect( "mysql", "host=127.0.0.1; port=3306", "admin", "passw0rd", "share=1" )

if DB then
	outputDebugString( "db connect ok" )
else
	outputDebugString( "db connect error" )
end


Connection.asyncQuery = function( self, callback, args, ... )
    local result = self:query( callback, args, ... )
    if result then 
        return result
    else 
        outputDebugString("MySQL QUERY ERROR "..tostring(result), 1 )
    end
end

Connection.Query = function( self, ... ) 
    local query = self:query( ... )
    local result = query:poll( -1 )
    return result
 end

 
 Connection.QuerySingle = function( self, ... )
    local result = self:query( ... )
    if type( result ) == "table" then
        return result[ 1 ]
    end
 end


 function dateToTimestamp( date )
    local year, month, day, = date:match( "( %d+ )-( %d+ )-( %d+ )" )
    return os.time( { year, month, day } )
end