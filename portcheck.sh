#!/bin/sh
/usr/bin/clear
echo "Running Portcheck.."

# Check if the user is root.
if [ $(whoami) != "root" ]; then
	echo ""
    echo "You must be root to run this script!"
    echo "Terminating portcheck.. done."
    echo ""
    exit 1
fi

# Using portsnap from the base system to fetch and install or update the ports.
if [ -d /var/db/portsnap ]; then
	echo ""
	echo "Portcheck step [1/3] - Fetching and updating the ports tree."
	echo ""
	echo "Fetching and updating the ports.."
	/usr/sbin/portsnap fetch update
	if [ $? = "1" ]; then
		echo ""
		echo "Something went wrong! Portsnap has reported an error!"
		echo "You need to have a working and functional Internet" 
		echo "connection in order to use this script!"
		echo ""
	    echo "Terminating portcheck.. done."
	    exit 1
	else
		echo "Done fetching and updating the ports."
	fi
else
	echo ""
	echo "Portcheck step [1/3] - Fetching and extracting the ports tree."
	echo ""
	echo "Fetching and extracting the ports.."
	/usr/sbin/portsnap fetch extract
	if [ $? = "1" ]; then
		echo ""
		echo "Something went wrong! Portsnap has reported an error!"
		echo "You need to have a working and functional Internet" 
		echo "connection in order to use this script!"
		echo ""
	    echo "Terminating portcheck.. done." 
		echo ""
	    exit 1
	else
		echo "Done fetching and extracting the ports."
		echo ""
	fi
fi

# Check if portaudit is installed.
if [ ! -e /usr/local/sbin/portaudit ]; then
	echo ""
	echo "The program 'portaudit' is not installed!"
 	echo "Portcheck needs portaudit to check all your installed packages"
	echo "for important security updates."
	echo ""
	echo "You can install portaudit using the command 'make install clean'"
	echo "in /usr/ports/security/portaudit. Or if you want to use binary"
 	echo "installation by issuing the command 'pkg_add -r portaudit'."
 	echo ""
 	echo "Please install portaudit and re-run this script!" 
	echo "Terminating portcheck.. done."
	echo ""
	exit 1
fi

# Check if any installed packages needs updating
echo ""
echo "Portcheck step [2/3] - Normal checkup."
echo ""
echo "Doing a normal checkup of all installed packages.."
echo "This may take a while!"
/usr/sbin/pkg_version -v -l '<' > /var/log/portcheck.log

# Check if any installed packages has any security issues
echo ""
echo "Portcheck step [3/3] - Security checkup."
echo ""
echo "Doing a security checkup of all installed packages.."

/usr/local/sbin/portaudit -Fda > /tmp/portcheck.txt 
if [ $? = "1" ]; then
	echo "" >> /var/log/portcheck.log 
	echo "The following packages has security issues!" >> /var/log/portcheck.log
	echo "" >> /var/log/portcheck.log
	/bin/cat /tmp/portcheck.txt >> /var/log/portcheck.log
	/bin/rm /tmp/portcheck.txt
else
	echo "" >> /var/log/portcheck.log 
	echo "No security issues found." >> /var/log/portcheck.log
fi

echo ""
echo "Portcheck result.."
echo ""

/bin/cat /var/log/portcheck.log
echo ""
echo "A copy of the above result is kept in /var/log/portcheck.log"
echo "Portcheck.. done."
echo ""
