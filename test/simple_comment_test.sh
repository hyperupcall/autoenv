## setup
source activate.sh

test_dir="${TMPDIR:=/tmp}/_autoenv_$$"

mkdir -p "$test_dir/a/b"
echo "echo -a/b-" > "$test_dir/a/b/.env"
echo "echo -a-" > "$test_dir/a/.env"
mkdir -p "$test_dir/c/d"
echo "echo -c/d-" > "$test_dir/c/d/.env"

cd $test_dir

## test
( cd a   ) # match=/-a-/ ; match!=/-a/b-/ ; status=0
( cd a/b ) # match=/-a-\n-a/b-/ ; status=0
( cd c   ) # match=/$^/ ; status=0
( cd c/d ) # match!=/-c-/ ; match=/-c/d-/ ; status=0
( cd e   ) # match!=/^$/ ; status!=0

## teardown
rm -rf "$test_dir"
