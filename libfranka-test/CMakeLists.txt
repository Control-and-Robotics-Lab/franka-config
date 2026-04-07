cmake_minimum_required(VERSION 3.22)

project(libfranka_smoke_test LANGUAGES CXX)

# Keep dependent packages in the same Conda prefix as libfranka. Otherwise CMake can
# mix the active env with the base Miniconda installation, which breaks libstdc++ at runtime.
if(DEFINED Franka_DIR AND EXISTS "${Franka_DIR}")
  get_filename_component(_franka_cmake_root "${Franka_DIR}" DIRECTORY)
  get_filename_component(_franka_lib_dir "${_franka_cmake_root}" DIRECTORY)
  get_filename_component(_franka_prefix "${_franka_lib_dir}" DIRECTORY)
elseif(DEFINED ENV{CONDA_PREFIX} AND EXISTS "$ENV{CONDA_PREFIX}/lib/cmake/Franka")
  set(_franka_prefix "$ENV{CONDA_PREFIX}")
  set(Franka_DIR "${_franka_prefix}/lib/cmake/Franka" CACHE PATH "Franka package directory" FORCE)
endif()

if(DEFINED _franka_prefix)
  list(PREPEND CMAKE_PREFIX_PATH "${_franka_prefix}")

  if(EXISTS "${_franka_prefix}/lib/cmake/fmt")
    set(fmt_DIR "${_franka_prefix}/lib/cmake/fmt" CACHE PATH "fmt package directory" FORCE)
  endif()
endif()

find_package(Franka 0.20.5 CONFIG REQUIRED)

add_executable(libfranka_smoke_test main.cpp)
target_link_libraries(libfranka_smoke_test PRIVATE Franka::Franka)
target_compile_features(libfranka_smoke_test PRIVATE cxx_std_17)
target_compile_definitions(
  libfranka_smoke_test
  PRIVATE LIBFRANKA_PACKAGE_VERSION="0.20.5"
)

if(DEFINED _franka_prefix)
  set_target_properties(
    libfranka_smoke_test
    PROPERTIES
      BUILD_RPATH "${_franka_prefix}/lib"
      INSTALL_RPATH "${_franka_prefix}/lib"
  )

  # Force DT_RPATH instead of DT_RUNPATH so an IDE-injected LD_LIBRARY_PATH from
  # the base Miniconda install cannot override the franka env runtime libraries.
  target_link_options(libfranka_smoke_test PRIVATE "-Wl,--disable-new-dtags")
endif()
