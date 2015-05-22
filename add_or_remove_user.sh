#!/bin/bash

if [ $# -lt 1 ]
  then
    echo "Usage : $0 userfile"
    exit
fi

if [ $(id -u) -eq 0 ]; then

    while IFS=, read username password; do
	# delete users starting with a "-":
	if [[ $username == -* ]]; then
	    actualuser=${username#"-"}
	    echo "DELETING USER $actualuser"
	    /usr/sbin/userdel -r $actualuser
        elif egrep "^$username" /etc/passwd >/dev/null;  then
	    echo "$username exists!"
	else
	    password=$(perl -e 'print crypt($ARGV[0], "password")' $password)

	    if  useradd -m -p "$password" "$username" >/dev/null; then
		echo "User '$username' has been added to system!"
	    else
		echo "Failed to add  user '$username'!"
	    fi
	fi
	if [[ $username == -* ]]; then
	    echo "No symbolic links for deleted user $username"
	else
	    ln -s /opt/shared_nbs /home/$username
	    ln -s /opt/quant_notebooks /home/$username
	fi
    done <"$@"
else
      echo "Only root may add a user to the system"
      exit
fi
