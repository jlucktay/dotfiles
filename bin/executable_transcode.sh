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

tool_check ffmpeg ffprobe jq

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

if [[ $# -ne 1 ]]; then
	usage
	err "need exactly one argument; input file"
fi

input_file=$1
readonly input_file
shift

if [[ -z $input_file ]]; then
	err "no input file"
fi

if [[ ! -r $input_file ]]; then
	err "can't read input file '$input_file'"
fi

# Derive name of output file based on input file, and maybe replace the video codec while we're at it.
declare output_file=""

codec_name=$(
	ffprobe -i "$input_file" -print_format json -show_streams 2> /dev/null \
		| jq --raw-output '.streams[] | select( .codec_type == "video" ) | .codec_name'
)

# Save current state of the 'nocasematch' shell option.
if ! current_ncm_setting=$(shopt -p nocasematch); then
	:
fi

# Do case-insensitive string replacement of old codec name with new.
shopt -s nocasematch
output_file=${input_file//$codec_name/"VP9"}

# Revert to the saved/previous state of the 'nocasematch' shell option.
eval "$current_ncm_setting"

# Fix up output file extension.
output_file=${output_file%.*}.webm

if [[ -z $output_file ]]; then
	err "no output file"
fi

if [[ $output_file == "$input_file" ]]; then
	err "output file '$output_file' exactly matches input file '$input_file'"
fi

if [[ -f $output_file ]]; then
	err "output file '$output_file' already exists"
fi

if [[ ${#output_file} -lt 5 ]] || [[ ${output_file: -5} != '.webm' ]]; then
	err "output file '$output_file' should end with the '.webm' extension"
fi

input_file_base=$(basename "$input_file")
readonly input_file_base

plf_prefix="ffmpeg-passlogfile-${input_file_base// /_}-$(gdn)"
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
)

prefix_without_timestamp=${plf_prefix%-*}

# If the log file already exists (e.g. from a previous run) then skip pass 1 and use the found log file for pass 2.
if compgen_result=$(compgen -G "$prefix_without_timestamp"*); then
	existing_plf=${compgen_result%-*}
	common_flags+=(-passlogfile "$existing_plf")
else
	# Set filename prefix of log file for pass 1 to generate and pass 2 to consume.
	common_flags+=(-passlogfile "$plf_prefix")

	# Pass 1 of 2:
	#   '-an' skips audio.
	#   '-f null' sets output file format to null.
	#   '/dev/null' is where the output goes  i.e. nowhere.
	#
	# The two-pass logfile is generated in this first run.
	(
		set -x
		ffmpeg "${common_flags[@]}" -pass 1 -an -f null /dev/null
	)
fi

# Pass 2 of 2:
#   '-codec:a libopus' sets audio codec to transcode into.
#
# Google Cast and all Cast Web Receiver applications support the media facilities and types listed on this page:
# https://developers.google.com/cast/docs/media
#
# The two-pass logfile is consumed in this second run.
(
	set -x
	ffmpeg "${common_flags[@]}" -pass 2 -codec:a libopus "$output_file"
)

# TODO
# - consider options for H.264 encodings in MP4 containers as well, as AMD Video Code Engine (VCE) is a full hardware
# implementation of the video codec H.264/MPEG-4 AVC
#   - Firefox support: https://support.mozilla.org/en-US/kb/html5-audio-and-video-firefox#w_patented-media
#   - or maybe don't bother considering H.26[45]
# - (re)read/implement these:
#   - https://trac.ffmpeg.org/wiki/Encode/VP9
#   - https://developers.google.com/media/vp9/settings/vod/
# - > [libopus @ 0x121e08260] No bit rate set. Defaulting to 320000 bps.
#   256kbps should be fine for (up to) 5.1 (6 channels)
