# shellcheck shell=sh

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# .env might be a symlink
# .env might be a symlink to a parent directory
# .env might be a symlink to a child directory
# .env might be a symlink to a nonexistent file
# The current directory might be a symlink

# Structure:
# a
#  - b
#    - .env
#  - c
#    - .env -> ../b/.env
#  - d
#    - .env -> ../nonexistent
#  - e -> c
# b
#   - c
#     - .env -> ../.env
#   - .env
# c
#   - d
#     - .env
#   - .env -> e/.env


# Prepare files/directories
mkdir -pv 'a/b' 'a/c' 'a/d'
mkdir -pv 'b/c'
mkdir -pv 'c/d'
ln -s '../b/.env' 'a/c/.env'
ln -s '../nonexistent' 'a/d/.env'
ln -s '../.env' 'b/c/.env'
ln -s 'd/.env' 'c/.env'
ln -s 'c' 'a/e'
echo 'echo b' > 'a/b/.env'
echo 'echo b' > 'b/.env'
echo 'echo d' > 'c/d/.env'

# .env is a smylink
patterntest 'echo "Y" | cd a/c' '.*b$'
# .env is a symlink to a parent directory
patterntest 'yes "Y" | cd b/c' '.*b$'
# .env is a symlink to a child directory
patterntest 'yes "Y" | cd c' '.*d$'
# .env is a nonexistent symlink
patterntest 'echo "Y" | cd a/d' '^$'
# The current directory is a symlink
patterntest 'echo "Y" | cd a/e' '.*b$'
