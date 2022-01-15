cmake_minimum_required(VERSION 3.21)

add_subdirectory(PackagerConfig)
add_subdirectory(PackagerDeb)
add_subdirectory(PackagerRpm)
add_subdirectory(PackagerTgz)
add_subdirectory(PackagerZip)

add_subdirectory(PackageApi) # NOTE THAT IT IS CALLED PackageApi <--- the 'r' is missing


