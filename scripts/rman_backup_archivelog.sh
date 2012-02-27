#!/bin/ksh
# File          	: rman_backup_archivelog.sh
# Created on    	: 2012/02/24
# Purpose       	: This script will perform a backup of archivelogs of a specified database, based on the API functions, if the size of the archivelogs directory exceeds a given size.
# Syntax        	: rman_backup_archivelog.sh <sid> <archivelog_path> [size] [archivelog_size]
#   <sid>       	: SID of the database to backup
#   <archivelog_path>   : Path of the archivelogs to check the size.
#   <size>		: Minimum size in the backup directory we need to perform the backup (if no specified, it's 20%)
#   <archivelog_size>	: If the size of the archivelogs directory exceeeds this size,the backup will be launched (if no specified, it's 10%).  

# Check the parameters
if [[ $# < 2 ]] ; then
	echo "Error, no enough arguments passed."
	echo "Usage : $0 <SID> <archivelog_path> [Size] [Archivelog_Size]"
	exit -1
fi

# Keep the parameters
db_sid="${1}"
archivelog_path="${2}"

if [[ "${3}" != "" ]] ; then
	min_size="${3}"
else
	min_size="20%"
fi

if [[ "${4}" != "" ]] ; then
        archivelog_size="${4}"
else
        archivelog_size="10%"
fi

# Load the libraries
. initapi ora 
. initapi os 

### Configuration

# Log files & path
export API_LOGFILE=${db_sid}_rman_backup_archivelog.log
export API_VLOGFILE=${db_sid}_verbose_rman_backup_archivelog.log
export API_LOGPATH="/home/oracle/logs/backup"

# Backup script
export BACKUPSCRIPT="archivelog_backup.rman"

### Main

# Print the configuration to the standart output
print_api_stdoutd "Backup	: ARCHIVELOG"
print_api_stdoutd "DB SID	: ${db_sid}"
print_api_stdoutd "Log 		: ${API_LOGPATH}/${API_LOGFILE}"
print_api_stdoutd "Verbose log 	: ${API_LOGPATH}/${API_VLOGFILE}"

# Execute the clean_resources function to end the script properly when CTRL-C or TERM signal is trap
trap "clean_resources 1" INT TERM 
# Initialize the log engine
# Note : The LOGPATH will be concatened to the LOGFILE into the LOGFILE variables
init_api_logs "APPEND"
print_api_logfile start

# Check if available space in the archivelog directory is inferior to $archivelog_size
print_api_all "Checking minimum available space in $archivelog_path"
chk_availablespace "$archivelog_path" "$archivelog_size"
if [[ "$?" == "0" ]] ; then
        # Enough disk space, we don't backup and leave the script
	print_api_all "Enough space in $archivelog_path"
	print_api_all "End of the script."	
	# Shut the log engine
	print_api_logfile end end 0
	exit 0
else
	# Not enough disk space, we'll perform the backup of archivelogs
        check_api_result 0 "Archivelog space check"            
fi

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

# Logging post-backup stats
print_api_all "Logging post-backup system informations"   
df -k                                               			>>${API_VLOGFILE}	# FS Usage
check_api_result $? "Post-backup system informations records"  

print_api_stdoutd "Script end."
print_api_stdoutd "Log 		: ${API_LOGFILE}"
print_api_stdoutd "Verbose log 	: ${API_VLOGFILE}"

# Shut the log engine
print_api_logfile end end 0
