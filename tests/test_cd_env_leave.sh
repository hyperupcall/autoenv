# shellcheck shell=sh

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a/b' 'a/bz'
echo 'echo zulu' > 'a/b/.env.leave'
echo 'echo yankee' > 'a/b/.autoenv.leave'

AUTOENV_ENABLE_LEAVE=1
AUTOENV_ASSUME_YES=1
cd 'a/b'
patterntest 'cd ../../a/bz' 'zulu'
cd '../b'
patterntest 'cd ../../a/bz' 'yankee$'
