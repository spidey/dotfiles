stty -ixon

[[ -z "$SSH_AUTH_SOCK" ]] && eval `ssh-agent -s` >/dev/null
trap 'test -n "$SSH_AUTH_SOCK" && eval `/usr/bin/ssh-agent -k`' 0

