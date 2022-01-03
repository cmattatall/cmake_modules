
1-Liner to clean the existing build tree if in the build tree, and 
configure, build, cpack, and uncompress the package before printing the 
directory structure of the decompressed output. If this command is not invoked
from the directory "build", first a directory called "build" is created and entered.
```sh
if [ $(basename $(realpath $(pwd))) == "build" ]; then rm -r ./*; echo "in build tree"; elif  [ -f "$(realpath $(pwd))/.gitignore" ]; then if [ -d "$(realpath $(pwd))/build" ]; then rm -r "$(realpath $(pwd))/build"; fi; mkdir build && cd build; fi; cmake ../ --log-level=debug && make && cpack && cd packages && find . -name "*\.tar\.gz" -exec tar -xf {} -C . \; && tree; cd ../../
```

# TODO

[ ] Fix bug with uninstall script not properly uninstalling as part of test teardown. This is likely because the name of the debian packges once installed with dpkg are ${PROJECT_NAME}-${PKG} and not just ${PKG}. The fix is likely in the cpack_deb.cmake file

[ ] Add project readme

[ ] Add project license file

    