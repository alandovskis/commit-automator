set -u

EINVAL=22
USAGE="Usage: commit-automator install|prepare|register"
CONFIG_BRANCHES="${HOME}/.config/commit-automator"

prepare_repo()
{
	local branch="${1}"

	REPO=$(mktemp -d)
	git -C "${REPO}" init >/dev/null
	git -C "${REPO}" switch -c "${branch}"

	local file="test"
	touch "${REPO}/${file}"
	git -C "${REPO}" add "${file}"
	git -C "${REPO}" commit -m "init"
	echo "${REPO}"
}

@test "show usage when no action passed" {
	local output=$(./commit-automator)

	[ "${output}" == "${USAGE}" ]
}

@test "show usage when no valid action passed" {
	local output=$(./commit-automator blah)

	[ "${output}" == "${USAGE}" ]
}

@test "install sets up hook" {
	REPO="test-repo"
	git config --global init.defaultBranch main
	git init "${REPO}"

	./commit-automator install "${REPO}"

	HOOK=".git/hooks/prepare-commit-msg"
	test -f "${REPO}/${HOOK}"

	rm -rf "${REPO}"
}

@test "install without argument fails" {
	local output=$(./commit-automator install)

	[ "${output}" == "${USAGE}" ]
}

@test "register sets up mapping between branch and issue" {
	local branch="registered"
	local issue="AN-1"
	prepare_repo "${branch}"

	local root=$(pwd)
	local commit_automator="${root}/commit-automator"
    cd "${REPO}"
	"${commit_automator}" register "${issue}"

	branch_file="${CONFIG_BRANCHES}/branches/${branch}"
	test -f "${branch_file}"
	local actual_issue=$(cat ${branch_file} | tr -d '\n')
	[ x"${actual_issue}"x == x"${issue}"x ]

    rm -rf "${CONFIG_BRANCHES}"
}

@test "register without issue fails" {
	local output=$(./commit-automator register)

	[ "${output}" == "${USAGE}" ]
}

@test "prepare formats message" {
	local branch="test"
	local issue="AN-1"

	prepare_repo "${branch}"
	local commit_file=$(mktemp)

	local root=$(pwd)
	local commit_automator="${root}/commit-automator"
	cd "${REPO}"
	"${commit_automator}" register "${issue}"
	"${commit_automator}" prepare "${commit_file}"

	local result=$(tail -n 1 "${commit_file}")
	[ "${result}" == "Issue: ${issue}" ]
}

@test "prepare missing file show usage" {
	local output=$(./commit-automator prepare)
	[ "${output}" == "${USAGE}" ]
}
