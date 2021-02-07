@test "install sets up hook" {
      REPO="test-repo"
      rm -rf "${REPO}"
      git config --global init.defaultBranch main
      git init "${REPO}"

      run ./commit-automator install "${REPO}"

      HOOK=".git/hooks/prepare-commit-msg"
      test -f "${REPO}/${HOOK}"
}
