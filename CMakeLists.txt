cmake_minimum_required( VERSION 3.8...3.27 )
project( PROJECT_ VERSION 0.0.0 LANGUAGES CXX )
set( SON8PROJ son8__${PROJECT_NAME} )
# Private configuration under source directory
add_subdirectory( source )
add_library( son8::${PROJECT_NAME} ALIAS ${SON8PROJ} )
target_compile_features( ${SON8PROJ} INTERFACE cxx_std_17 )
target_compile_options( ${SON8PROJ} INTERFACE $<$<CXX_COMPILER_ID:MSVC>:/utf-8 /permissive- /Zc:__cplusplus> )
