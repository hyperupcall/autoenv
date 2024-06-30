# shellcheck shell=sh

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a/b' 'a/bz'
echo 'echo zulu' > 'a/b/.env.leave'

AUTOENV_ENABLE_LEAVE=1
cd 'a/b'
patterntest 'echo "Y" | cd ../../a/bz' 'zulu$'
