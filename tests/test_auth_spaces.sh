AUTOENV_AUTH_FILE="${AUTOENV_AUTH_FILE} with spaces"

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a/b' 'c/d'
echo 'echo a' > "a/.env"
echo 'echo b' > "a/b/.env"
echo 'echo c' > "c/.env"

# Test simple cd
patterntest 'echo "Y" | cd a' '.*a$'
# Test cd to subdirectory
patterntest 'echo "Y" | cd a/b' '.*a
b$'
# Test cd with env in parent directory
patterntest 'echo "Y" | cd c/d' '.*c$'
# Check cd into nonexistent directory
echo "Y" | cd d && exit 1 || :
