@test "install sets up hook" {
      REPO="test-repo"
      rm -rf "${REPO}"
      git config --global init.defaultBranch main
      git init "${REPO}"

      run ./commit-automator install "${REPO}"

      [ "$status" -eq 0 ]
      test -f "${REPO}/git/hooks/prepare-commit-msg"
}
