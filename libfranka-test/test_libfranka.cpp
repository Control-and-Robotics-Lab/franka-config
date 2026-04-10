#include <cstdlib>
#include <iostream>
#include <string>

#include <franka/exception.h>
#include <franka/control_types.h>
#include <franka/robot.h>
#include <franka/robot_state.h>

franka::Robot connect_robot(const std::string& robot_ip) {
  try {
    return franka::Robot(robot_ip, franka::RealtimeConfig::kEnforce);
  } catch (const franka::RealtimeException& exception) {
    std::cerr << "Realtime scheduling is unavailable (" << exception.what()
              << "). Retrying with RealtimeConfig::kIgnore...\n";
    return franka::Robot(robot_ip, franka::RealtimeConfig::kIgnore);
  }
}

int main(int argc, char** argv) {
  std::cout << "libfranka package version: " << LIBFRANKA_PACKAGE_VERSION << '\n';

  franka::RobotState offline_state{};
  std::cout << "Offline RobotState.q has " << offline_state.q.size() << " joints\n";

  // Force a real libfranka symbol reference so the smoke test validates linking
  // without printing a misleading fake compatibility error.
  [[maybe_unused]] auto read_once_symbol = &franka::Robot::readOnce;
  std::cout << "libfranka symbols resolved successfully\n";

  if (argc < 2) {
    std::cout << "Offline smoke test passed. Provide a robot IP to run a live readOnce() check.\n";
    return EXIT_SUCCESS;
  }

  const std::string robot_ip = argv[1];
  try {
    franka::Robot robot = connect_robot(robot_ip);
    franka::RobotState live_state = robot.readOnce();
    std::cout << "Connected to " << robot_ip << '\n';
    std::cout << "Server version: " << robot.serverVersion() << '\n';
    std::cout << "Robot mode: " << static_cast<int>(live_state.robot_mode) << '\n';
    std::cout << "q[0]: " << live_state.q[0] << '\n';
  } catch (const franka::Exception& exception) {
    std::cerr << "Live libfranka test failed: " << exception.what() << '\n';
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
