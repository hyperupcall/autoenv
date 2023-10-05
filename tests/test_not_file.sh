# shellcheck shell=sh

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

#####
# Tests what happens when .env is not a file.
#####

# Prepare files/directories
mkdir -pv 'a/.env' 'b'
mkfifo 'b/.env'

# .env is a directory
patterntest 'echo "Y" | cd a' '^$'
# .env is a fifo
patterntest 'echo "Y" | cd b' '^$'
