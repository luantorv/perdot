#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/runtime.sh"
source "$SCRIPTS_DIR/core/plan.sh"

apply_plan() {
    while IFS='|' read -r pkg src target; do
        find "$src" -type f | while read -r file; do
            rel="${file#$src/}"
            dest="$target/$rel"

            if [[ "$DRY_RUN" == "1" ]]; then
                echo "WOULD LINK: $dest -> $file"
                continue
            fi

            mkdir -p "$(dirname "$dest")"

            if [[ -e "$dest" ]]; then
                if [[ "$FORCE" != "1" ]]; then
                    warn "Skipping existing file: $dest"
                    continue
                fi

                if [[ "$DRY_RUN" != "1" ]]; then
                    backup_file "$dest"
                    log "Backed up $dest"
                fi
            fi

            echo "$dest" >> "$TOUCHED_FILE"
            ln -sf "$file" "$dest"
            log "Linked $dest -> $file"
        done
    done < "$PLAN_FILE"
}
