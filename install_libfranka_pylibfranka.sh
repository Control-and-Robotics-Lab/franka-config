#!/usr/bin/env bash
set -euo pipefail

LIBFRANKA_VERSION="${1:-0.20.5}"
REPO_URL="${REPO_URL:-https://github.com/frankarobotics/libfranka.git}"
SRC_ROOT="${SRC_ROOT:-$HOME/src}"
SRC_DIR="${SRC_ROOT}/libfranka-${LIBFRANKA_VERSION}"
SOURCE_BUILD_LIBFRANKA="${SOURCE_BUILD_LIBFRANKA:-0}"

if [[ -z "${CONDA_PREFIX:-}" ]]; then
  echo "Activate the target conda environment first." >&2
  exit 1
fi

if [[ ! -f "${CONDA_PREFIX}/lib/libfranka.so" && "${SOURCE_BUILD_LIBFRANKA}" != "1" ]]; then
  echo "libfranka is not installed in the active environment." >&2
  echo "Install it from conda-forge first, or rerun with SOURCE_BUILD_LIBFRANKA=1." >&2
  exit 1
fi

mkdir -p "${SRC_ROOT}"

if [[ ! -d "${SRC_DIR}/.git" ]]; then
  git clone --branch "${LIBFRANKA_VERSION}" --depth 1 --recurse-submodules "${REPO_URL}" "${SRC_DIR}"
else
  echo "Using existing source tree: ${SRC_DIR}"
fi

cd "${SRC_DIR}"

if [[ "${SOURCE_BUILD_LIBFRANKA}" == "1" ]]; then
  cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${CONDA_PREFIX}" \
    -DCMAKE_PREFIX_PATH="${CONDA_PREFIX}" \
    -DEIGEN3_INCLUDE_DIRS="${CONDA_PREFIX}/include/eigen3" \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF

  cmake --build build -j"$(nproc)"
  cmake --install build
fi

export CMAKE_PREFIX_PATH="${CONDA_PREFIX}:${CMAKE_PREFIX_PATH:-}"
export PKG_CONFIG_PATH="${CONDA_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH:-}"

if ! rg -q 'EIGEN3_INCLUDE_DIRS=.*include/eigen3' setup.py; then
  sed -i "/-DGENERATE_PYLIBFRANKA=ON/a\\
            f\"-DCMAKE_PREFIX_PATH=${CONDA_PREFIX}\",\\
            f\"-DEIGEN3_INCLUDE_DIRS=${CONDA_PREFIX}/include/eigen3\"," setup.py
fi

python -m pip install --no-build-isolation --no-deps .

mkdir -p "${CONDA_PREFIX}/etc/conda/activate.d" "${CONDA_PREFIX}/etc/conda/deactivate.d"

cat > "${CONDA_PREFIX}/etc/conda/activate.d/franka.sh" <<EOF
#!/usr/bin/env bash
export _FRANKA_OLD_CMAKE_PREFIX_PATH="\${CMAKE_PREFIX_PATH:-}"
export _FRANKA_OLD_PKG_CONFIG_PATH="\${PKG_CONFIG_PATH:-}"
export _FRANKA_OLD_LD_LIBRARY_PATH="\${LD_LIBRARY_PATH:-}"
export CMAKE_PREFIX_PATH="${CONDA_PREFIX}:\${CMAKE_PREFIX_PATH:-}"
export PKG_CONFIG_PATH="${CONDA_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:\${LD_LIBRARY_PATH:-}"
export Franka_DIR="${CONDA_PREFIX}/lib/cmake/Franka"
EOF

cat > "${CONDA_PREFIX}/etc/conda/deactivate.d/franka.sh" <<'EOF'
#!/usr/bin/env bash
export CMAKE_PREFIX_PATH="${_FRANKA_OLD_CMAKE_PREFIX_PATH:-}"
export PKG_CONFIG_PATH="${_FRANKA_OLD_PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="${_FRANKA_OLD_LD_LIBRARY_PATH:-}"
unset _FRANKA_OLD_CMAKE_PREFIX_PATH
unset _FRANKA_OLD_PKG_CONFIG_PATH
unset _FRANKA_OLD_LD_LIBRARY_PATH
unset Franka_DIR
EOF

echo
if [[ "${SOURCE_BUILD_LIBFRANKA}" == "1" ]]; then
  echo "Installed libfranka ${LIBFRANKA_VERSION} and pylibfranka into ${CONDA_PREFIX}"
else
  echo "Installed pylibfranka ${LIBFRANKA_VERSION} into ${CONDA_PREFIX}"
  echo "Using libfranka from the active conda environment."
fi
echo "Reactivate the environment once so the activation hooks take effect:"
echo "  conda deactivate && conda activate $(basename "${CONDA_PREFIX}")"
