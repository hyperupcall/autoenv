. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

mkdir a
echo 'echo a' > a/.env

patterntest 'set -C; echo "Y" | cd a' '.*a$'

