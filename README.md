# Topological Map Maker
A new topological map can be created alongside a new metric map using the tmux script "lucie_start_mapping.sh" and following the instructions below. The program is run as ```./lucie_start_mapping.sh name_of_map path_to_database``` where ```name_of_map``` is what the map file will be called (```{name_of_map}.tmap```) and the name of the WayPoints in the database. If the database folder does not yet exist then the script will create it for you.

## Tmux useful keys
- ```ctrl & B then 0``` change to session 0. Replace 0 with any number up to 7 to change between the sessions.
- ```ctrl & B then →``` change between panes using the arrow keys.
- ```ctrl & B then D``` exit the tmux session. Note the session is still running and needs to be killed. Run ./kill_tmux.sh to really exit.

## Sessions in Tmux
There are 7 sessions running in tmux, which are designed for the different tasks required in building a topological map.

### Session 0
This runs roscore and htop to monitor processes. Both of these scripts run automatically so if there are no errors then change to session 1.

### Session 1
The main pane runs mongodb, which will create your database at the path given and allow the WayPoints to be inserted once they have been created. Run it and leave it until you've finished.

The second pane contains the command to run robomongo, which allows you to view the database in more detail. It is not required.

### Session 2
This is robot_bringup and provides the lasers and joystick.

### Session 3
This is to enable the cameras. The script expects the head camera to be in luciel and the chest camera to be in lucie.

### Session 4
The first pane runs slam gmapping, which scans the environment to build a metric map. It is this that will provide the data for map.pgm and map.yaml files later.

The second pane script is to get WayPoints simultaneously while mapping via the joypad. Run session 5 before beginning mapping.

### Session 5
This is to run Rviz with some useful options open. It will allow you to see the map being generated.

### Making the map.
LUCIE can be driven by holding [LB] and using the left joystick. If the bumper is hit the motors will stop. Make sure the bumper isn't pressed and hit [start].

WayPoints are set by pressing [LB] & [A], "JOY" will be printed to stdout in Session 4, right pane.

### Session 6
This is part of saving the map. The top will save the map, creating the ```{name_of_map}_raw.pgm``` and ```{name_of_map}_raw.yaml``` files. The bottom will crop the map to create ```{name_of_map}.pgm, {name_of_map}.yaml```.

To get the WayPoints.csv file, exit the process running in session 4 on the right hand side, which is the joy_map_waypoints.py program, by pressing ```ctrl & C```. This will then save the ```{name_of_map}_waypoints.csv``` file as it exits.

### Session 7
The first pane creates a tmap file from the others already made. The second pane then inserts this data into the database.

### Wrapping up
The map files have been created in TopologicalMapMaker/robot_files/ and can be moved to your prefered directory. The WayPoints have been inserted into the given database and called "```name_of_map```". The running processes can now be killed and tmux can be killed using the provided script: kill_tmux.sh.

It may be beneficial to clean the map image file using gimp before using it. Node and edges can be edited in Rviz by checking the 'UpdateNode' and 'EdgeUpdate' boxes. Under 'Update Topic' subscribe to '/topological_map_add_rm_node/update' and 'topological_map_edges/update' respectively.

![adding_edges](assets/adding_edges.png)
