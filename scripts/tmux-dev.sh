#!/bin/zsh
t="temp"

if [ -z "$1" ];
then
  set -- $t
fi
if [ -z "$2" ];
then
  set -- "$1" "$PWD"
fi

# Creates session, and names window DEV
tmux new-session -d -s $1 -c $2
tmux rename-window 'DEV'
tmux split-window -v -p 10 -c $2
tmux select-pane -t 1
tmux split-window -h -p 30 -c $2

# Creates second window named SERVER
tmux new-window -a -d -n 'SERVER' -c $2
tmux select-pane -t 1

# Attaches to tmux session
tmux attach-session -t $1

# tmux -u new-session -d -s dev -n ide
# tmux split-window -v -p 10 -t dev
# tmux select-pane -t 1
# tmux split-window -h -p 30 -t dev
# tmux new-window -n shell
# tmux select-window -t dev:1
# tmux select-pane -t 1
# tmux -2 attach-session -t dev
