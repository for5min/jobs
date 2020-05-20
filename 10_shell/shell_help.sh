#!/bin/bash
usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":hs:p:" arg; do
  case $arg in
    p) # Specify p value.
      echo "p is ${OPTARG}"
      ;;
    s) # Specify strength, either 50 or 100.
      strength=${OPTARG}
      [ $strength -eq 50 -o $strength -eq 100 ] \
        && echo "Strength is $strength." \
        || echo "Strength needs to be either 50 or 100, $strength found instead."
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done