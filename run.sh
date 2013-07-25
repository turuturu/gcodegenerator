#!/bin/sh
DAT_EXTENSITON=ncd
DAT_DIR=dat
for f in img/*;do
	basename=`basename $f`;
	filename=${basename%.*}
	echo converting $filename
	ruby img2gcode.rb $f > ${DAT_DIR}/${filename}.${DAT_EXTENSITON}
done
