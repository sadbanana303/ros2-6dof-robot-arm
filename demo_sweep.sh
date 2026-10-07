#!/bin/bash
source ~/robot_arm_ws/install/setup.bash
ros2 topic pub /arm_controller/joint_trajectory trajectory_msgs/msg/JointTrajectory "{
  joint_names: [joint1, joint2, joint3, joint4, joint5, joint6],
  points: [
    {positions: [1.2, 0.8, -1.2, 0.8, 0.6, 0.0], time_from_start: {sec: 3}},
    {positions: [-1.2, -0.6, 1.0, -0.8, -0.6, 1.2], time_from_start: {sec: 6}},
    {positions: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], time_from_start: {sec: 9}}
  ]
}" --once
