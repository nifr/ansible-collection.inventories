#!/usr/bin/env sh

# Example Usage:
#
# export HTTP_ENDPOINT_INVENTORY='https://nifr.github.io/ansible-collections/examples/inventory.json'
# export HTTP_ENDPOINT_HOST_VARS='https://nifr.github.io/ansible-collections/examples/host_vars/%s.json'
#
# ./remote_http.sh --list
# ./remote_http.sh --host 'host1.example.com'
#
# ansible-inventory --inventory ./remote_http.sh --graph
# ansible-inventory --inventory ./remote_http.sh --list [--yaml]

http_user=''
http_password=''
http_endpoint=''

output_stdout=
validation_error=
exit_code=1
debug=0

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

if [ "$1" = '--list' ] && [ ! -z "${HTTP_ENDPOINT_INVENTORY}" ]
then
  http_endpoint="${HTTP_ENDPOINT_INVENTORY}"
fi

if [ "$1" = '--host' ] && [ ! -z "${HTTP_ENDPOINT_HOST_VARS}" ]
then
  http_endpoint=$(printf '..%s..' "${HTTP_ENDPOINT_HOST_VARS}" "$2")
fi

if [ -z "${http_endpoint}" ]
then
  validation_error="Missing or empty HTTP_ENDPOINT_* variable for $1."
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
