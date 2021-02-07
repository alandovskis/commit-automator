@test "install sets up hook" {
      HOOK=".git/hooks/prepare-commit-msg"
      run commit-automator install .
      [ "$status" -eq 0 ]
      [ test -f "${HOOK}" ]
}
