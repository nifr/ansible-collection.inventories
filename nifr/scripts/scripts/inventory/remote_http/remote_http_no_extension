#!/usr/bin/env sh

inventory_endpoint='https://nifr.github.io/ansible-collection.inventory_scripts/examples/inventory.json'
hostvars_endpoint='https://nifr.github.io/ansible-collection.inventory_scripts/examples/host_vars/%s.json'

# https://nifr.github.io/ansible-collection.inventory_scripts/examples/inventory.json
# https://nifr.github.io/ansible-collection.inventory_scripts/examples/host_vars/host1.example.com.json

http_user='user'
http_password='password'
http_endpoint="${inventory_endpoint}"

output_stdout=
validation_error=
exit_code=1
debug=0

if [ ! -z "${DEBUG}" ]
then
  debug=1
  echo '$# is' $#
  echo '$1 is' $1
  echo '$2 is' $2
fi

if ! command -v 'curl' >/dev/null 2>&1
then
  validation_error='curl is required to query the HTTP inventory endpoint!'
fi

if [ "$#" -ne '1' ] && [ "$#" -ne '2' ]
then
  validation_error="Usage: '$0 --list' or '$0 --host <hostname>'"
fi

if [ "$1" != '--list' ] && [ "$1" != '--host' ]
then
  validation_error="Invalid argument '$1'!"
fi

if [ "$1" != '--list' ] && [ "$#" -ne '1' ]
then
  validation_error='The --list flag does not take any arguments!'
fi

if [ "$1" = '--host' ] && [ "$#" -ne '2' ]
then
  validation_error='Missing argument for --host parameter!'
fi

if [ "$1" = '--host' ]
then
  http_endpoint=$(printf '..%s..' "${hostvars_endpoint}" "$2")
fi

if [ ! -z "${validation_error}" ]
then
  echo "${validation_error}" >&2
else 
  output_stdout=$(curl --silent --fail --header 'Accept: application/json' --user "${http_user}:${http_password}" "${http_endpoint}")
  exit_code="$?"
fi

if [ "${exit_code}" -ne 0 ]
then
  printf 'curl to remote HTTP endpoint "%s" failed with exit code "%s".\n' "${http_endpoint}" "${exit_code}" >&2
  output_stdout='{}';
fi

echo "${output_stdout}";
exit "${exit_code}";