cmake_minimum_required(VERSION 3.7) # not sure of version...
project(VGA_SIMULATOR)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

#TODO: auto install verilator

# Enable compile commands JSON for editor support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Check if SDL2 is available, otherwise download and build it
include(FetchContent)

# Try to find SDL2 on the system first
find_package(SDL2)

if (SDL2_FOUND)
    message(STATUS "Found SDL2: ${SDL2_INCLUDE_DIRS}")
else()
    message(STATUS "SDL2 not found. Fetching SDL2 from source.")

    FetchContent_Declare(
        SDL2
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG release-2.28.2  # Use a specific stable release
    )

    # Fetch and build SDL2
    FetchContent_MakeAvailable(SDL2)
endif()


add_executable(Vour main_square.cpp)
# Link SDL2 library
target_link_libraries(Vour PRIVATE SDL2::SDL2 SDL2::SDL2main)

# Glob all .sv files in the rtl directory
file(GLOB RTL_SOURCE_FILES rtl/*.sv)

# Ensure top_square.sv is at the top and not duplicated
list(REMOVE_ITEM RTL_SOURCE_FILES ${CMAKE_SOURCE_DIR}/rtl/top_square.sv)
list(INSERT RTL_SOURCE_FILES 0 ${CMAKE_SOURCE_DIR}/rtl/top_square.sv)


verilate(Vour SOURCES ${RTL_SOURCE_FILES})
