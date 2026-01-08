#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

rand_git_user() {
	git config user.name "$(random_name) $(random_name)"
	git config user.email "$(random_lower)@localhost"
}

rand_git_repo() { repo="$(rand_mkdir)" && cd "$repo" && git init; }
random_word() { random_alnum "$(random_int 2 8)"; echo; }

rand_repeat() {
	range="$1"; shift
	repeat "$(random_int "${range%-*}" "${range#*-}")" "$@";
}

commit() { : 'overwrite for specific task!'; }
commit_fake_token() { commit "$(current_fake_token)"; }
commit_token() { commit "$(current_token)"; }

git config --global advice.defaultBranchName false

next_task # 1 commit message
# (
# rand_git_repo
# rand_git_user
# git commit --allow-empty -m "$(current_token)"
# rand_repeat 16-32 git commit --allow-empty -m "$(current_fake_token)"
# task "The token is in the the commit message of the first commit in repository $(bold "$repo")."
# )

next_task # 2 unreachable commits
# (

# commit() { git commit-tree -m "$1" "$(git write-tree)"; }

# rand_git_repo
# rand_git_user
# commit="$(commit_token)"
# rand_repeat 8-16 commit_fake_token
# task "The token is in the the commit message of commit $(bold "$commit") in repository $(bold "$repo")."
# )

next_task # 3 branches
# (
# rand_git_repo
# rand_git_user

# file="$(uniq_filename).txt"

# commit() {
# 	echo "$1" > "$file"
# 	git add "$file"
# 	git commit -m "$(rand_repeat 2-8 random_word | join_lines ' ')"
# }

# make_random_branch() {
# 	git checkout -qb "$(random_alnum)"
# 	rand_repeat 8-16 commit_fake_token
# 	git checkout -q -
# }

# commit_fake_token # initial commit

# rand_repeat 4-8 make_random_branch

# branch="$(random_alnum)"
# git checkout -qb "$branch"
# rand_repeat 8-16 commit_fake_token
# commit_token

# git checkout -q -

# task "The token is in file $(bold "$file") in branch $(bold "$branch") in repository $(bold "$repo")."
# )

next_task # 4 remotes
(

commit() {
	echo "$1" > "$file"
	git add "$file"
	git commit -m "$(rand_repeat 2-8 random_word | join_lines ' ')"
}

make_random_branch() {
	git checkout -qb "$(random_alnum)"
	rand_repeat 8-16 commit_fake_token
	git checkout -q -
}

branch="$(random_alnum)"
file="$(uniq_filename).txt"

make_remote() (
	origin="$1"
	cd "$origin"
	git init
	rand_git_user

	commit_fake_token # initial commit

	rand_repeat 2-4 make_random_branch

	git checkout -qb "$branch"
	rand_repeat 4-8 commit_fake_token
	commit_token

	git checkout -q -
)

add_remote() {
	origin="$(mktemp -d)"
	make_remote "$origin"
	git remote add "${1:-$(random_alnum)}" "file://$origin";
}

rand_git_repo
rand_repeat 2-4 add_remote
remote="$(random_alnum)"
add_remote "$remote"
git fetch -q --all

task "The token is in file $(bold "$file") in branch $(bold "$branch") of remote $(bold "$remote") in repository $(bold "$repo")."
)

next_task # 5 stash, conflicts
(
rand_git_repo
rand_git_user

cat <<-'EOF' >README
Read this file first, it contains important information

Configuration: Configure the current token in file `.env`
EOF
cat <<-EOF >.env
TOKEN=
EOF

git add README .env
git commit -m 'Initial commit'

cat <<-EOF >.env
TOKEN=$(current_token)
EOF
git stash push -m 'Stash token for bugfix'

cat <<-EOF >.env
# replace with your real token:
TOKEN=$(current_fake_token)
EOF
cat <<-EOF >>README

IMPORTANT: Make sure to NEVER commit the token!
EOF
git add README .env
git commit -m 'Explain token handling'

task "You needed to implement an urgent bugfix.  The token is stashed away safely in repository $(bold "$repo")."
)

next_task # 6 tracked files
(
rand_git_repo
rand_git_user

rand_stage_file() {
	file="$(uniq_filename)"
	current_fake_token > "$file"
	git add "$file"
}
rand_repeat 8-16 rand_stage_file
git commit -m 'Initial commit'

current_token > "$(uniq_filename)"
task "Don't lose important work.  Currently, it's the only untracked file in repository $(bold "$repo")."
)

next_task # 7 remotes
(
origin="$(mktemp -d)"
repo="$(rand_mkdir)"
bundle=".$repo.bundle"
bundlepath="$PWD/$bundle"

	(
	cd "$origin"
	git init
	rand_git_user

	cat <<-EOF >README
	Working with remotes is easy
	EOF
	git add README
	git commit -m 'Initial commit'

	git bundle create "$bundlepath" --all
	)

git clone -q "$bundle" "$repo"
cd "$repo"
git remote set-url origin "../$bundle"
rand_git_user

	(
	cd "$origin"
	current_token >token.txt
	git add token.txt
	git checkout -qb tokenize
	git commit -m 'Add token'

	git bundle create "$bundlepath" --all
	)

task "Your peer pushed the token to a new branch in your shared remote of repository $(bold "$repo")."
)

next_task # 8 detecting changes
(
# TODO make more interesting, e.g. multiple commits
rand_git_repo
rand_git_user

rand_repeat 32-64 current_fake_token > tokens.txt
git add tokens.txt
git commit -m 'Initial commit'

rand_repeat 32-64 current_fake_token > /tmp/tokens.txt
awk -v "line=$(random_int "$(wc -l < tokens.txt)")" \
	-v "token=$(current_token)" \
	'1;NR==line{print token}' /tmp/tokens.txt > tokens.txt

git add tokens.txt
git commit -m 'Regenerate tokens'

branch="$(random_alnum)"
git branch "$branch"
cat /tmp/tokens.txt > tokens.txt
git add tokens.txt
git commit -CHEAD --amend

task "The token does not exist in your current branch, but it's still available in branch $(bold "$branch") in repository $(bold "$repo")."
)

next_task # 9 create commits
(
commits="$(random_int 4 8)"
prepare_current_token "$(printf '%s\n' "$commits")"
task "Create a new Git repository with a branch that contains $(bold "$commits") commits.  Get the token by calling $(bold "$(print_check check-git count "$commits")") $(underlined path/to/repo) $(underlined branchname)"
)

# TODO create N commits on branch XY
# TODO config?
# TODO merge?
# TODO reflog?
