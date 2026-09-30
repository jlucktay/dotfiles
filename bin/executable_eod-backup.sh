#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
	# shellcheck disable=SC1090
	source "$lib"
done

dslog "start"
trap 'dslog "finish"' 0

# Restore with rclone copy (never sync) using the same filters and no --backup-dir, source and destination swapped, then recreate the main checkout's projects/*/memory symlink into memory-stores/, which link-worktree-memory.sh never creates.

dest="$HOME/james.lucktaylor@ovo.com - Google Drive/My Drive/Claude"
base="$HOME/.claude"
today="$(date +%F)"
upload_timeout_seconds=60
upload_poll_seconds=1

rclone_flags=(
	# No remotes are used, so point rclone at an empty config rather than have it warn that its default one is missing.
	"--config=/dev/null"

	"--include=/memory-stores/**"
	"--include=/projects/*/memory/**"

	# Deleted and overwritten files move here instead of being removed; the filters above exclude it, so sync never prunes it.
	"--backup-dir=$dest/.deleted/$today"

	"--verbose"
)

# Prints one line per file under the given roots that Google Drive has not accepted; no output means every file is uploaded.
pending_uploads() {
	osascript -l JavaScript - "$@" << 'EOF'
ObjC.import('Foundation');
function run(argv) {
  const fm = $.NSFileManager.defaultManager;
  const problems = [];
  for (const root of argv) {
    const walker = fm.enumeratorAtPath(root);
    if (walker.isNil()) { problems.push('missing\t' + root); continue; }
    for (let rel = walker.nextObject; !rel.isNil(); rel = walker.nextObject) {
      const path = root + '/' + ObjC.unwrap(rel);
      const isDir = Ref();
      fm.fileExistsAtPathIsDirectory(path, isDir);
      if (isDir[0]) { continue; }
      const url = $.NSURL.fileURLWithPath(path);
      const value = (key) => { const v = Ref(); url.getResourceValueForKeyError(v, key, null); return v[0]; };
      const error = value($.NSURLUbiquitousItemUploadingErrorKey);
      const uploaded = value($.NSURLUbiquitousItemIsUploadedKey);
      if (error !== undefined && !error.isNil()) { problems.push('error\t' + path + '\t' + ObjC.unwrap(error.localizedDescription)); }
      else if (uploaded === undefined || uploaded.isNil()) { problems.push('notdrive\t' + path); }
      else if (!ObjC.unwrap(uploaded)) { problems.push('pending\t' + path); }
    }
  }
  return problems.join('\n');
}
EOF
}

tool_check jq osascript pgrep rclone

if ! pgrep -x 'Google Drive' > /dev/null; then
	err "Google Drive for desktop is not running, so nothing written to '$dest' would leave this machine."
fi

if ! [[ -d ${dest%/*} ]]; then
	err "'${dest%/*}' is missing, so Google Drive is signed out or signed in as another account; rclone would otherwise create a plain local folder in its place."
fi

backed_up_files=0

if [[ -d $dest ]]; then
	backed_up_files="$(rclone lsf "${rclone_flags[@]}" --recursive --files-only -- "$dest" | wc -l)"
fi

planned_removals="$(
	{
		rclone sync "${rclone_flags[@]}" --dry-run --use-json-log -- "$base" "$dest" > /dev/null
	} 2>&1 | jq --slurp '[.[] | select(.skipped == "move into backup dir")] | length'
)"

if ((backed_up_files > 0 && planned_removals * 2 > backed_up_files)); then
	err "Number of planned removals would be too destructive; backed up files count '$((backed_up_files))', planned removal count '$((planned_removals))'."
fi

rclone sync "${rclone_flags[@]}" -- "$base" "$dest"

deadline=$((SECONDS + upload_timeout_seconds))

while :; do
	problems="$(pending_uploads "$dest")"

	if [[ -z $problems ]]; then
		break
	fi

	if grep --quiet --invert-match '^pending' <<< "$problems" || ((SECONDS >= deadline)); then
		err "Google Drive has not accepted the backup:"$'\n'"$problems"
	fi

	sleep "$upload_poll_seconds"
done
