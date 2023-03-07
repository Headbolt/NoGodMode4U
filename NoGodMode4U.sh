#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	NoGodMode4U.sh
#	https://github.com/Headbolt/NoGodMode4U
#
#   This Script is designed for use in JAMF
#
#	The Following Variables should be defined
#	Variable 4 - Named "Desired Local Admins - eg. user1 user2 user3"
#
#   - This script will ...
#			Check through and ensure the local Admin group only contains desired accounts
#
###############################################################################################################################################
#
# HISTORY
#
#	Version: 1.1 - 07/03/2023
#
#	15/04/2017 - V1.0 - Created by Headbolt
#
#	07/03/2023 - V1.1 - Updated by Headbolt
#							More comprehensive notation, lot of tidying up
#
###############################################################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
AdminUsers=$4 # Grab the usernames for the user we want to be admins from JAMF variable #4 eg. user1 user2
#
ScriptName="MacOS | Local Admins" # Set the name of the script for later logging
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# CurrentAdminCheck Function
#
CurrentAdminCheck(){
#
CurrentLocalADAdmins=$(dscacheutil -q group -a name admin | grep "users" | cut -c 8-)
/bin/echo 'Local Admins = "' $CurrentLocalADAdmins'"'
#
}
#
###############################################################################################################################################
#
# Process Function
#
Process(){
#
/bin/echo 'Processing all Local Users'
#
for username in $(dscl . list /Users UniqueID | awk '$2 { print $1 }' | tr “[A-Z]” “[a-z]”)
do
	if [[ $(dsmemberutil checkmembership -U "${username}" -G admin) != *not* ]]
		then
			if [[ $AdminUsers != *$username* ]]
				then
					/bin/echo 'Removing Local Account "'$username'" From Local Admins Group' # Outputs Name To Be Removed from Current Admins List
					dseditgroup -o edit -d $username admin
					dseditgroup -o edit -d $username _appserveradm
					dseditgroup -o edit -d $username _appserverusr
			fi
	else
		if [[ $AdminUsers == *$username* ]]
			then
				/bin/echo 'Adding Local Account "'$username'" To Local Admins Group' # Outputs Name Being Added to Current Admins List
				dseditgroup -o edit -a $username admin
				dseditgroup -o edit -a $username _appserveradm
				dseditgroup -o edit -a $username _appserverusr
		fi	
	fi
done
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
/bin/echo Ending Script '"'$ScriptName'"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
####################################################################################################
#
/bin/echo # Outputs a blank line for reporting purposes
SectionEnd
#
/bin/echo 'Checking Initial local Admins'
CurrentAdminCheck
SectionEnd
#
/bin/echo 'Desired Local Admins = "'$AdminUsers'"'
SectionEnd
#
Process
SectionEnd
#
/bin/echo 'Checking New local Admins'
CurrentAdminCheck
SectionEnd
ScriptEnd
