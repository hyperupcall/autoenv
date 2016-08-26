. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a/b' 'c/d'
echo 'echo a' > "a/.env"
echo 'echo b' > "a/b/.env"
echo 'echo c' > "c/.env"

# Test simple cd
patterntest 'echo "Y" | cd a/' '.*a$'
# Test absolute cd
patterntest "echo "Y" | cd /${PWD}/a/" '.*a$'
# Test cd to subdirectory
( echo "Y" | cd a/b )
patterntest 'echo "Y" | cd a//b/' '.*a
b$'
# Test cd with env in parent directory
patterntest 'echo "Y" | cd c//d/' '.*c$'
# Check cd into nonexistent directory
echo "Y" | cd d// && exit 1 || :
