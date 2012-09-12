#
# Copyright (c) 2012 Uli Fuchs <ufuchs@gmx.com>
# Released under the terms of the GNU GPL v2.0.
#

KEY_NOT_FOUND=100

declare -a PROPERTIES
declare -a KEYSET

#
# Gets the key name of a key/value pair
# @param $1	the key/value pair
# qreturn	the key name of the key/value pair
getKey () {
  echo ${1%%=*}
}

#
# Gets the value of a key/value pair
# @param $1	the key/value pair
# qreturn	the value of the key/value pair
getValue () {
  echo "${1#*=}"
}

#
# checks if a list of keys contains a particular key
# @param $1	list of keys
# @param $2	key in question
# @return	true if list contains the key in question
#
containsKey () {
  
  local keys="$1"
  local keyInQuestion="$2"
  local found=0

  # key list lookup
  for key in $keys; do

    [ "$keyInQuestion" = "$key" ] && {
      found=1
      break
    }
      
  done

  return "$found"

}

#
# Gets the value of a property by a given key
# @param $1	key name of the property
# @return	value of the property
getPropertyValue () 
{

  local result=""

  for property in "${PROPERTIES[@]}"; do

    local key=$(getKey "$property")
    local value=$(getValue "$property")

    [ "$1" == "$key" ] && {
      result="$value"
      break
    }

  done 

  echo "$result"

}

#
# Loads the content from PROPERTY_FILENAME into an array named 'PROPERTIES'.
# An element in the array represents a single line from the property file.
# In the form 'KEY=VALUE
#
# @param $1	name of the property file
loadProperties () 
{

  local cnt=0

  while read line; do

    # 1.remove all leading whitespaces
    # 2 remove all trailing whitespaces
    # 3.remove all comments
    line=$(echo $line | sed -e 's/^[ 	]*//g' -e 's/[ 	]*$//g' -e 's/#.*//')
    #                               ^
    #                               |  this is a space and a tab because the sed on 
    #                               |+ Mac OS 10.7 doesn't recognize a '\t'

    [ ${#line} -eq 0 ] && continue  # skip the now eventually empty lines

    PROPERTIES[cnt]="$line"
    ((cnt++))

  done < "$1"                       # the input comes from here...

  # populate the KEYSET
  local i=0
  for property in "${PROPERTIES[@]}"; do 

    KEYSET[i]=$(getKey "$property")
    ((i++))

  done 

#  for i in "${KEYSET[@]}"; do echo $i; done 

}




