#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
  # shellcheck disable=SC1090
  source "$lib"
done

# The real Dark Souls starts here.
dslog "start"
trap 'dslog "finish"' 0

tool_check ffmpeg

### Set up usage/help output
function usage() {
  cat << HEREDOC

Usage: ${SCRIPT_NAME:?} {INPUT_FILE OUTPUT_FILE | [--help]}

Will transcode INPUT_FILE into a VP9-encoded WebM OUTPUT_FILE, using two-pass
encoding and row-based multithreading.

Optional arguments:
  -h, --help          show this help message and exit

HEREDOC
}

### Get flags ready to parse given arguments
declare input_file=""
declare output_file=""

for i in "$@"; do
  case $i in
    -h | --help)
      usage
      exit 0
      ;;
    *)
      :
      ;;
  esac
done

if [[ $# -ne 2 ]]; then
  usage
  err "need exactly two arguments; input file, and output file"
fi

input_file=$1
readonly input_file
shift

output_file=$1
readonly output_file
shift

if [[ -z $input_file ]]; then
  err "no input file"
fi

if [[ ! -r $input_file ]]; then
  err "can't read input file '$input_file'"
fi

if [[ -z $output_file ]]; then
  err "no output file"
fi

if [[ -f $output_file ]]; then
  err "output file '$output_file' already exists"
fi

if [[ ${#output_file} -lt 5 ]] || [[ ${output_file: -5} != '.webm' ]]; then
  err "output file '$output_file' should end with the '.webm' extension"
fi

plf_prefix="ffmpeg-passlogfile-$(gdn)"
readonly plf_prefix

common_flags=(
  # Set input file to read from.
  -i "$input_file"

  # Set video codec to transcode into.
  # Further reading on VP9 encoding with FFmpeg:
  # https://trac.ffmpeg.org/wiki/Encode/VP9
  -codec:v libvpx-vp9

  # Set target bitrate to 1 MBit/s.
  -b:v 1M

  # Enable row-based multithreading.
  -row-mt 1

  # Set filename prefix of log file for pass 1 to generate and pass 2 to consume.
  -passlogfile "$plf_prefix"
)

# Pass 1 of 2:
#   '-an' skips audio.
#   '-f null' sets output file format to null.
#   '/dev/null' is where the output goes  i.e. nowhere.
#
# The two-pass logfile is generated in this first run.
(
  set -vx
  ffmpeg "${common_flags[@]}" -pass 1 -an -f null /dev/null
)

# Pass 2 of 2:
#   '-codec:a libopus' sets audio codec to transcode into.
#
# Google Cast and all Cast Web Receiver applications support the media facilities and types listed on this page:
# https://developers.google.com/cast/docs/media
#
# The two-pass logfile is consumed in this second run.
(
  set -vx
  ffmpeg "${common_flags[@]}" -pass 2 -codec:a libopus "$output_file"
)
