#!/bin/bash

markdown_py -o html5 $1.md > $1.html 
if [ "$2" = null ]; then
    wkhtmltopdf --page-size letter -B 20mm -T 20mm -L 20mm -R 20mm $1.html $1.pdf
else
    if [ ! -d "$2" ]; then
          mkdir $2
    fi
    wkhtmltopdf --page-size letter -B 20mm -T 20mm -L 20mm -R 20mm $1.html $2/$1.pdf
fi
    rm -f $1.html
