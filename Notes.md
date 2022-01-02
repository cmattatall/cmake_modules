
1-Liner to clean the existing build tree if in the build tree, and 
configure, build, cpack, and uncompress the package before printing the 
directory structure of the decompressed output. If this command is not invoked
from the directory "build", first a directory called "build" is created and entered.
```sh
if [ $(basename $(realpath $(pwd))) == "build" ]; then rm -r ./*; echo "in build tree"; elif  [ -f "$(realpath $(pwd))/.gitignore" ]; then if [ -d "$(realpath $(pwd))/build" ]; then rm -r "$(realpath $(pwd))/build"; fi; mkdir build && cd build; fi; cmake ../ --log-level=debug && make && cpack && cd packages && find . -name "*\.tar\.gz" -exec tar -xf {} -C . \; && tree; cd ../../
```
