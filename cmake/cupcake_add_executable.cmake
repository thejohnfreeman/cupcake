include_guard(GLOBAL)

include(cupcake_find_sources)
include(cupcake_project_properties)
include(GNUInstallDirs)

# A target representing all executables declared with the function below.
add_custom_target(executables)

# add_executable(<name> [<source>...])
function(cupcake_add_executable name)
  set(target ${PROJECT_NAME}.${name})
  set(this ${target} PARENT_SCOPE)
  add_executable(${target} ${ARGN})
  set(alias ${PROJECT_NAME}::${name})
  add_executable(${alias} ALIAS ${target})

  cupcake_set_project_property(
    APPEND PROPERTY PROJECT_EXECUTABLES "${alias}"
  )

  # if(PROJECT_IS_TOP_LEVEL)
  if(PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    add_dependencies(executables ${target})
    add_custom_target(execute.${name} ${target} \${CUPCAKE_EXE_ARGUMENTS})
    if(name STREQUAL CMAKE_PROJECT_NAME)
      add_custom_target(execute ${target} \${CUPCAKE_EXE_ARGUMENTS})
    endif()
  endif()

  # Let the executable include "private" headers if it wants.
  target_include_directories(${target}
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/${name}"
  )

  cupcake_find_sources(sources ${name} src)
  target_sources(${target} PRIVATE ${sources})

  set_target_properties(${target} PROPERTIES
    OUTPUT_NAME ${name}
    EXPORT_NAME ${name}
  )

  install(
    TARGETS ${target}
    EXPORT ${PROJECT_EXPORT_SET}
    RUNTIME
      DESTINATION "${CMAKE_INSTALL_BINDIR}"
      COMPONENT ${PROJECT_NAME}_runtime
  )
endfunction()
