function update_gemfile() {
  ORIGIN=$1/home/Gemfile
  DEST=$2/home/Gemfile

  for LINE in $(cat $ORIGIN | grep "^\\s*gem" | sed -e "s/.*'\\(.*\\)'.*'\(.*\)'.*/\\1:\\2/g" ); do
    GEM=$(echo $LINE | sed -e "s/\\(.*\\):\(.*\)/\\1/g")
    VERSION=$(echo $LINE | sed -e "s/\\(.*\\):\(.*\)/\\2/g")
    cat $DEST | sed "s/\\('$GEM'.*\\)'.*'/\\1'$VERSION'/g" > tmp.txt
    mv tmp.txt $DEST
    echo $GEM = $VERSION
  done
}

function update_deps() {
  IMAGE=$2
  SOURCE=$3

  if [ $IMAGE ] && [ $SOURCE ]; then
    VERSION=$(current_version $IMAGE)
    SOURCE_VERSION=$(current_version $SOURCE)
    update_gemfile $SOURCE/$SOURCE_VERSION $IMAGE/$VERSION
  else
    help
  fi

}
