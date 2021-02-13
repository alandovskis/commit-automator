EINVAL=22
USAGE="Usage: commit-automator install|prepare|register"

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

	BRANCH_FILE="${HOME}/.config/commit-automator/branches/${BRANCH}"
	test -f "${BRANCH_FILE}"
	local issue=$(cat "${BRANCH_FILE} | tr -d '\n'")
	[ "${result}" == "${issue}" ]
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
	local commit_file=$(mktemp)

	./commit-automator register "${branch}" "${issue}"
	./commit-automator prepare "${commit_file}" "${branch}"

	local result=$(tail -n 1 "${commit_file}")
	[ "${result}" == "Issue: ${issue}" ]
}

@test "prepare missing file show usage" {
	local output=$(./commit-automator prepare)
	[ "${output}" == "${USAGE}" ]
}
