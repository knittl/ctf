#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

git config --global advice.defaultBranchName false

rand_git_user() {
	git config user.name "$(random_name) $(random_name)"
	git config user.email "$(random_lower)@localhost"
}

rand_git_repo() { repo="${1:-"$(rand_mkdir)"}" && cd "$repo" && git init && rand_git_user; }
rand_word() { random_alnum "$(random_int 2 8)"; echo; }
rand_subject() { rand_repeat 2-8 rand_word | join_lines ' '; }

rand_repeat() {
	range="$1"; shift
	repeat "$(random_int "${range%-*}" "${range#*-}")" "$@";
}

commit() { : 'overwrite for specific task!'; }
commit_fake_token() { commit "$(current_fake_token)"; }
commit_token() { commit "$(current_token)"; }

next_task # 1 commit message
(
rand_git_repo
git commit --allow-empty -m "$(current_token)"
fake_commit() { git commit --allow-empty -m "$(current_fake_token)"; }
rand_repeat 16-32 fake_commit
task "The token is in the commit message of the first commit in repository $(bold "$repo")."
)

next_task # 2 unreachable commits
(
commit() { git commit-tree -m "$1" "$(git write-tree)"; }

rand_git_repo
rand_repeat 8-16 commit_fake_token
commit="$(commit_token)"
task "The token is in the commit message of commit $(bold "$commit") in repository $(bold "$repo")."
)

next_task # 3 branches
(
rand_git_repo

file="$(uniq_filename).txt"

commit() {
	echo "$1" > "$file"
	git add "$file"
	git commit -m "$(rand_subject)"
}

make_random_branch() {
	git checkout -qb "$(random_alnum)"
	rand_repeat 8-16 commit_fake_token
	git checkout -q -
}

commit_fake_token # initial commit

rand_repeat 4-8 make_random_branch

branch="$(random_alnum)"
git checkout -qb "$branch"
rand_repeat 8-16 commit_fake_token
commit_token

git checkout -q -

task "The token is in file $(bold "$file") in branch $(bold "$branch") in repository $(bold "$repo")."
)

next_task # 4 remotes
(

commit() {
	echo "$1" > "$file"
	git add "$file"
	git commit -m "$(rand_subject)"
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
	rand_git_repo "$origin"

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

cat <<-'EOF' >README
Read this file first, it contains important information

Configuration: Configure the current token in file `.env`
EOF
printf 'TOKEN=\n' >.env

git add README .env
git commit -m 'Initial commit'

printf 'TOKEN=%s\n' "$(current_token)" >.env
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

rand_stage_file() {
	file="$(uniq_filename)"
	current_fake_token > "$file"
	git add "$file"
}
rand_repeat 8-16 rand_stage_file
git commit -m 'Initial commit'

# TODO modify files
# TODO stage files
# TODO stage and modify files?
# TODO delete files
# TODO delete files from index only

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
	rand_git_repo "$origin"

	printf 'Working with remotes is easy\n' >README
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
	git checkout -qb tokenize
	current_token >token.txt
	git add token.txt
	git commit -m 'Add token'

	git bundle create "$bundlepath" --all
	)

task "Your peer pushed the token to a new branch in your shared remote of repository $(bold "$repo")."
)

next_task # 8 detecting changes
(
# TODO make more interesting, e.g. multiple commits
rand_git_repo

rand_repeat 32-64 current_fake_token > tokens.txt
git add tokens.txt
git commit -m 'Initial commit'

rand_repeat 32-64 current_fake_token > /tmp/tokens.txt
awk -v "line=$(random_int "$(wc -l < /tmp/tokens.txt)")" \
	-v "token=$(current_token)" \
	'1;NR==line{print token}' /tmp/tokens.txt > tokens.txt

git add tokens.txt
git commit -m 'Regenerate tokens'

branch="$(random_alnum)"
git branch "$branch"
cat /tmp/tokens.txt > tokens.txt
git add tokens.txt
git commit --amend --no-edit

task "The token does not exist in your current branch, but it's still available in branch $(bold "$branch") in repository $(bold "$repo")."
)

next_task # 9 create commits
(
commits="$(random_int 4 8)"
prepare_current_token "$(printf '%s\n' "$commits")"
task "Create a new Git repository with a branch that contains $(bold "$commits") commits.  Get the token by calling $(bold "$(print_check check-git count "$commits")") $(underlined path/to/repo) $(underlined branchname)"
)

next_task # 10 merging
(
rand_git_repo

commit() {
	file="$prefix.$1"; shift
	printf '%s\n' "$@" | tee "$file" >&3
	git add "$file"
	git commit -qm "$(rand_subject)"
}

commit_branch() {
	git checkout -qb "$(random_alnum)" HEAD^
	commit "$@"
}

prefix="$(random_alnum)"
commit txt 'Find the token' 3>/dev/null
commit txt 'Combine all branches' 3>/dev/null

branch="$(git branch --show-current)"
prefix="$(random_alnum)"
# TODO random number of branches (must work with print_check:
# for nr in $(seq "$(random_int 4 8)"); do
for nr in $(seq 4); do
	commit_branch "$nr" "$(rand_word)"
done 3>/tmp/expected
git checkout -q "$branch"

prepare_current_token "$(cat /tmp/expected)"
task "The token was split across multiple branches like a Horcrux.  Merge all branches of repository $(bold "$repo") and run $(bold "$(print_check cat "$prefix.1" "$prefix.2" "$prefix.3" "$prefix.4")") to reconstruct it."
)

next_task # 10 merging
(
rand_git_repo
prefix="$(random_alnum)"

commit() {
	file="$prefix.$1"; shift
	printf "$@" > "$file"
	git add "$file"
	git commit -m "$(rand_subject)"
}

commit_branch() {
	git checkout -qb "branch-$1" HEAD^
	commit "$@"
}

# TODO run checker script, not merge token
prepare_current_token
commit 00 'Find the token\n'
commit 00 'Find the token split across files in multiple branches\n'
branch="$(git branch --show-current)"
commit_branch 01 'The token is: '
commit_branch 02 '%s' "$course{"
commit_branch 03 '%s' "$exercise:"
commit_branch 04 '%s' "$student:"
commit_branch 05 '%s' "$nonce:"
commit_branch 06 '%s\n' "$mac}"
git checkout -q "$branch"

task "The token was split across multiple branches like a Horcrux.  Merge all branches of repository $(bold "$repo") to reconstruct it."
)

# TODO config?
# TODO merge?
# TODO reflog?
