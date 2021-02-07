@test "install sets up hook" {
      HOOK=".git/hooks/prepare-commit-msg"
      run commit-automator install .
      [ -f "${HOOK}" ]
}
