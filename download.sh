#!/bin/bash

if [[ "$#" -ne 1 ]]
then
  echo "Usage: $0 <year>"
  exit -1
fi

fileyear="$1"

for i in {1..2}
do
  echo "Processing ...${fileyear}_${i}"

  # Download Zip File
  curl -o On_Time_On_Time_Performance_${fileyear}_${i}.zip http://tsdata.bts.gov/PREZIP/On_Time_On_Time_Performance_${fileyear}_${i}.zip

  # Unzip the file
  unzip -o On_Time_On_Time_Performance_${fileyear}_${i}.zip

  echo "Clearning up the file..."

  # File contains " as escape character for strings and use comma as field separator. However some fields also contain comma in field values.
  # Clean up to retain comma inside a string, but delete the escape character and change field separator to |

  sed -i '1d; s/, /;/g; s/,/|/g; s/"//g; s/;/, /g' On_Time_On_Time_Performance_${fileyear}_${i}.csv

  # Delete the zip file
  rm On_Time_On_Time_Performance_${fileyear}_${i}.zip

done
