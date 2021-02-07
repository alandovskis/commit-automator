@test "install sets up hook" {
      DIR="a"
      mkdir -p "${DIR}"
      HOOK=".git/hooks/prepare-commit-msg"

      run commit-automator install "${DIR}"

      [ -f "${DIR}/${HOOK}" ]
}
