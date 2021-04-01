#!/bin/sh

echo "\nBuilding the new package..."
sbt package

exit $?
