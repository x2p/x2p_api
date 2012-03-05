#!/bin/ksh
# File          : datapump_export.sh
# Created on    : 2012/03/05
# Purpose       : This script will perform a logical backup of specified database objects.
# Syntax        : datapump_export.sh <sid> <type> <names>
#   <sid>       : SID of the database to backup
#   <type>      : FULL|TABLESPACE|SCHEMA 
#   <names>     : Name[,Name][...] 
# Example	: datapump_export.sh DTEST01 FULL
# Example	: datapump_export.sh DTEST01 SCHEMA SCOTT,HR

# Check the parameters
if [[ $# < 2 ]] ; then
        echo "Error, not enough arguments passed."
        echo "Usage : $0 <SID> <TYPE> [NAMES]"
        exit -1
fi

# Keep the parameters
db_sid="${1}"
bck_type="${2}"
bck_names="${3}"

# Load the libraries
. initapi ora

### Configuration

# Log files & path
export API_LOGFILE=${db_sid}_datapump_export.log
export API_VLOGFILE=${db_sid}_verbose_datapump_export.log
export API_LOGPATH="/home/oracle/logs/backup"

### Main

# Print the configuration to the standart output
print_api_stdoutd "EXPORT	: ${bck_type}"
print_api_stdoutd "DB SID       : ${db_sid}"
print_api_stdoutd "Log          : ${API_LOGPATH}/${API_LOGFILE}"
print_api_stdoutd "Verbose log  : ${API_LOGPATH}/${API_VLOGFILE}"

# Execute the clean_resources function to end the script properly when CTRL-C or TERM signal is trap
trap "clean_resources 1" INT TERM
# Initialize the log engine
# Note : The LOGPATH will be concatened to the LOGFILE into the LOGFILE variables
init_api_logs
print_api_logfile start

# Initializing Oracle environment
print_api_all "Initializing Oracle ${db_sid} environment"
set_ora_env ${db_sid}                                           >>${API_VLOGFILE}
check_api_result $? "Oracle environnement initialization"

# Logging pre-backup stats
print_api_all "Logging pre-backup system informations"
df -k                                                                   >>${API_VLOGFILE}       # FS Usage
env                                                                     >>${API_VLOGFILE}       # show environnement settings
check_api_result $? "Pre-backup system informations records"

# Executing datapump export
print_api_all "Executing logical backup"
export_datapump "${bck_type}" "${bck_names}"                                      >>${API_VLOGFILE}
check_api_result $? "Datapump execution"

# Logging post-backup stats
print_api_all "Logging post-backup system informations"
df -k                                                                   >>${API_VLOGFILE}       # FS Usage
check_api_result $? "Post-backup system informations records"

print_api_stdoutd "Script end."
print_api_stdoutd "Log          : ${API_LOGFILE}"
print_api_stdoutd "Verbose log  : ${API_VLOGFILE}"

# Shut the log engine
print_api_logfile end end 0
