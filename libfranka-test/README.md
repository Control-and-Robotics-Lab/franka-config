# C++ libfranka Test

Offline smoke test:

```bash
conda run -n franka bash -lc '
  cmake -S "$PWD/libfranka-test" -B /tmp/libfranka-test-build &&
  cmake --build /tmp/libfranka-test-build &&
  /tmp/libfranka-test-build/test_libfranka
'
```

Optional live robot check:

```bash
conda run -n franka /tmp/libfranka-test-build/test_libfranka <robot_ip>
```
