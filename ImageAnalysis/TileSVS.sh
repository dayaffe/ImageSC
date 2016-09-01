#!/bin/bash
# This script takes 4 arguments and are as follows:
# 1. The pixel size of all of the sides in the tiles
# 2. The suffix or file extension for the resulting image (usually png)
# 3. The username folder inside "scratch"
# 4. The cancer disease code (i.e., prad)

oldDir=$(pwd)

cd /home/dayaffe/Imaging/ImageSC/scratch/david.yaffe/THAD/

shopt -s nullglob
FILES=(*.svs)
if [ ${#FILES[@]} -eq 0 ]; then 
    echo "no svs files found"
else
    for i in "${FILES[@]}"
    do
        FOLDER=$(echo ${i} | cut -d. -f1)
        if [ -d ${FOLDER} ]; then
            echo "${FOLDER} exists"
        else
            mkdir ${FOLDER}
            echo "$i -> ${FOLDER}"
            vips dzsave ${i} ${FOLDER}/ --depth one --tile-size ${1} --overlap 0 --suffix .jpeg
            cd ./${FOLDER}/${FOLDER}_files/0
            shopt -s dotglob
            mv -- * ../..
            shopt -u dotglob
            cd ../..
            rm -r ./${FOLDER}_files
            mv *.dzi ../
            cd ..
        fi
    done
fi
shopt -u nullglob

cd ${oldDir}

echo "done"
