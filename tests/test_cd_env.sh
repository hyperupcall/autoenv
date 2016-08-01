. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare files/directories
mkdir -pv 'a/.env' 'b/.env'
echo 'echo b' > 'b/.env/.env'

# Test without a .env file
patterntest 'echo "Y" | cd a/.env' '^$'
# Test with a directory with .env file
patterntest 'echo "Y" | cd b/.env' '.*b$'
