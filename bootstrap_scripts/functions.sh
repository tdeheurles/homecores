inject() {
  file_to_insert=$1
  file_where_to_insert=$2
  marker=$3

  echo "    $1"
  sed "/Standard/i $marker" $file_where_to_insert \
  | sed -e "/$marker/r $file_to_insert" > $tmp
  sed "s|$marker||g" $tmp > $file_where_to_insert
}
