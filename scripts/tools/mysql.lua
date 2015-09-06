local ffi = require("ffi")
local table = require("table")
local string = require("string")
local math = require( "math")

ffi.cdef[[
      typedef void MYSQLwrap_t;
      void free(void*ptr);
      void * malloc(size_t size);
      unsigned long	mysql_real_escape_string(MYSQLwrap_t *mysql, char *to,const char *from, unsigned long from_length);

      MYSQLwrap_t * mysql_init( MYSQLwrap_t *mysql );
		int mysql_options(MYSQLwrap_t *mysql,enum mysql_option option, const void *arg);
		int mysql_ping(MYSQLwrap_t *mysql);
      MYSQLwrap_t * mysql_real_connect( MYSQLwrap_t *mysql,
                                        const char *host,
                                        const char *user,
                                        const char *passwd,
                                        const char *db,
                                        unsigned int port,
                                        const char *unix_socket,
                                        unsigned long clientflag);

      unsigned int mysql_errno(MYSQLwrap_t *mysql);
      const char *mysql_error(MYSQLwrap_t *mysql);

      int  mysql_query(MYSQLwrap_t *mysql, const char *q);
      typedef void MYSQL_RESwrap_t;
      MYSQL_RESwrap_t * mysql_store_result(MYSQLwrap_t *mysql);

      unsigned long long mysql_num_rows(MYSQL_RESwrap_t *res);

      typedef char **MYSQL_ROWwrap_t;

      MYSQL_ROWwrap_t mysql_fetch_row(MYSQL_RESwrap_t *result);

      void mysql_free_result(MYSQL_RESwrap_t *result);

	  int mysql_next_result(MYSQLwrap_t *mysql);

	enum enum_mysql_error_type {
							CR_COMMANDS_OUT_OF_SYNC = 2014, //
							CR_SERVER_GONE_ERROR = 2006,    //MySQL server has gone away
							CR_SERVER_LOST =  2013,         //Lost connection to MySQL server during query
							CR_UNKNOWN_ERROR = 2000         //Unknown MySQL error
						};
	enum mysql_option 
	{
	  MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,
	  MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,
	  MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,
	  MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,
	  MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,
	  MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,
	  MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,
	  MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT,
	  MYSQL_OPT_SSL_VERIFY_SERVER_CERT
	};
								
      enum enum_field_types { MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY,
                              MYSQL_TYPE_SHORT,  MYSQL_TYPE_LONG,
                              MYSQL_TYPE_FLOAT,  MYSQL_TYPE_DOUBLE,
                              MYSQL_TYPE_NULL,   MYSQL_TYPE_TIMESTAMP,
                              MYSQL_TYPE_LONGLONG,MYSQL_TYPE_INT24,
                              MYSQL_TYPE_DATE,   MYSQL_TYPE_TIME,
                              MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR,
                              MYSQL_TYPE_NEWDATE, MYSQL_TYPE_VARCHAR,
                              MYSQL_TYPE_BIT,
                              MYSQL_TYPE_NEWDECIMAL=246,
                              MYSQL_TYPE_ENUM=247,
                              MYSQL_TYPE_SET=248,
                              MYSQL_TYPE_TINY_BLOB=249,
                              MYSQL_TYPE_MEDIUM_BLOB=250,
                              MYSQL_TYPE_LONG_BLOB=251,
                              MYSQL_TYPE_BLOB=252,
                              MYSQL_TYPE_VAR_STRING=253,
                              MYSQL_TYPE_STRING=254,
                              MYSQL_TYPE_GEOMETRY=255

                           };


      // mysql 5.1.x
      typedef struct st_mysql_field {
         char *name;                 /* Name of column */
         char *org_name;             /* Original column name, if an alias */
         char *table;                /* Table of column if column was a field */
         char *org_table;            /* Org table name, if table was an alias */
         char *db;                   /* Database for table */
         char *catalog;	      /* Catalog for table */
         char *def;                  /* Default value (set by mysql_list_fields) */
         unsigned long length;       /* Width of column (create length) */
         unsigned long max_length;   /* Max width for selected set */
         unsigned int name_length;
         unsigned int org_name_length;
         unsigned int table_length;
         unsigned int org_table_length;
         unsigned int db_length;
         unsigned int catalog_length;
         unsigned int def_length;
         unsigned int flags;         /* Div flags */
         unsigned int decimals;      /* Number of decimals in field */
         unsigned int charsetnr;     /* Character set */
         int type;                   /* Type of field. See mysql_com.h for types */
         void *extension;
      } MYSQL_FIELDwrap_t;

      MYSQL_FIELDwrap_t * mysql_fetch_fields(MYSQL_RESwrap_t *res);

      unsigned int mysql_num_fields(MYSQL_RESwrap_t *res);

      void mysql_close(MYSQLwrap_t *sock);

      unsigned long * mysql_fetch_lengths(MYSQL_RESwrap_t *result);
	  typedef void MYSQL_TIMEwrap_t ;
]]

local mysqllib = nil

if ffi.os=='Windows' then
	print('try to load libmysql.dll..')
	mysqllib = ffi.load( "libmysql.dll", true )
	if not mysqllib then print('Failed to load mysql') end
else
	print('try to load mysqlclient..')
	mysqllib = ffi.load( "mysqlclient", true )
	if not mysqllib then print('Failed to load mysql') end
end


local mysql_is_num_types =
   function(t)
      return ( t == mysqllib.MYSQL_TYPE_DECIMAL or t == mysqllib.MYSQL_TYPE_TINY or t == mysqllib.MYSQL_TYPE_SHORT or t == mysqllib.MYSQL_TYPE_LONG or t == mysqllib.MYSQL_TYPE_FLOAT or t == mysqllib.MYSQL_TYPE_DOUBLE or t==mysqllib.MYSQL_TYPE_LONGLONG)
   end
local mysql_is_string_types =
   function(t)
      return ( t == mysqllib.MYSQL_TYPE_STRING or t == mysqllib.MYSQL_TYPE_VAR_STRING )
   end
local mysql_is_blob_types =
   function(t)
      return ( t == mysqllib.MYSQL_TYPE_BLOB or t == mysqllib.MYSQL_TYPE_TINY_BLOB or t == mysqllib.MYSQL_TYPE_MEDIUM_BLOB or t == mysqllib.MYSQL_TYPE_LONG_BLOB )
   end



local time_ull_to_table =
   function(ffiull)  -- 19830905132800ULL
      local n = tonumber(ffiull)
      return { sec = math.floor(n)%100,
               min = math.floor(n/100)%100,
               hour = math.floor(n/100/100)%100,
               day = math.floor(n/100/100/100)%100,
               month = math.floor(n/100/100/100/100)%100,
               year = math.floor(n/100/100/100/100/100)%10000 }
   end

local function str_to_time_t(strTime)
	local year = string.sub(strTime, 0, 4)
	local month = string.sub(strTime, 6, 7)
	local day = string.sub(strTime, 9, 10)

	local hour = tonumber(string.sub(strTime, 12, 13)) or 0
	local minute = tonumber(string.sub(strTime, 15, 16)) or 0
	local second = tonumber(string.sub(strTime, 18, 19)) or 0

	return os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second})
end

local mysql_query =
   function( self, qstr )
	
 --     self:log("mysql_query:", qstr)
--	print(qstr)
      local ret = mysqllib.mysql_query( self.conn, qstr )
	  
	  		local repCount = 100
		while ret == ffi.C.CR_SERVER_LOST or ret==ffi.C.CR_SERVER_GONE_ERROR do
            mysqllib.mysql_ping(self.conn)
            ret = mysqllib.mysql_query(self.conn,qstr)
            if ret ~= 0 then ret = mysqllib.mysql_errno(self.conn) end
            --log
            repCount = repCount -1
            if repCount <= 0 then
                return nil
            end
        end
		
      if ret ~= 0 then
		print('sql = '..qstr)
         error( "fatal:" .. ffi.string(mysqllib.mysql_error(self.mysql)))
      end
      local res = mysqllib.mysql_store_result(self.mysql)
     -- local nullpo = ffi.cast( "MYSQL_RESwrap_t *", 0 )

	  if ffi.cast('void*',res)==nil then
		return nil
	  end

      local nrows = tonumber(mysqllib.mysql_num_rows( res ))
      local nfields = tonumber(mysqllib.mysql_num_fields( res ) )

      local fldtbl = {}
      local flds = mysqllib.mysql_fetch_fields(res)
      for i=0,nfields-1 do
         local f = { name = ffi.string(flds[i].name), type = tonumber(flds[i].type) }
         table.insert( fldtbl, f )
      end


      local restbl={}

      for i=1,nrows do
         local row = mysqllib.mysql_fetch_row( res )
         local lens = mysqllib.mysql_fetch_lengths( res )
         local rowtbl={}
         for i=1,nfields do
            local fdef = fldtbl[i]
            if row[i-1] == ffi.cast( "char*",0) then
               rowtbl[ fdef.name ] = nil
            elseif mysql_is_num_types(fdef.type) then
               rowtbl[ fdef.name ] = tonumber( ffi.string( row[i-1] ) )
            elseif mysql_is_string_types(fdef.type) then
               --rowtbl[ fdef.name ] = ffi.string( row[i-1] )
			   local tmp = ffi.new('uint8_t[?]', lens[i-1])
			   ffi.copy(tmp, row[i-1], lens[i-1])
			   rowtbl[ fdef.name ] = tmp
            elseif mysql_is_blob_types(fdef.type) then
--               rowtbl[ fdef.name ] = ffi.string( row[i-1], lens[i-1] )
			   local tmp = ffi.new('uint8_t[?]', lens[i-1])
			   ffi.copy(tmp, row[i-1], lens[i-1])
			   rowtbl[ fdef.name ] = tmp
            elseif fdef.type == mysqllib.MYSQL_TYPE_TIMESTAMP or fdef.type == mysqllib.MYSQL_TYPE_DATETIME or fdef.type == mysqllib.MYSQL_TYPE_DATE or fdef.type == mysqllib.MYSQL_TYPE_TIME then
 --              local w = ffi.new("int[1]",{})
               local datestr = ffi.string( row[i-1] )
 --[[              local llt,r
               if fdef.type == mysqllib.MYSQL_TYPE_TIME then
                  r = mysqllib.str_to_time( datestr, string.len(datestr), self.timeStruct, w )
                  llt = mysqllib.TIME_to_ulonglong( self.timeStruct )
               else
                  r = ffi.C.str_to_datetime( datestr, string.len(datestr), self.timeStruct, 0, w )
                  if fdef.type == mysqllib.MYSQL_TYPE_DATE then
                     llt = mysqllib.TIME_to_ulonglong_date( self.timeStruct )
                     llt = llt * 100 * 100 * 100
                  elseif fdef.type == mysqllib.MYSQL_TYPE_TIMESTAMP or fdef.type == mysqllib.MYSQL_TYPE_DATETIME then
                     llt = mysqllib.TIME_to_ulonglong( self.timeStruct )
                  end
               end
               rowtbl[ fdef.name ] = time_ull_to_table(llt) ]]
			   rowtbl[ fdef.name ] = str_to_time_t(datestr)
            else
              error( string.format( "type %d is not implemented", fdef.type ) )
            end
         end
         table.insert(restbl, rowtbl)
      end

	mysqllib.mysql_free_result(res)
	--while mysqllib.mysql_next_result(self.conn) do mysqllib.mysql_free_result(res) end
	return restbl
   end

local mysql_query_multi =
   function( self, qstr )
		self:log("mysql_query:", qstr)
		local ret = mysqllib.mysql_query( self.conn, qstr )
		if ret ~= 0 then
			error( "fatal:" .. ffi.string(mysqllib.mysql_error(self.mysql)))
		end

		local restbl={}

		local res = nil
		local index = 0
		repeat
			index = index + 1
			res = mysqllib.mysql_store_result(self.mysql)
			if ffi.cast('void*',res)==nil then
				break
			end
			restbl[index] = {}
			local nrows = tonumber(mysqllib.mysql_num_rows( res ))
			local nfields = tonumber(mysqllib.mysql_num_fields( res ) )
			local fldtbl = {}
			local flds = mysqllib.mysql_fetch_fields(res)
			for i=0,nfields-1 do
				local f = { name = ffi.string(flds[i].name), type = tonumber(flds[i].type) }
				table.insert( fldtbl, f )
			end
			for i=1,nrows do
				local row = mysqllib.mysql_fetch_row( res )
				local lens = mysqllib.mysql_fetch_lengths( res )
				local rowtbl={}
				for i=1,nfields do
					local fdef = fldtbl[i]
					if row[i-1] == ffi.cast( "char*",0) then
						rowtbl[ fdef.name ] = nil
					elseif mysql_is_num_types(fdef.type) then
						rowtbl[ fdef.name ] = tonumber( ffi.string( row[i-1] ) )
					elseif mysql_is_string_types(fdef.type) then
						local tmp = ffi.new('uint8_t[?]', lens[i-1])
						ffi.copy(tmp, row[i-1], lens[i-1])
						rowtbl[ fdef.name ] = tmp
					elseif mysql_is_blob_types(fdef.type) then
						local tmp = ffi.new('uint8_t[?]', lens[i-1])
						ffi.copy(tmp, row[i-1], lens[i-1])
						rowtbl[ fdef.name ] = tmp
					elseif fdef.type == mysqllib.MYSQL_TYPE_TIMESTAMP or fdef.type == mysqllib.MYSQL_TYPE_DATETIME or fdef.type == mysqllib.MYSQL_TYPE_DATE or fdef.type == mysqllib.MYSQL_TYPE_TIME then
						local datestr = ffi.string( row[i-1] )
						rowtbl[ fdef.name ] = str_to_time_t(datestr)
					else
						error( string.format( "type %d is not implemented", fdef.type ) )
					end
				end
				table.insert(restbl[index],rowtbl)
			end
			mysqllib.mysql_free_result(res)
		until mysqllib.mysql_next_result(self.conn)~=0
		return restbl
   end

local mysql_escape =
   function( self, orig )
      if not orig then return nil end
      local strsz = string.len(orig) * 2 + 1 + 1
      local cdata = ffi.new( "char[" .. strsz .. "]", {})
      local ret = mysqllib.mysql_real_escape_string(self.conn, cdata, orig, string.len(orig) )
      return ffi.string( cdata, ret )
   end

local mysql_connect =
   function( self, host, user, password, db )
	  print("连接数据库"..host..',name:'..db)
      local out={}
      local mysql = ffi.cast( "MYSQLwrap_t*",ffi.C.malloc( 1024*1024 ))
      local ret = mysqllib.mysql_init(mysql)
      self:log("mysql_init:", ret )
	  local mb = ffi.new('char[1]', 1)
	  mysqllib.mysql_options(mysql, mysqllib.MYSQL_OPT_RECONNECT, mb)
      local conn = mysqllib.mysql_real_connect( mysql, host, user, password, db, 3306,NULL,196608 )
      local nullpo = ffi.cast( "MYSQLwrap_t*",0)
      if conn == nullpo then
         error( "fatal:" .. ffi.string(mysqllib.mysql_error(mysql)) )
         return nil
      end

      local timeStruct = ffi.cast( "MYSQL_TIMEwrap_t*",ffi.C.malloc(1024))

--	  out.db_info = {host=host, user=user, password=password, db=db}
      out.mysql = mysql
      out.conn = conn
	  out.escape = mysql_escape
      out.query = mysql_query
	  out.query_m = mysql_query_multi
      out.execute = mysql_query -- from luasql
      out.log = self.log
      out.doLog = false
      out.toggleLog = function(self,v) self.doLog = v end
      out.close = function(self) mysqllib.mysql_close( self.conn ) end
      out.timeStruct = timeStruct
      return out
   end

local _log = function(self,...) if self.doLog then print(...) end end

--selfTest()

return {
   connect = mysql_connect,
   escape = mysql_escape,
   log = _log,
   doLog = false
}
