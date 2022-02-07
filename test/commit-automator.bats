set -u

USAGE="Usage: commit-automator install|prepare|register"
CONFIG_BRANCHES="${HOME}/.config/commit-automator"
COMMIT_AUTOMATOR=$(realpath ./commit-automator)
ERROR_INVALID_VALUE=22

prepare_repo()
{
    local branch="${1}"

    REPO=$(mktemp -d)
    git -C "${REPO}" init >/dev/null

    #local file="test"
    #touch "${REPO}/${file}"
    #git -C "${REPO}" add "${file}"
    #git -C "${REPO}" commit -m "init"
    echo "${REPO}"
}

@test "show usage when no action passed" {
    run ./commit-automator
    [ "$status" -eq ${ERROR_INVALID_VALUE} ]
    [ "$output" = "${USAGE}" ]
}

@test "show usage when no valid action passed" {
    run ./commit-automator blah
    [ "$status" -eq ${ERROR_INVALID_VALUE} ]
    [ "$output" = "${USAGE}" ]
}

@test "install sets up hook if core.hookspath not set" {
    REPO=$(prepare_repo "main")

    pushd "${REPO}"
    ${COMMIT_AUTOMATOR} install "${REPO}"
    popd

    HOOK=".git/hooks/prepare-commit-msg"
    test -f "${REPO}/${HOOK}"

    rm -rf "${REPO}"
}

@test "install sets up hook if core.hookspath set" {
    REPO=$(prepare_repo "main")

    HOOKS="hooks"
    git -C "${REPO}" config core.hookspath "${HOOKS}"
    mkdir -p "${REPO}/${HOOKS}"

    pushd "${REPO}"
    ${COMMIT_AUTOMATOR} install "${REPO}"
    popd

    HOOK="${HOOKS}/prepare-commit-msg"
    test -f "${REPO}/${HOOK}"

    rm -rf "${REPO}"
}

@test "install without argument fails" {
    run ./commit-automator install
    [ "$status" -eq ${ERROR_INVALID_VALUE} ]
    [ "$output" = "${USAGE}" ]
}

@test "register sets up mapping between branch and issue w/o slash" {
    local branch="registered"
    local issue="AN-1"
    prepare_repo "${branch}"

    cd "${REPO}"
    "${COMMIT_AUTOMATOR}" register "${issue}"

    branch_file="${CONFIG_BRANCHES}/branches/${branch}"
    test -f "${branch_file}"
    local actual_issue=$(cat ${branch_file} | tr -d '\n')
    [ x"${actual_issue}"x == x"${issue}"x ]

    rm -rf "${CONFIG_BRANCHES}"
}

@test "register sets up mapping between branch and issue with slash" {
    local branch="build/registered"
    local issue="AN-1"
    prepare_repo "${branch}"

    cd "${REPO}"
    "${COMMIT_AUTOMATOR}" register "${issue}"

    branch_file="${CONFIG_BRANCHES}/branches/${branch}"
    test -f "${branch_file}"
    local actual_issue=$(cat ${branch_file} | tr -d '\n')
    [ x"${actual_issue}"x == x"${issue}"x ]

    rm -rf "${CONFIG_BRANCHES}"
}

@test "register without issue fails" {
    run ./commit-automator register
    [ "$status" -eq ${ERROR_INVALID_VALUE} ]
    [ "$output" = "${USAGE}" ]
}

@test "prepare formats message" {
    local branch="test"
    local issue="AN-1"

    prepare_repo "${branch}"
    local commit_file=$(mktemp)

    cd "${REPO}"
    "${COMMIT_AUTOMATOR}" register "${issue}"
    "${COMMIT_AUTOMATOR}" prepare "${commit_file}"

    local result=$(tail -n 1 "${commit_file}")
    [ "${result}" == "Issue: ${issue}" ]
}

@test "prepare missing file show usage" {
    run ./commit-automator prepare
    [ "$status" -eq ${ERROR_INVALID_VALUE} ]
    [ "$output" = "${USAGE}" ]
}
