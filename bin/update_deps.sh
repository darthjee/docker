function update_gemfile() {
  ORIGIN=$1/home/Gemfile
  DEST=$2/home/Gemfile

  cat $ORIGIN | grep gem | sed -e "s/.*'\\(.*\\)'.*'\(.*\)'/\\1:\\2/g"
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
