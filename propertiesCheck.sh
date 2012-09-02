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
#
#
checkForUnknownKeys () {

  local keys="$1"
  local unknownKeys=""

  # property list lookup
  for property in $properties; do

    local found=0

    local propKey=$(echo ${property%%=*})

    # key list lookup
    for key in $keys; do

      [ "$propKey" = "$key" ] && {
        found=1
        break
      }

    done 

    [ $found -eq 0 ] && unknownKeys=$(appendTo "$unknownKeys" "$propKey""=")      

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

  for key in $mandatoryKeys; do

    getPropertyValue $key value
    [ $? -ne 0 ] && missingKeys=$(appendTo "$missingKeys" "$key")
    
  done

  echo "$missingKeys"
  
}

#
#
#
checkForMissingValues ()
{

  local unknownKeys="$1"
  local missingValues=""

  for property in $properties; do

    local found=0

#    local propKey=$(echo ${property%%=*})
#    local propValue=$(echo ${property##*=})

    local propKey=${property%%=*}
    local propValue=${property##*=}

    for unknownKey in $unknownKeys; do

      [ "$propKey" = "$unknownKey" ] && {
        found=1
        break
      }
      
    done

    [ $found -eq 1 ] && {
      [ -z "$propValue" ] && missingValues=$(appendTo "$missingValues" "$propKey""=")
    }

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

  # check for missing values in the mandatory keys
  missingValues=$(checkForMissingValues "$mandatoryKeys")
  [ ${#missingValues} -ne 0 ] && retVal=1

  [ $retVal -ne 0 ] && {

    message "checkIntegrityOfProperties"

    writeReportSection "Missing mandatory keys" "$missingKeys" "$ident"
    writeReportSection "Unknown/mispelled keys" "$unknownKeys" "$ident"
    writeReportSection "Keys without value" "$missingValues" "$ident"

  }

  return $retVal

}

