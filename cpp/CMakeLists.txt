cmake_minimum_required(VERSION 3.16)
project(ai_task_priority_core LANGUAGES C CXX)

add_library(priority_core SHARED
    src/priority_core.cpp
)

target_include_directories(priority_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_features(priority_core PUBLIC cxx_std_17)
set_target_properties(priority_core PROPERTIES
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    CMAKE_CXX_VISIBILITY_PRESET hidden
)
