#!/bin/bash

#
# Copyright (c) 2012 Uli Fuchs <ufuchs@gmx.com>
# Released under the terms of the GNU GPL v2.0.
#

set +x

# include
source ../properties.sh
source ../propertiesCheck.sh

# extracts the pure script filename without extension.
# in this case --> 'project2tar'
SCRIPT_NAME=${0##*/}

#
# used properties
#
KEY_PROJECT_DIR="project-dir"
KEY_ARCHIVE_DIR="archive-dir"
KEY_TAR_EXTRA_OPTS="tar-extra-options"

mandatoryKeys="\
  $KEY_PROJECT_DIR \
  $KEY_ARCHIVE_DIR \
"

allKeys="\
  ${mandatoryKeys[0]} \
  ${mandatoryKeys[1]} \
  $KEY_TAR_EXTRA_OPTS \
"
  
#
#
#
archiveProject () {

  getPropertyValue $KEY_ARCHIVE_DIR archiveDir

  getPropertyValue $KEY_PROJECT_DIR projectDir

  # a missing 'projcetDir' is a show stopper...
  if [ ! -d ""$projectDir"" ]; then
    echo
    echo "  [error caused by property '"$KEY_PROJECT_DIR"']"
    echo "  '""$projectDir""' doesn't exists."
    abortExecution
  fi 

  # if 'archiveDir' doesn't exist the user can create it...
  if [ ! -d ""$archiveDir"" ]; then
    echo
    echo "  [info caused by property '"$KEY_ARCHIVE_DIR"']"
    echo "  '""$archiveDir""' doesn't exists."
    read -p "  Would you like to create this directory?[Y/n]" yesNo
    case "${yesNo:-Yes}" in
      [yY] | [yY][Ee][Ss])  echo "  creating directory '""$archiveDir""'"
            ;;
      *)  abortExecution
    esac
  fi 

  invokeTar "$projectDir" "$archiveDir"

}


#
#
#
invokeTar () {

  local projectDir="$1"
  local archiveDir="$2"
  getPropertyValue $KEY_TAR_EXTRA_OPTS extraOpts

  local archiveName=${projectDir##*/}
  archiveName="$archiveName"-"$(date +"%m-%d-%YT%H%M%S")"

#  archiveName=$(echo $archiveName | sed -e 's/[.]/_/g')

  tarparams="czPf $archiveDir/$archiveName.tgz $extraOpts $projectDir/"

  echo
  echo "  [invoking 'tar' with following params]"
  echo "  $tarparams"

  tar $tarparams

  echo
  echo "  [your tar-file has been written]"
  echo "  $archiveDir/$archiveName"

}

#
# creates an _empty_ property file.
# you have to populate the mandatory keys to run the script whitout any next show stoppers
#
# @param $1	name of the property file
#
createPropFile () {

  local propfileName="$1"

  (cat <<- EOF
	# Template for '$propfileName'

	# Mandatory
	# Set here your project directory
	$KEY_PROJECT_DIR=

	# Mandatory
	# Set here your archive directory
	$KEY_ARCHIVE_DIR=

	# Optional
	# Set here extra options for the 'tar'
	$KEY_TAR_EXTRA_OPTS=
	EOF
  ) > "$propfileName"

  propertyFileMustBeConfiguredMessage

}


#
#
#
abortExecution () {

  echo "
===============================================================================

  Execution aborted.
  Please fix the hints first.
"
  exit 1;
}

#
#
#
usageMsg () {
  echo
  echo "usage : $SCRIPT_NAME" [propertyfile]
  echo "        if propertyfile isn't given, the script tries to use '"$SCRIPT_NAME"'"
}

#
#
#
propertyFileMustBeConfiguredMessage () {

  echo "
===============================================================================

  Execution aborted.
  Your property file hasn't been found.
  Instead a new property file has been created.
  Please configure this new property file before you try an other run.
"

}

# determines the name of the property file.
# if no '$1' is given, the name of the property file results from the script name.
# otherwise '$1' will be used to name the property file.
#
# @param $1	argument 1 from the commandline
# @return	a property file name as descriped
determinePropFileName () {
  
  local propFileName=${1%%.*}

  if [ ${#propFileName} -eq 0 ]; then
    propFileName="${SCRIPT_NAME%%.*}.properties"
  else
    propFileName="$propFileName.properties"
  fi

  echo $propFileName

}

#
#
#
main () {

  local propFileName=$(determinePropFileName "$1")

  if [ ! -e "$propFileName" ]; then

    usageMsg

    createPropFile "$propFileName"
 
    exit 1

  fi

  properties=$(loadProperties "$propFileName")

  checkIntegrityOfProperties "$allKeys" "$mandatoryKeys"

  [ $? -ne 0 ] && abortExecution

  archiveProject

}

main $1





