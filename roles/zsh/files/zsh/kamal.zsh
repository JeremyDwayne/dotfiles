# Quiet Kamal down to progress lines and errors.
#
# Two independent knobs are needed, because neither one covers the other:
#
#   -q                       Silences SSHKit's "INFO [abc123] Running docker ... on host"
#                            echo. It does NOT touch the build: kamal/cli/build.rb wraps
#                            build and push in with_verbosity(:debug) unconditionally,
#                            which overrides -q.
#   BUILDKIT_PROGRESS=quiet  Silences the buildx output wall. Kamal runs buildx through a
#                            pipe rather than a tty, so buildx's `auto` mode degrades to
#                            `plain` and prints every layer line instead of a progress bar.
#
# What survives: Kamal's own step lines ("Build and push app image...") use Thor's `say`,
# which is gated on --raw rather than verbosity, and build failures still print the full
# Dockerfile context and ERROR line.
#
# -q must follow the subcommand -- `kamal -q deploy` prints help instead of deploying --
# so this appends rather than prepends, and an explicit -v opts back into full output.
kamal() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      -v | --verbose)
        command kamal "$@"
        return
        ;;
    esac
  done

  BUILDKIT_PROGRESS=quiet command kamal "$@" -q
}
