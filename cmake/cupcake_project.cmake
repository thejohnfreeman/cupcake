include_guard(GLOBAL)

macro(cupcake_project)
  # Allow `install(CODE)` to use generator expressions.
  cmake_policy(SET CMP0087 NEW)

  # Define more project variables.
  set(PROJECT_EXPORT_SET ${PROJECT_NAME}_targets)

  set(PROJECT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  set(PROJECT_EXPORT_DIR "${PROJECT_BINARY_DIR}/export/${PROJECT_NAME}")

  set(CMAKE_INSTALL_EXPORTDIR share)

  #if(PROJECT_IS_TOP_LEVEL)
  if(PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    set(CMAKE_PROJECT_EXPORT_SET ${PROJECT_EXPORT_SET})
  endif()

  # Change defaults to follow recommended best practices.

  # On Windows, we need to make sure that shared libraries end up next to the
  # executables that require them.
  # Without setting these variables, multi-config generators generally place
  # targets in ${subdirectory}/${target}.dir/${config}.
  # We cannot use CMAKE_INSTALL_LIBDIR because the value of that variable may
  # differ between the top-level project linking against subproject
  # artifacts installed under the output prefix, and subprojects installing
  # themselves under the top-level project's output prefix.
  # In other words, if a subproject installs a library to
  # CMAKE_INSTALL_LIBDIR, then it may end up somewhere other than the
  # CMAKE_INSTALL_LIBDIR that the top-level project looks in.
  if(NOT CMAKE_OUTPUT_PREFIX)
    set(CMAKE_OUTPUT_PREFIX "${CMAKE_BINARY_DIR}/output/$<CONFIG>")
  endif()
  if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_OUTPUT_PREFIX}/bin")
  endif()
  if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_OUTPUT_PREFIX}/lib")
  endif()
  if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_OUTPUT_PREFIX}/lib")
  endif()
  if(NOT CMAKE_INCLUDE_OUTPUT_DIRECTORY)
    set(CMAKE_INCLUDE_OUTPUT_DIRECTORY
      "${CMAKE_BINARY_DIR}/output/Common/include"
    )
  endif()

  # Search for Package Configuration Files first.
  # Use Find Modules as backup only.
  set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)
  # Prefer the latest version of a package.
  set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
  # Prefer Config Modules over Find Modules.
  set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
  # Cupcake projects must put their Find Modules in `external/`.
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/external")

  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(OSX TRUE)
  endif()
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(LINUX TRUE)
  endif()
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(WINDOWS TRUE)
  endif()

  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN YES)
  set(CMAKE_EXPORT_COMPILE_COMMANDS YES)

  # Enable deterministic relocatable builds.
  set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)

  get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  if("CXX" IN_LIST languages OR "C" IN_LIST languages)
    include(GNUInstallDirs)
    # Use relative rpath for installation.
    if(OSX)
      set(origin @loader_path)
    else()
      set(origin $ORIGIN)
    endif()
    file(RELATIVE_PATH relDir
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
    )
    set(CMAKE_INSTALL_RPATH ${origin} ${origin}/${relDir})
  endif()

  set(target ${PROJECT_NAME}.imports.main)
  add_library(${target} INTERFACE)
  install(TARGETS ${target} EXPORT ${PROJECT_EXPORT_SET})
  add_library(${PROJECT_NAME}::imports::main ALIAS ${target})

  # This command should be called when
  # `CMAKE_CURRENT_SOURCE_DIR == PROJECT_SOURCE_DIR`,
  # but when it isn't, we want to look in `PROJECT_SOURCE_DIR`.
  set(path "${PROJECT_SOURCE_DIR}/cupcake.json")
  if(EXISTS "${path}")
    file(READ "${path}" PROJECT_JSON)
    set(${PROJECT_NAME}_JSON "${PROJECT_JSON}")
  endif()

  set(${PROJECT_NAME}_FOUND 1)
endmacro()
