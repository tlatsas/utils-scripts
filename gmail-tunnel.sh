#!/bin/sh

# Tunel imap connection through your server

_server="your-server-here"
_port="your-server-port-here"
_username="your-server-login-name"


# tunnel gmail imap  (imap.gmail.com:993) <-> (localhost:10993)
ssh -f -N -L localhost:10993:imap.gmail.com:993 -p ${_port} -l ${_username} ${_server}


# tunnel gmail smtp  (smtp.gmail.com:587) <-> (localhost:10587)
ssh -f -N -L localhost:10587:smtp.gmail.com:587 -p ${_port} -l ${_username} ${_server}

