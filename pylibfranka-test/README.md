# Python pylibfranka Test

Offline smoke test:

```bash
conda run -n franka python "$PWD/pylibfranka-test/test_pylibfranka.py"
```

Optional live robot check:

```bash
sudo ufw disable
conda run -n franka python "$PWD/pylibfranka-test/test_pylibfranka.py" <robot_ip>
```

If the machine cannot enable realtime scheduling, the script now retries automatically with
`RealtimeConfig.kIgnore`. You can also force the mode explicitly:

```bash
conda run -n franka python "$PWD/pylibfranka-test/test_pylibfranka.py" --realtime ignore <robot_ip>
```
