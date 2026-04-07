# C++ libfranka Test

Offline smoke test:

```bash
conda run -n franka bash -lc '
  cmake -S /home/yichangfeng/franka-conda/libfranka-test -B /tmp/libfranka-test-build &&
  cmake --build /tmp/libfranka-test-build &&
  /tmp/libfranka-test-build/libfranka_smoke_test
'
```

Optional live robot check:

```bash
conda run -n franka /tmp/libfranka-test-build/libfranka_smoke_test <robot_ip>
```
