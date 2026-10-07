# 6-DOF Robot Arm Simulation (ROS2 + Gazebo)

A 6 degree-of-freedom robotic arm, modeled from scratch and simulated with physics-accurate gravity, torque, and momentum using ROS2 and Gazebo.

[Demo]

<img width="970" height="864" alt="gazebo-ezgif com-gif-maker" src="https://github.com/user-attachments/assets/5c1df02c-f3e9-4248-9488-d7c9da0b4d00" />


## Overview

This project models a 6-DOF robotic arm in URDF/xacro, connects it to ROS2's control framework (`ros2_control`), and simulates it in Gazebo with real physics. A trajectory controller drives all 6 joints through commanded poses, with joint dynamics (damping, torque limits) tuned to produce smooth, stable motion instead of oscillation or gravity-induced collapse.

Built by Nandana Narendra and Giri Pranesh.

## Stack

- **ROS2 Jazzy** — robot middleware / control framework
- **Gazebo Harmonic** — physics simulation
- **ros2_control** / **gz_ros2_control** — hardware abstraction and joint control
- **xacro/URDF** — robot structure definition
- **RViz2** — visualization
- Running on **WSL2 (Ubuntu 24.04)**

## Architecture

```
URDF/xacro (robot structure: links, joints, mass, inertia)
        │
        ▼
ros2_control tag (defines command/state interfaces per joint)
        │
        ▼
gz_ros2_control plugin (bridges ROS2 control to Gazebo physics)
        │
        ▼
joint_trajectory_controller (accepts waypoint commands over ROS2 topics)
        │
        ▼
Gazebo physics simulation (gravity, torque, collision, momentum)
```

## Repository structure

```
ros2-6dof-robot-arm/
├── src/robot_arm_description/
│   ├── urdf/              # Robot model (links, joints, ros2_control)
│   ├── launch/             # Launch files (RViz display + Gazebo sim)
│   ├── config/              # Controller configuration (controllers.yaml)
│   └── rviz/               # Saved RViz view configs
├── demo_sweep.sh          # One-command demo: dramatic sweep motion
└── README.md
```

## Setup

Requires ROS2 Jazzy and Gazebo Harmonic installed.

```bash
sudo apt install ros-jazzy-ros2-control ros-jazzy-ros2-controllers \
                 ros-jazzy-gz-ros2-control ros-jazzy-ros-gz \
                 ros-jazzy-joint-state-publisher-gui ros-jazzy-xacro
```

Clone and build:
```bash
git clone https://github.com/sadbanana303/ros2-6dof-robot-arm.git
cd ros2-6dof-robot-arm
colcon build
source install/setup.bash
```

## Running the simulation

**Terminal 1 — launch Gazebo with the robot:**
```bash
source install/setup.bash
ros2 launch robot_arm_description gz_sim.launch.py
```
Wait for confirmation that both controllers activated:
```
[spawner_joint_state_broadcaster]: Configured and activated joint_state_broadcaster
[spawner_arm_controller]: Configured and activated arm_controller
```

**Terminal 2 — run the demo motion:**
```bash
./demo_sweep.sh
```
The arm sweeps through a dramatic pose, then another, then returns to standing straight.

**Optional — view the kinematic model in RViz** (no physics, just the skeleton + manual joint sliders):
```bash
ros2 launch robot_arm_description display.launch.py
```

**Optional — mirror live Gazebo physics in RViz simultaneously:**
```bash
rviz2 -f world
```
Add a `RobotModel` display, set Description Topic to `/robot_description`.

## Sending custom movements

Any 6-value joint position array can be sent directly:
```bash
ros2 topic pub /arm_controller/joint_trajectory trajectory_msgs/msg/JointTrajectory "{
  joint_names: [joint1, joint2, joint3, joint4, joint5, joint6],
  points: [{positions: [0.5, 0.3, -0.4, 0.2, 0.1, 0.0], time_from_start: {sec: 3}}]
}" --once
```
Positions are in radians. Multiple waypoints in one message produce continuous multi-stage motion (see `demo_sweep.sh` for an example).

## Engineering challenges solved

- **Underdamped oscillation** — the arm initially overshot target poses and wobbled before settling. Fixed by tuning per-joint `<dynamics damping="..." friction="..."/>` values and lowering controller proportional gain, trading responsiveness for stability.
- **Torque saturation** — at larger commanded angles, the arm would collapse under its own weight because the simulated joint torque limits were too low to resist gravity. Raised `effort` limits in the URDF to match the load each joint actually carries.
- **Plugin load-order race condition** — the `gz_ros2_control` plugin would sometimes initialize before the full URDF (including the `ros2_control` tag) was available on the `/robot_description` topic, causing a silent failure. Fixed with explicit `robot_param` / `robot_param_node` plugin parameters.
- **Base drift** — without a fixed anchor, reaction forces from arm movement caused the whole robot to slide across the ground plane. Fixed by adding a `world` link with a fixed joint to `base_link`.
- **WSL2 GPU rendering issues** — Gazebo/RViz would crash or render blank windows due to a hardware-acceleration driver conflict (`D3D12: Removing Device`). Resolved by switching to software rendering (`LIBGL_ALWAYS_SOFTWARE=1`) with `OGRE_RTT_MODE=Copy`.

## Adding the demo GIF

1. Record a short screen capture of the arm sweeping in Gazebo (10-15 seconds).
2. Convert to GIF (e.g. via [ezgif.com](https://ezgif.com)) or keep as `.mp4`.
3. Create a `docs/` folder in the repo and add the file there.
4. Update the image path at the top of this README to match.

## Future work

- **MoveIt integration** for inverse kinematics — specify a target point in space instead of manually computing joint angles.
- **Gripper** end-effector for object manipulation.
- **Camera/vision integration** for perception-driven motion.
