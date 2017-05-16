#!/bin/bash

cd ..

echo "(Re)stowing all apps..."
for dir in */
do
    echo Unstowing $dir
    stow -D $dir
    if [ "$dir" != "tools" ]
    then
        echo Stowing $dir
        stow $dir
    fi
done
