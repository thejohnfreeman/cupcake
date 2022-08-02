if(INCLUDED_CUPCAKE_ADD_SUBPROJECT)
  return()
endif()
set(INCLUDED_CUPCAKE_ADD_SUBPROJECT TRUE CACHE INTERNAL "")

include(cupcake_project_properties)

set(
  CUPCAKE_SET_SUBPROJECT_VARIABLES
  "${CMAKE_CURRENT_LIST_DIR}/data/set_subproject_variables.cmake"
  CACHE INTERNAL ""
)

# cupcake_add_subproject(<name> [PRIVATE] [<path> ...])
# TODO: I don't think surplus arguments are handled correctly.
function(cupcake_add_subproject name)
  cmake_parse_arguments(ARG "PRIVATE" "" "" ${ARGN})
  if(NOT ARG_UNPARSED_ARGUMENTS)
    set(ARG_UNPARSED_ARGUMENTS ${name})
  endif()

  # added in CMake 3.19: cmake_language(DEFER)
  set(CMAKE_PROJECT_${name}_INCLUDE "${CUPCAKE_SET_SUBPROJECT_VARIABLES}")
  message(STATUS "Entering subproject '${name}' depended by '${PROJECT_NAME}'...")
  add_subdirectory(${ARG_UNPARSED_ARGUMENTS})

  if(ARG_PRIVATE)
    return()
  endif()

  list(GET ARG_UNPARSED_ARGUMENTS 0 path)
  get_filename_component(path "${path}" ABSOLUTE)
  get_property(SUBPROJECT_NAME
    DIRECTORY "${path}"
    PROPERTY PROJECT_NAME
  )
  if(NOT SUBPROJECT_NAME STREQUAL name)
    message(FATAL_ERROR "Subproject '${name}' not found at '${path}'.")
  endif()

  get_property(SUBPROJECT_VERSION_MAJOR
    DIRECTORY "${path}"
    PROPERTY PROJECT_VERSION_MAJOR
  )
  get_property(SUBPROJECT_VERSION_MINOR
    DIRECTORY "${path}"
    PROPERTY PROJECT_VERSION_MINOR
  )
  
  cupcake_set_project_property(
    APPEND PROPERTY PROJECT_DEPENDENCIES
    "${SUBPROJECT_NAME}\\\\;${SUBPROJECT_VERSION_MAJOR}.${SUBPROJECT_VERSION_MINOR}"
  )
endfunction()
