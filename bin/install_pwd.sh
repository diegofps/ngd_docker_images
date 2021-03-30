#!/bin/sh

TGT="export PATH=\"$PWD:\$PATH\""

if [ "$(cat ~/.bashrc | grep "$TGT")" = '' ]
then
  echo $TGT >> ~/.bashrc
  echo "Done!"

else
  echo "Already installed"  
fi

