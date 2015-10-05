# Hipchat, the ZSH plugin
# Author: Robert Krzyzanowski
# Dependencies: curl
# https://github.com/robertzk/hipchat.zsh

__hipchat_urlencode() { # http://stackoverflow.com/a/10797966/2540303
  local data
  if [[ $# != 1 ]]; then
      echo "Usage: $0 string-to-urlencode"
      return 1
  fi
  data="$(curl -s -o /dev/null -w %{url_effective} --get --data-urlencode "$1" "")"
  if [[ $? != 3 ]]; then
      echo "Unexpected error" 1>&2
      return 2
  fi
  echo "${data##/?}"
  return 0
}

hipchat_usage() {
  echo "Usage: hipchat [-d] <email or room> <message>"
  echo "-d: debug (more verbose output)"
}

hipchat() { # Arg 1: Username to send, rest: message to send
  if [[ -z $HIPCHAT_API_TOKEN ]]; then
    echo "Please set your HIPCHAT_API_TOKEN environment variable." >&2
    echo ""
    hipchat_usage
    return
  fi

  # Ensure curl is present
  command -v curl >/dev/null 2>&1 || { echo "Please install curl." >&2; exit 1; }

  local OPTIND opt d # http://stackoverflow.com/questions/16654607/using-getopts-inside-a-bash-function
  local DEBUG=false
  while getopts ":d" opt; do 
    case "${opt}" in
      d)
        local DEBUG=true
        ;;
      \?)
        hipchat_usage
        return
        ;;
    esac
  done
  shift $((OPTIND-1))
  
  if [[ $# -lt 2 ]]; then
    echo "Please provide at least two arguments: who to send to and the message." >&2
    echo ""
    hipchat_usage
    return
  fi

  if [[ $1 =~ '@' ]]; then 
    local hipchat_module='user'
    local hipchat_path='message'

    local url="http://api.hipchat.com/v2/$hipchat_module/$1/$hipchat_path?auth_token=$HIPCHAT_API_TOKEN" 
    local message="{\"message\": \"${@:2}\", \"message_format\": \"text\" }"
    
    if $DEBUG; then
      echo "URL=$url"
      echo "MESSAGE=$message"
    fi
    curl -H "Content-Type: application/json" --request POST $url --data "$message"
  else
    local from=$HIPCHAT_FROM
    if [[ -z $from ]]; then
      local from=`whoami`
    fi
    local token=$HIPCHAT_ROOM_API_TOKEN
    if [[ -z $from ]]; then
      local token=$HIPCHAT_API_TOKEN
    fi

    local url="http://api.hipchat.com/v1/rooms/message?format=json&auth_token=$token&message_format=text"

    local msg="$(__hipchat_urlencode "${@:2}")"
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to URL encode hipchat message"
      return 1
    fi

    local room="$(__hipchat_urlencode "$1")"
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to URL encode hipchat room"
      return 1
    fi

    local fromenc="$(__hipchat_urlencode "$from")"
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to URL encode hipchat sender"
      return 1
    fi

    local message="message=$msg&room_id=$room&from=$fromenc"

    if $DEBUG; then
      echo "Using:"
      echo ""
      echo "URL=$url"
      echo "MESSAGE=$message"
      echo ""
      echo "Executing: "
      echo ""
      echo "curl --request POST $url --data $message"
    fi
    curl --request POST $url --data $message
  fi
}

