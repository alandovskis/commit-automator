USAGE="Usage: commit-automator install"

@test "show usage when no action passed" {
      local output=$(./commit-automator)

      [ "${output}" == "${USAGE}" ]
}

@test "install sets up hook" {
      REPO="test-repo"
      rm -rf "${REPO}"
      git config --global init.defaultBranch main
      git init "${REPO}"

      ./commit-automator install "${REPO}"

      HOOK=".git/hooks/prepare-commit-msg"
      test -f "${REPO}/${HOOK}"
}
