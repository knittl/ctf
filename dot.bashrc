show-motd() { cat ~/README; }

show-tasks() (
  while [ "$PWD" != / ] && ! [ -f README ]; do cd ..; done
  cat README 2>/dev/null || echo 'No tasks available, are you in the correct directory?'
)

show-motd
