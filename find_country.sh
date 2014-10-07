HOST=$1
IP=`dig ${HOST} | egrep 'IN\tA\t' | awk '{print $5}' | head -n 1`
geocode $IP | grep -i country

