#
# Copyright (c) 2012 Uli Fuchs <ufuchs@gmx.com>
# Released under the terms of the GNU GPL v2.0.
#

KEY_NOT_FOUND=100

#
# Gets the value of a property by a given key
#
# @param $1	key name of the property
# @param $2	value of the property by reference
# @return	if successfull otherwise PROPKEY_NOT_FOUND
getPropertyValue () 
{

  local result=$2   

  for property in $properties; do

    local key=$(echo ${property%%=*})
    local value=$(echo ${property##*=})

    [ "$1" = "$key" ] && {
      eval $result="'$value'"
      return 0
    }

  done 

  return $PROPKEY_NOT_FOUND

}

#
# Appends a new key/value pair to a given property string
#
# @param $1	the current property string
# @param $2	new property to add
# @param $3	separator sign between the concatenated properties
# @return	the current property string plus the new property
#
appendTo () {

  local properties="$1"
  local value="$2"
  local separator=${3:-' '}

  [ ${#properties} -ne 0 ] && properties="$properties""$separator"

  echo "$properties""$value"

}

#
# Loads the content from PROPERTY_FILENAME into an array.
# An element in the array represents a single line from the property file.
# In the form 'KEY=VALUE
#
# @param $1	name of the property file
# @return	an array of key/value pairs 
loadProperties () 
{

  local result=""

  #  Remove all comments and
  #+ leading and trailing white spaces and
  #+ spaces within the property
  #   
  while read line; do

    # 1.remove all whitespaces
    # 2.remove all comments
    line=$(echo $line | sed -e 's/[ \t]*//g' -e 's/#.*//')    

    [ ${#line} -eq 0 ] && continue       # skip the now eventually empty lines

     result=$(appendTo "$result" "$line")

  done < "$1"                            # the input comes from here...

  echo "$result"

}
