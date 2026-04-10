cmake_minimum_required(VERSION 3.22)

project(test_libfranka LANGUAGES CXX)

# Keep all C++ packages in the same Conda prefix as libfranka.
if(DEFINED Franka_DIR AND EXISTS "${Franka_DIR}")
  cmake_path(GET Franka_DIR PARENT_PATH _franka_cmake_dir)
  cmake_path(GET _franka_cmake_dir PARENT_PATH _franka_lib_dir)
  cmake_path(GET _franka_lib_dir PARENT_PATH FRANKA_PREFIX)
elseif(DEFINED ENV{CONDA_PREFIX} AND EXISTS "$ENV{CONDA_PREFIX}/lib/cmake/Franka")
  set(FRANKA_PREFIX "$ENV{CONDA_PREFIX}")
  set(Franka_DIR "${FRANKA_PREFIX}/lib/cmake/Franka" CACHE PATH "Franka package directory" FORCE)
endif()

if(DEFINED FRANKA_PREFIX)
  list(PREPEND CMAKE_PREFIX_PATH "${FRANKA_PREFIX}")
  if(EXISTS "${FRANKA_PREFIX}/lib/cmake/fmt")
    set(fmt_DIR "${FRANKA_PREFIX}/lib/cmake/fmt" CACHE PATH "fmt package directory" FORCE)
  endif()
endif()

find_package(Franka 0.20.5 CONFIG REQUIRED)

add_executable(test_libfranka test_libfranka.cpp)
target_link_libraries(test_libfranka PRIVATE Franka::Franka)
target_compile_features(test_libfranka PRIVATE cxx_std_17)
target_compile_definitions(
  test_libfranka
  PRIVATE LIBFRANKA_PACKAGE_VERSION="0.20.5"
)

if(DEFINED FRANKA_PREFIX)
  set_target_properties(
    test_libfranka
    PROPERTIES
      BUILD_RPATH "${FRANKA_PREFIX}/lib"
      INSTALL_RPATH "${FRANKA_PREFIX}/lib"
  )

  # Force DT_RPATH instead of DT_RUNPATH so an IDE-injected LD_LIBRARY_PATH from
  # the base Miniconda install cannot override the franka env runtime libraries.
  target_link_options(test_libfranka PRIVATE "-Wl,--disable-new-dtags")
endif()
