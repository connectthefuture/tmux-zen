# Initialize the current fish session and connect to the tmux session.
# If we're not running in an interactive terminal, do nothing.
if begin; not isatty; or not status --is-interactive; end
  exit
end

# If we're running in a superuser shell, do nothing.
if test $USER = root
  exit
end

# Connect to the TMUX session if it exists, or create it if it doesn't.
if not set -q TMUX
  set -l tmux_bin (config tmux-zen --get tmux-bin --default tmux)
  set -l session_name (config tmux-zen --get session-name --default local)

  if eval "$tmux_bin has-session -t $session_name"
    exec env -- $tmux_bin new-session -t $session_name \; set destroy-unattached on
  else
    exec env -- $tmux_bin new-session -s $session_name
  end
end

# Initialize the session if we didn't already.
if not set -q ZEN_SESSION_INITIALIZED
  # Set a global variable to make sure we only get called once per session.
  set -g ZEN_SESSION_INITIALIZED true
  zen tmux setenv -g ZEN_SESSION_INITIALIZED true

  # Emit the init event. This by default triggers the default init code, but
  # can also be captured by the user.
  emit zen.init
end

function zen.init --on-event zen.init
  config tmux-zen --query events.init
    and eval (config tmux-zen --get events.init)
end
