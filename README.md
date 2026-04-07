# franka-conda

Portable Conda setup for:
- `libfranka`
- `pylibfranka`

Recommended model:
- use `conda-forge` for the full dependency stack
- use `conda-forge::libfranka`
- install `pylibfranka` from the `libfranka` source tree with `pip --no-deps --no-build-isolation`

This avoids the usual Conda/PyPI conflicts where `pip` tries to manage C++ dependencies.

## Files

- `environment-franka.yml`
  Recommended fresh environment.
  Uses `conda-forge::libfranka=0.20.5`.

- `environment.yml`
  Alternative environment file with the same core stack.

- `install_libfranka_pylibfranka.sh`
  Helper to install `pylibfranka` into the active env.
  Optional: also source-build `libfranka` when `SOURCE_BUILD_LIBFRANKA=1`.

## Recommended Install

From this repository root:

```bash
conda env create -f environment-franka.yml
conda activate franka

./install_libfranka_pylibfranka.sh 0.20.5
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

## Optional Source Build

If you want to source-build `libfranka` instead of using `conda-forge::libfranka`:

```bash
conda env create -f environment-franka.yml
conda activate franka
SOURCE_BUILD_LIBFRANKA=1 ./install_libfranka_pylibfranka.sh 0.20.5
```

The script:
- clones `libfranka`
- optionally builds and installs `libfranka` into `$CONDA_PREFIX`
- installs `pylibfranka` into the active env
- adds Conda activation hooks for `Franka_DIR`, `CMAKE_PREFIX_PATH`, `PKG_CONFIG_PATH`, and `LD_LIBRARY_PATH`

## Rebuild

For a local rebuild in the `franka` env:

```bash
conda activate franka
./install_libfranka_pylibfranka.sh 0.20.5
```

If you need a full source rebuild of both layers:

```bash
conda activate franka
SOURCE_BUILD_LIBFRANKA=1 ./install_libfranka_pylibfranka.sh 0.20.5
```

## Practical Notes

- Do not use plain `pip install pylibfranka` in these envs.
  That can pull a second dependency stack and break the Conda-managed one.

- `conda-forge::libfranka` does not include `pylibfranka`.
  The Python bindings still need a separate source install.

- If you upgrade the Pinocchio / Boost stack, rerun:

```bash
conda activate franka
./install_libfranka_pylibfranka.sh 0.20.5
```

- Prefer running examples without `sudo`.
  If you must use `sudo`, preserve the env:

```bash
sudo -E ./your_binary <robot_ip>
```

## Recommended Result

For maximum stability, the target state is:
- `libfranka` from `conda-forge`
- Pinocchio stack from `conda-forge`
- `pylibfranka` as the only source-installed package
