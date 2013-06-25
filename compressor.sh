#!/bin/sh
mkdir ValueViewer
mkdir ValueViewer/example
cp example.pde ValueViewer/example
cp ValueViewer.pde ValueViewer
cp ValueViewer.pde ValueViewer/example
zip ValueViewer_$1.zip ValueViewer
rm -rf ValueViewer
