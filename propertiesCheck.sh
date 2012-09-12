#
# Copyright (c) 2012 Uli Fuchs <ufuchs@gmx.com>
# Released under the terms of the GNU GPL v2.0.
#
# checks the integrity of your properties against
# 1.Missing mandatory keys
# 2.Unknown/mispelled keys
# 3.Mandatory keys without value
#
# using this functionality is optional
#

#
# Appends a new string to a given other string
#
# @param $1	the current string
# @param $2	new string to add
# @param $3	separator sign between the concatenated strings
# @return	the current string plus the new string
#
appendTo () {

  local curr="$1"
  local new="$2"
  local separator=${3:-' '}
                       #  the default separator
                       #+ is the space sign

  [ ${#curr} -ne 0 ] && curr="$curr""$separator"
                       #  add the separator sign if the
                       #+ current string is no longer empty

  echo "$curr""$new"

}

#
#
#
checkForUnknownKeys () {

  local keys="$1"
  local unknownKeys=""

  # property list lookup
  for property in "${PROPERTIES[@]}"; do

    local keyInQuestion=$(getKey "$property")

    containsKey "$keys" "$keyInQuestion"

    [ $? -eq 0 ] && unknownKeys=$(appendTo "$unknownKeys" "$keyInQuestion""=")            

  done

  echo "$unknownKeys"

}

#
#
#
checkForMissingMandatoryKeys () 
{

  local mandatoryKeys="$1"
  local missingKeys=""

  for mandatoryKey in $mandatoryKeys; do

    local found=0

    for key in "${KEYSET[@]}"; do

      [ "$key" = "$mandatoryKey" ] && {
        found=1
        break
      }

    done

    [ $found -eq 0 ] && missingKeys=$(appendTo "$missingKeys" "$mandatoryKey")

  done

  echo "$missingKeys"
  
}

#
#
#
checkForMissingValues ()
{

  local mandatoryKeys="$1"
  local missingValues=""

  for property in "${PROPERTIES[@]}"; do

    local key=$(getKey "$property")

    containsKey "$mandatoryKeys" "$key"

    if [ $? -eq 1 ]; then

      local value="$(getValue "$property")"  

      if [ -z "$value" ]; then
        missingValues=$(appendTo "$missingValues" "$key""=")
      fi

    fi

  done 
  
  echo "$missingValues"

}

# writes a report section
#
#
writeReportSection () 
{

  local sectionName="$1"
  local pairs="$2"
  local ident="$3"

  [ ${#pairs} -eq 0 ] && return 0

  echo
  echo "$ident[$sectionName]"

  for pair in $pairs; do echo "  $ident$pair"; done

}

#
#
#
message () {

  echo "
===============================================================================
Report of integrity check:"

}

#
#
#
checkIntegrityOfProperties () {

  local allKeys="$1"
  local mandatoryKeys="$2"
  local unknownKeys
  local missingKeys
  local missingValues
  local ident=""

  local retVal=0

  # check for necessary keys
  missingKeys=$(checkForMissingMandatoryKeys "$mandatoryKeys")
  [ ${#missingKeys} -ne 0 ] && retVal=1

  # check for unknown key items
  unknownKeys=$(checkForUnknownKeys "$allKeys")
  [ ${#unknownKeys} -ne 0 ] && retVal=1

  # check for missing values in the mandatory keys
  missingValues=$(checkForMissingValues "$mandatoryKeys")
  [ ${#missingValues} -ne 0 ] && retVal=1

  [ $retVal -ne 0 ] && {

    message "checkIntegrityOfProperties"

    writeReportSection "Missing mandatory keys" "$missingKeys" "$ident"
    writeReportSection "Unknown/mispelled keys" "$unknownKeys" "$ident"
    writeReportSection "Mandatory keys without value" "$missingValues" "$ident"

  }

  return $retVal

}

