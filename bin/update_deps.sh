function update_deps() {
  IMAGE=$2
  SOURCE=$3

  if [ $IMAGE ] && [ $SOURCE ]; then
    VERSION=$(current_version $IMAGE)
    SOURCE_VERSION=$(current_version $SOURCE)
  else
    help
  fi

}
