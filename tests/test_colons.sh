. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a:a/b:b' 'c:c/d:d'
echo 'echo a' > "a:a/.env"
echo 'echo b' > "a:a/b:b/.env"
echo 'echo c' > "c:c/.env"

# Test simple cd
patterntest 'echo "Y" | cd a:a' '.*a$'
# Test cd to subdirectory
patterntest 'echo "Y" | cd a:a/b:b' '.*a'$'\n''b$'
# Test cd with env in parent directory
patterntest 'echo "Y" | cd c:c/d:d' '.*c$'
# Check cd into nonexistent directory
echo "Y" | cd 'd:d' && exit 1 || :
