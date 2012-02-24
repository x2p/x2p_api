#!/bin/ksh
# File          : rman_backup_inc0.sh
# Created on    : 2012/02/22
# Purpose       : This script will perform an incremental level 0 backup of a specified database, based on the API functions.
# Syntax        : rman_backup_full.sh <sid> <size>
#   <sid>       : SID of the database to backup
#   <size>	: Minimum size in the backup directory we need to perform the backup (if no specified, it's 20%)
# History       :
#  2012/02/22 (J. Alarcon) Initial version from ora_backup.sh by B. Garcia
# Developpers   :
#   Benoit Garcia can be reached at <benoit.garcia@x2p.fr>
#   Julien Alarcon can be reached at <julien.alarcon@x2p.fr>

# Check the parameters
if [[ $# < 1 ]] ; then
	echo "Error, no arguments passed."
	echo "Usage : $0 <SID> [Size]"
	exit -1
fi

# Keep the parameters
db_sid="${1}"

if [[ "${2}" != "" ]] ; then
	min_size="${2}"
else
	min_size="20%"
fi

# Load the libraries
. initapi ora 
. initapi os 

### Configuration

# Log files & path
export API_LOGFILE=${db_sid}_rman_backup_inc0.log
export API_VLOGFILE=${db_sid}_verbose_rman_backup_inc0.log
export API_LOGPATH="/home/oracle/logs/backup"

# Backup script
export BACKUPSCRIPT="inc0_backup.rman"

### Main

# Print the configuration to the standart output
print_api_stdoutd "Backup	: INCREMENTAL LEVEL 0"
print_api_stdoutd "DB SID	: ${db_sid}"
print_api_stdoutd "Log 		: ${API_LOGPATH}/${API_LOGFILE}"
print_api_stdoutd "Verbose log 	: ${API_LOGPATH}/${API_VLOGFILE}"

# Execute the clean_resources function to end the script properly when CTRL-C or TERM signal is trap
trap "clean_resources 1" INT TERM 
# Initialize the log engine
# Note : The LOGPATH will be concatened to the LOGFILE into the LOGFILE variables
init_api_logs
print_api_logfile start

# Initializing Oracle environment
print_api_all "Initializing Oracle ${db_sid} environment"
set_ora_env ${db_sid}                              		>>${API_VLOGFILE}
check_api_result $? "Oracle environnement initialization"  

# Get the path for backup 
print_api_all "Get the RMAN backup path for ${db_sid}" 
get_rman_backuppath                                                   	>>${API_VLOGFILE}
check_api_result $? "RMAN backup path: ${BACKUP_PATH}" 

# Logging pre-backup stats
print_api_all "Logging pre-backup system informations"
df -k                                               			>>${API_VLOGFILE}      	# FS Usage
env                                                 			>>${API_VLOGFILE}	# show environnement settings
check_api_result $? "Pre-backup system informations records"

# Checking available space
print_api_all "Checking available space at least ${min_size}" 
chk_availablespace "${BACKUP_PATH}" "${min_size}"			>>${API_VLOGFILE}
check_api_result $? "Available space check"	

# Executing backup script
print_api_all "Executing backup script ${BACKUPSCRIPT}"
run_ora_rmanscript ${BACKUPSCRIPT} 		        		>>${API_VLOGFILE}
check_api_result $? "Backup script execution"

# Crosscheck
print_api_all "Performing crosscheck"        
run_ora_rmanscript "crosscheck.rman"              			>>${API_VLOGFILE}
check_api_result $? "Crosscheck operation" 

# Delete Expired
print_api_all "Deletion of EXPIRED backups and archivelogs" 
run_ora_rmanscript "delete_expired.rman"               			>>${API_VLOGFILE}
check_api_result $? "Deletion of EXPIRED backups and archivelogs"  

# Delete Obsolete
print_api_all "Deletion of OBSOLETE backups and archivelogs" 
run_ora_rmanscript "delete_obsolete.rman"                               >>${API_VLOGFILE}
check_api_result $? "Deletion of OBSOLETE backups and archivelogs"

# Logging post-backup stats
print_api_all "Logging post-backup system informations"   
df -k                                               			>>${API_VLOGFILE}	# FS Usage
check_api_result $? "Post-backup system informations records"  

print_api_stdoutd "Script end."
print_api_stdoutd "Log 		: ${API_LOGFILE}"
print_api_stdoutd "Verbose log 	: ${API_VLOGFILE}"

# Shut the log engine
print_api_logfile end end 0
