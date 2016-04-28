#! /bin/bash

tmux -u new-session -d -s dev -n ide
tmux split-window -v -p 10 -t dev
tmux select-pane -t 1
tmux split-window -h -p 30 -t dev
tmux new-window -n shell
tmux select-window -t dev:1
tmux select-pane -t 1
tmux -2 attach-session -t dev
