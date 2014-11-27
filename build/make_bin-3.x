#!/bin/bash

    ln -s bin-3.x ../bin

    echo "+-----------------------------------------------------+"
    echo "| Building:  LINICE                                   |"
    echo "+-----------------------------------------------------+"
    cd ../linice
    make clean
    make

    echo "+-----------------------------------------------------+"
    echo "| Building:  LINSYM                                   |"
    echo "+-----------------------------------------------------+"
    cd ../linsym
    make clean
    make

    echo "+-----------------------------------------------------+"
    echo "| Building:  XICE                                     |"
    echo "+-----------------------------------------------------+"
    cd ../x
    make clean
    make

    echo "+-----------------------------------------------------+"
    echo "| Building:  FINAL KERNEL-DEPENDENT LINICE MODULE     |"
    echo "+-----------------------------------------------------+"
    cd ../bin
    ./compile_3.x

    echo "+-----------------------------------------------------+"
    echo "| Compilation of all components is complete. Change   |"
    echo "| directory to ../bin and run linice.                 |"
    echo "+-----------------------------------------------------+"
