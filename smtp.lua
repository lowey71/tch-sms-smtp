#!/usr/bin/lua
local smtp = require("socket.smtp")

if ( arg[1] == nil or arg[2] == nil or arg[3] == nil or arg[4] == nil or arg[5] == nil ) then
  print ("ERROR - need 5 arguments - server from to subject body")
  os.exit(1)
end  
   
mesgt = {
  headers = {
    subject = arg[4]
  },
  body = arg[5]
}

r, e = smtp.send{
  from = arg[2],
  rcpt = arg[3], 
  source = smtp.message(mesgt),
  server = arg[1]
}

if r == nil then
  print ("ERROR - LUA SMTP:",e)
  os.exit(1)
end
