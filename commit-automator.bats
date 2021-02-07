@test "install sets up hook" {
      [ ! test -f .git/hooks/prepare-commit-msg ]
      run commit-automator install .
      [ "$status" -eq 0 ]
      [ test -f .git/hooks/prepare-commit-msg ]
}
