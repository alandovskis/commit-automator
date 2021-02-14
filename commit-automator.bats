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

@test "register setups mapping between branch and issue" {
	BRANCH="test"
	ISSUE="AN-1"

	./commit-automator register "${BRANCH}" "${ISSUE}"

	BRANCH_FILE="${CONFIG_BRANCHES}/branches/${BRANCH}"
	test -f "${BRANCH_FILE}"
	local issue=$(cat ${BRANCH_FILE} | tr -d '\n')
	[ x"${issue}"x == x"${ISSUE}"x ]

    rm -rf "${CONFIG_BRANCHES}"
}

@test "register without branch and issue fails" {
	local output=$(./commit-automator register)

	[ "${output}" == "${USAGE}" ]
}

@test "register without issue fails" {
	local output=$(./commit-automator register test)

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
	"${commit_automator}" register "${branch}" "${issue}"
	"${commit_automator}" prepare "${commit_file}"

	local result=$(tail -n 1 "${commit_file}")
	[ "${result}" == "Issue: ${issue}" ]
}

@test "prepare missing file show usage" {
	local output=$(./commit-automator prepare)
	[ "${output}" == "${USAGE}" ]
}
