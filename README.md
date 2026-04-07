# franka-conda

Minimal Conda setup for:
- `libfranka`
- `pylibfranka`
- `pinocchio`

## Files

- `environment.yml`
  Environment with pinned versions only for:
  - `python=3.10.19`
  - `cmake>=3.22,<4`
  - `eigen=3.4.0`
  - `libfranka=0.20.5`
  - `pinocchio=3.9.0`
  - `pylibfranka==0.20.5` via the `pip:` section
  Other supporting packages remain included without version pins.

- `install.sh`
  Creates or updates the `franka` Conda env from `environment.yml`.

## Recommended Install

From this repository root:

```bash
./install.sh
conda activate franka
```

To update an existing env in place:

```bash
./install.sh
```

Verify:

```bash
python - <<'PY'
import pinocchio
import pylibfranka
print("pinocchio", pinocchio.__version__)
print("pylibfranka", pylibfranka.__version__)
PY
```

## Build Configuration

Recommended `libfranka-test` configure/build from this repository root:

```bash
conda activate franka
cmake -S libfranka-test -B libfranka-test/cmake-build-release-franka \
  -DCMAKE_BUILD_TYPE=Release \
  -DFranka_DIR="$CONDA_PREFIX/lib/cmake/Franka"
cmake --build libfranka-test/cmake-build-release-franka
```

Direct run:

```bash
./libfranka-test/cmake-build-release-franka/libfranka_smoke_test 192.168.2.12
```

Equivalent one-shot build without activating the env:

```bash
conda run -n franka bash -lc '
  cmake -S "$PWD/libfranka-test" \
    -B /tmp/libfranka-test-build \
    -DCMAKE_BUILD_TYPE=Release \
    -DFranka_DIR="$CONDA_PREFIX/lib/cmake/Franka" &&
  cmake --build /tmp/libfranka-test-build
'
```

## Notes

- `libfranka` is installed from `conda-forge`; `pylibfranka` is installed by Conda via the `pip:` section.
- As of April 7, 2026, PyPI provides `pylibfranka 0.20.5` wheels for Python 3.10 on Linux.
- `conda` will install the `pip:` section after resolving the Conda packages in `environment.yml`.

## Realtime Scheduling

`libfranka` and `pylibfranka` may try to enable Linux realtime scheduling. If the OS denies that,
you can still connect with the fallback ignore mode in these tests, but for full realtime behavior
you need additional permissions.

Quick check with `sudo`:

```bash
sudo ./libfranka-test/cmake-build-release-franka/libfranka_smoke_test <robot_ip>
```

Recommended persistent setup for your Linux user:

Create `/etc/security/limits.d/franka.conf` with:

```conf
<your_username> soft rtprio 99
<your_username> hard rtprio 99
<your_username> soft memlock unlimited
<your_username> hard memlock unlimited
```

Then log out and log back in.

If you launch through `systemd`, also allow realtime there:

```ini
LimitRTPRIO=99
LimitMEMLOCK=infinity
```

Optional capability-based setup:

```bash
sudo setcap cap_sys_nice+ep ./libfranka-test/cmake-build-release-franka/libfranka_smoke_test
```

Check your current limits:

```bash
ulimit -r
ulimit -l
```

## Test Folders

- `libfranka-test/`
  Minimal CMake-based C++ smoke test for `libfranka`, with an optional live `readOnce()` check.

- `pylibfranka-test/`
  Minimal Python smoke test for `pylibfranka`, with an optional live `read_once()` check.
