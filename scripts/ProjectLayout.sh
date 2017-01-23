#!/bin/bash

mkdir $1
cd $1/
touch LICENSE README.md
cp files/Makefile .
mkdir bin src tests
