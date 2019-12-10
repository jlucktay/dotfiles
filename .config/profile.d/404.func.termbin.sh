function tb() {
  echo "Sending '$*' to termbin..."
  nc termbin.com 9999 < "$*"
}
