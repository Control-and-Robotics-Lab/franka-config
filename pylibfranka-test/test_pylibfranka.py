#!/usr/bin/env python3

import argparse
import sys

import pylibfranka


def offline_smoke_test() -> None:
    print(f"pylibfranka version: {pylibfranka.__version__}")
    print(f"pylibfranka module: {pylibfranka.__file__}")
    print(f"Robot constructor doc: {pylibfranka.Robot.__init__.__doc__.strip()}")
    exported = sorted(name for name in dir(pylibfranka) if not name.startswith("_"))
    print(f"Exported symbols: {len(exported)} total")
    print("Key symbols:", ", ".join(name for name in exported if name in {
        "Robot",
        "RobotMode",
        "RobotState",
        "NetworkException",
        "ControlException",
        "FrankaException",
    }))


def connect_robot(robot_ip: str, realtime_mode: str) -> pylibfranka.Robot:
    if realtime_mode == "enforce":
        return pylibfranka.Robot(robot_ip, pylibfranka.RealtimeConfig.kEnforce)
    if realtime_mode == "ignore":
        return pylibfranka.Robot(robot_ip, pylibfranka.RealtimeConfig.kIgnore)

    try:
        return pylibfranka.Robot(robot_ip, pylibfranka.RealtimeConfig.kEnforce)
    except pylibfranka.RealtimeException as exception:
        print(
            f"Realtime scheduling is unavailable ({exception}). "
            "Retrying with RealtimeConfig.kIgnore...",
            file=sys.stderr,
        )
        return pylibfranka.Robot(robot_ip, pylibfranka.RealtimeConfig.kIgnore)


def live_robot_test(robot_ip: str, realtime_mode: str) -> None:
    robot = connect_robot(robot_ip, realtime_mode)
    state = robot.read_once()
    print(f"Connected to {robot_ip}")
    print(f"Robot mode: {state.robot_mode}")
    print(f"q[0]: {state.q[0]}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Offline and optional live smoke test for pylibfranka."
    )
    parser.add_argument(
        "robot_ip",
        nargs="?",
        help="Optional robot IP address for a live read_once() check.",
    )
    parser.add_argument(
        "--realtime",
        choices=("auto", "enforce", "ignore"),
        default="auto",
        help=(
            "Realtime scheduling mode for the robot connection. "
            "'auto' tries enforce first, then falls back to ignore."
        ),
    )
    args = parser.parse_args()

    offline_smoke_test()

    if not args.robot_ip:
        print("Offline smoke test passed. Provide a robot IP to run a live read_once() check.")
        return 0

    try:
        live_robot_test(args.robot_ip, args.realtime)
    except pylibfranka.FrankaException as exception:
        print(f"Live pylibfranka test failed: {exception}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
