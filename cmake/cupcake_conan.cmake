if(DEFINED_CUPCAKE_CONAN)
  return()
endif()
set(DEFINED_CUPCAKE_CONAN TRUE)

set(CUPCAKE_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")
file(READ "${CMAKE_CURRENT_LIST_DIR}/install_cpp_info.cmake"
  CUPCAKE_INSTALL_CPP_INFO
)

function(cupcake_install_cpp_info)
  install(
    CODE "
string(TOUPPER $<CONFIG> CONFIG)
set(CUPCAKE_MODULE_DIR \"${CUPCAKE_MODULE_DIR}\")
set(PACKAGE_NAME ${PROJECT_NAME})
${CUPCAKE_INSTALL_CPP_INFO}
"
    COMPONENT ${PROJECT_NAME}_development
  )
endfunction()
