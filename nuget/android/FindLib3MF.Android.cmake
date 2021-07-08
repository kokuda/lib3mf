cmake_minimum_required(VERSION 3.9)

if (NOT Lib3MF_ANDROID_FOUND)
    set(Lib3MF_ANDROID_FOUND TRUE)
    add_library(Lib3MF STATIC IMPORTED GLOBAL)
    set_target_properties(Lib3MF PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/build/native/include")
    set_target_properties(Lib3MF PROPERTIES IMPORTED_LOCATION_DEBUG "${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${ANDROID_ABI}/Debug/static/lib3MF_s.a")
    set_target_properties(Lib3MF PROPERTIES IMPORTED_LOCATION_RELEASE "${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${ANDROID_ABI}/Release/static/lib3MF_s.a")
    set_target_properties(Lib3MF PROPERTIES IMPORTED_LOCATION_RELWITHDEBINFO "${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${ANDROID_ABI}/Release/static/lib3MF_s.a")
    set_target_properties(Lib3MF PROPERTIES IMPORTED_LOCATION_MINSIZEREL "${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${ANDROID_ABI}/Release/static/lib3MF_s.a")
    # Default location for other build configurations defaults to Debug
    set_target_properties(Lib3MF PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/build/native/lib/${ANDROID_ABI}/Debug/static/lib3MF_s.a")
endif()