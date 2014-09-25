# Hipchat, the ZSH plugin
# Author: Robert Krzyzanowski
# Dependencies: curl
# https://github.com/robertzk/hipchat.zsh

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

  local DEBUG=false
  while getopts "d:" OPTION
  do
    case $OPTION in
      d)
        local DEBUG=true
        shift 1
        ;;
    esac
  done
  
  if [[ $# -lt 2 ]]; then
    echo "Please provide at least two arguments: who to send to and the message." >&2
    echo ""
    hipchat_usage
    return
  fi

  if [[ $1 =~ '@' ]]; then 
    local hipchat_module='user'
    local hipchat_path='message'
  else
    local hipchat_module='room'
    local hipchat_path='notification'
  fi

  local url="http://api.hipchat.com/v2/$hipchat_module/$1/$hipchat_path?auth_token=$HIPCHAT_API_TOKEN" 
  local message="{\"message\": \"${@:2}\", \"message_format\": \"text\" }"
  
  if $DEBUG; then
    echo "URL=$url"
    echo "MESSAGE=$message"
  fi

  curl -H "Content-Type: application/json" --request POST $url --data $message
}

