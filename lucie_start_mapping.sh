#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
echo "Usage: lucie_start_mapping.sh name_of_topological_map path_to_database";
exit;
fi

if [ ! -d $2 ]; then
# Make database directory for user
mkdir -p $2;
fi

SESSION=$USER
MAPPING_HOME=$HOME/TopologicalMapMaking
ROBOT_FILES=$MAPPING_HOME/robot_files
DATABASE=$2

tmux -2 new-session -d -s $SESSION
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'roscore'
tmux new-window -t $SESSION:1 -n 'mongo'
tmux new-window -t $SESSION:2 -n 'robot_bringup'
tmux new-window -t $SESSION:3 -n 'cameras'
tmux new-window -t $SESSION:4 -n 'Run Mapping'
tmux new-window -t $SESSION:5 -n 'Rviz'
tmux new-window -t $SESSION:6 -n 'Saving Map'
tmux new-window -t $SESSION:7 -n 'Tmap DB'

tmux select-window -t $SESSION:0
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "roscore" C-m
tmux resize-pane -U 30
tmux select-pane -t 1
tmux send-keys "htop" C-m

tmux select-window -t $SESSION:1
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "roslaunch mongodb_store mongodb_store.launch db_path:=$DATABASE port:=62345"
tmux resize-pane -D 30
tmux select-pane -t 1
tmux send-keys "robomongo"
tmux select-pane -t 0

tmux select-window -t $SESSION:2
tmux send-keys "roslaunch strands_bringup strands_robot.launch machine:=localhost user:=$USER with_mux:=False js:=/dev/input/js0 laser:=/dev/ttyUSB0 scitos_config:=/opt/ros/indigo/share/scitos_mira/resources/SCITOSDriver.xml"

tmux select-window -t $SESSION:3
tmux send-keys "roslaunch strands_bringup strands_cameras.launch machine:=localhost user:=$USER head_camera:=True head_ip:=luciel head_user:=strands chest_camera:=True chest_ip:=localhost chest_user:=$USER"

tmux select-window -t $SESSION:4
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "rosrun gmapping slam_gmapping"
# To charging station, reset odemetry (on-board menu) [B] to mark node, [A] to save at end
# tmux send-keys "roslaunch topological_utils mapping.launch met_map:='$1_met' top_map:='$1'"
tmux resize-pane -U 30
tmux select-pane -t 1
# Press [LB] + [A] on Joypad when running
tmux send-keys "rosrun topological_utils joy_add_waypoint.py $ROBOT_FILES/$1_waypoints.csv"
tmux select-pane -t 0

tmux select-window -t $SESSION:5
tmux send-keys "rosrun rviz rviz -d $MAPPING_HOME/tsc_config.rviz"


tmux select-window -t $SESSION:6
tmux split-window -v
tmux select-pane -t 0
#tmux send-keys "rosrun map_server map_saver -f $ROBOT_FILES/$1_raw.yaml"
tmux send-keys "rosrun map_server map_saver $ROBOT_FILES/$1_raw.yaml"
tmux resize-pane -D 30
tmux select-pane -t 1
tmux send-keys "rosrun map_server crop_map $ROBOT_FILES/$1_raw.yaml $ROBOT_FILES/$1.yaml"
tmux select-pane -t 0

tmux select-window -t $SESSION:7
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "rosrun topological_utils tmap_from_waypoints.py $ROBOT_FILES/$1_waypoints.csv $ROBOT_FILES/$1.tmap"
tmux resize-pane -D 30
tmux select-pane -t 1
tmux send-keys "rosrun topological_utils insert_map.py $ROBOT_FILES/$1.tmap $1 $1_met"
tmux select-pane -t 0



# Set default window
tmux select-window -t $SESSION:0

# Attach to session
tmux -2 attach-session -t $SESSION

tmux setw -g mode-mouse on
