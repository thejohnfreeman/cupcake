if(INCLUDED_CUPCAKE_INSTALL_CPP_INFO)
  return()
endif()
set(INCLUDED_CUPCAKE_INSTALL_CPP_INFO TRUE CACHE INTERNAL "")

set(CUPCAKE_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")
file(READ "${CMAKE_CURRENT_LIST_DIR}/data/install_cpp_info.cmake"
  CUPCAKE_INSTALL_CPP_INFO
)

function(cupcake_install_cpp_info)
  install(
    CODE "
set(CUPCAKE_MODULE_DIR \"${CUPCAKE_MODULE_DIR}\")
set(PACKAGE_NAME ${PROJECT_NAME})
string(TOUPPER $<CONFIG> CONFIG)
${CUPCAKE_INSTALL_CPP_INFO}
"
    COMPONENT ${PROJECT_NAME}_development
  )
endfunction()