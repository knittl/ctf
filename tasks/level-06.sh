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

git config --global advice.defaultBranchName false

next_task # 1 commit message
# (
# rand_git_repo
# rand_git_user
# git commit --allow-empty -m "$(current_token)"
# repeat "$(random_int 16 32)" git commit --allow-empty -m "$(current_fake_token)"
# task "The token is in the the commit message of the first commit in repository $(bold "$repo")."
# )

next_task # 2 unreachable commits
# (

# commit_token() { git commit-tree -m "$(current_token)" "$(git write-tree)"; }
# commit_fake_token() { git commit-tree -m "$(current_fake_token)" "$(git write-tree)"; }

# rand_git_repo
# rand_git_user
# commit="$(commit_token)"
# repeat "$(random_int 8 16)" commit_fake_token
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
# 	git commit -m "$(repeat 5 random_word | join_lines ' ')"
# }

# commit_fake_token() { commit "$(current_fake_token)"; }
# commit_token() { commit "$(current_token)"; }

# make_random_branch() {
# 	git checkout -qb "$(random_alnum)"
# 	repeat "$(random_int 8 16)" commit_fake_token
# 	git checkout -q -
# }

# commit_fake_token # initial commit

# repeat "$(random_int 4 8)" make_random_branch

# branch="$(random_alnum)"
# git checkout -qb "$branch"
# repeat "$(random_int 8 16)" commit_fake_token
# commit_token

# git checkout -q -

# task "The token is in file $(bold "$file") in branch $(bold "$branch") in repository $(bold "$repo")."
# )

next_task # 4 remotes
(

# TODO actually different remotes

commit() {
	echo "$1" > "$file"
	git add "$file"
	git commit -m "$(repeat 5 random_word | join_lines ' ')"
}

commit_fake_token() { commit "$(current_fake_token)"; }
commit_token() { commit "$(current_token)"; }

make_random_branch() {
	git checkout -qb "$(random_alnum)"
	repeat "$(random_int 8 16)" commit_fake_token
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

	repeat "$(random_int 4 8)" make_random_branch

	git checkout -qb "$branch"
	repeat "$(random_int 8 16)" commit_fake_token
	commit_token

	git checkout -q -
)

add_remote() {
	origin="$(mktemp -d)"
	make_remote "$origin"
	git remote add "${1:-$(random_alnum)}" "file://$origin";
}

rand_git_repo
repeat "$(random_int 2 4)" add_remote
remote="$(random_alnum)"
add_remote "$remote"
git fetch -q --all

task "The token is in file $(bold "$file") in branch $(bold "$branch") of remote $(bold "$remote") in repository $(bold "$repo")."
)

# TODO create N commits on branch XY
# TODO diff?
# TODO (un)staged/untracked files?
# TODO config?
# TODO merge?
