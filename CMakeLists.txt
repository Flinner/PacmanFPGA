cmake_minimum_required(VERSION 3.7) # not sure of version...
project(VGA_SIMULATOR LANGUAGES CXX)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

#TODO: auto install verilator

# Enable compile commands JSON for editor support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Check if SDL2 is available, otherwise download and build it
include(FetchContent)

# # Try to find SDL2 on the system first
# find_package(SDL2)

# if (SDL2_FOUND)
#     message(STATUS "Found SDL2: ${SDL2_INCLUDE_DIRS}")
# else()
#     message(STATUS "SDL2 not found. Fetching SDL2 from source.")

#     FetchContent_Declare(
#         SDL2
#         GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
#         GIT_TAG release-2.28.2  # Use a specific stable release
#     )

#     # Fetch and build SDL2
#     FetchContent_MakeAvailable(SDL2)
# endif()

### SFML https://github.com/SFML/cmake-sfml-project/blob/master/CMakeLists.txt

FetchContent_Declare(SFML
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    GIT_TAG 2.6.x
    GIT_SHALLOW ON
    EXCLUDE_FROM_ALL
    SYSTEM)
FetchContent_MakeAvailable(SFML)



add_executable(Vour src/top.cpp)
# # Link SDL2 library
# target_link_libraries(Vour PRIVATE SDL2::SDL2 SDL2::SDL2main)

target_link_libraries(Vour PRIVATE sfml-graphics)
target_compile_features(Vour PRIVATE cxx_std_20)

if(WIN32)
    add_custom_command(
        TARGET main
        COMMENT "Copy OpenAL DLL"
        PRE_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${SFML_SOURCE_DIR}/extlibs/bin/$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,x64,x86>/openal32.dll $<TARGET_FILE_DIR:main>
        VERBATIM)
endif()


# Glob all .sv files in the rtl directory
file(GLOB RTL_SOURCE_FILES rtl/*.sv)
# # Ensure top.sv is at the top and not duplicated
list(REMOVE_ITEM RTL_SOURCE_FILES ${CMAKE_SOURCE_DIR}/rtl/top.sv)
list(INSERT RTL_SOURCE_FILES 0 ${CMAKE_SOURCE_DIR}/rtl/top.sv)


verilate(Vour SOURCES ${RTL_SOURCE_FILES}
  TOP_MODULE top
  OPT_FAST
  THREADS
  VERILATOR_ARGS -O3 --x-initial fast --noassert --x-assign fast --threads 10
)
