cmake_minimum_required(VERSION 3.15)
project(DogeOS)
include_directories(src/main)

set(CMAKE_C_STANDARD 11)

add_executable(DogeOS src/sipl/siplmain.c)