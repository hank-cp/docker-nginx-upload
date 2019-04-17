#!/bin/bash

cd /opt/upload
if [ ! -d "00" ]; then
  for i in $(seq -w 00 99); do
      mkdir $i;
      for j in $(seq -w 00 99); do
          mkdir $i/$j;
      done;
  done;

  chown -R www-data:www-data .;
fi