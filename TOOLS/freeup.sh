#! /bin/sh

ipcs | cut -f 2 -d ' ' > list.txt
echo "f = File.new('list.txt', 'r'); f.each { |line| \`ipcrm -m #{line}\` }" | ruby -
rm list.txt