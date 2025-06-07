# Program / Bash aliases

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# make stuff colourful
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# alias to always use more safe rm/mv (asks when deleting more than 3 things)
alias rm='rm -I'
alias mv='mv -i'

# make a new dir with the current date as name
alias mdd='mkdir $(date -I)'

# alias for easyer pacman update
alias pacdate='sudo pacman -Syu'

# pacman install alias
alias pacget='sudo pacman -S'

# pacman search alias
alias pacs='pacsearch'
alias pacfiles='pacman -F'  # search which pkg contains a specific file

# search all currently installed pacman pkgs
alias pacsi='pacman -Qq | fzf --preview "'"pacman -Qil {}"'" --layout=reverse --bind "'"enter:execute(pacman -Qil {} | less)"'"'
alias pacsall='pacman -Slq | fzf --preview "'"pacman -Si {}"'" --layout=reverse'

# alias for untaring things
alias untar='tar -xvf'

# powertop alias
alias pwrtp='sudo powertop'

######### Use modern alternatives of the standard unix commands ##########
# use lsd instead of ls if available
#if $(command -v lsd >/dev/null 2>&1) ; then
#   alias ls='lsd'
#fi
# use fd instead of find if available
#if $(command -v fd >/dev/null 2>&1) ; then
#   alias find='fd'
#fi
#########

# make ls output readable for humans
alias lsl='ls -lh'
alias lst='ls -lht'
alias perms="stat -c '%a - %n'"

# creating an awk calculator invoked by clc ARGS
clc () { awk "BEGIN{ pi = 4.0*atan2(1.0,1.0); deg = pi/180.0; print $* }" ;}

# hex/dec conversion shortcut
alias h2d='printf "%d\n"'
alias d2h='printf "%x\n"'
alias h2b='printf "\$*" | xxd -b | cut -d" " -f2'

# alias for todo.txt todo app
alias t='todo.sh -antc'
alias tls='todo.sh -antc ls'
alias tlss='todo.sh -antc ls | grep +sento'

# git shortcuts
alias gits='git status'
alias guncommit='git reset --soft HEAD~'
# pulls the remote branch with the same name as the local branch
alias gpl='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gps="git push origin HEAD"
alias gpsall='for i in `git remote`; do echo "Pushing to:" $i; git push $i; done;'
alias gitl='git log --all --decorate --oneline --graph'
alias gitf='git fetch --all -p'
alias gitdiff='GIT_EXTERNAL_DIFF=difft git log -p --ext-diff'
alias gbcp='git branch --show-current | wl-copy'
alias gsm='git switch main'
alias lgit='lazygit'

# clones a git dir without fsck'ing contents --> for old repos & new git
alias gitc-nofsck='git clone --config transfer.fsckobjects=false --config receive.fsckobjects=false --config fetch.fsckobjects=false'

# function which deletes already merged git branches locally
clean_git_branches() {
    git switch main
    git fetch --all --prune
    git branch -v

    echo "Check if you saw any unpushed branches. If so ABORT with Ctrl+C"
    read -p "If there were no unpushed branches, continue to DELETE? (n/N/Y)" -n 1 -r
    echo  # move to a new line
    if [[ $REPLY =~ ^[Y]$ ]]
    then
	num_deleted_branches=$(git branch --merged main | grep -c -v '^[ *]*main$')
	git branch --merged main | grep -v '^[ *]*main$' | xargs git branch -d
	echo "Deleted $num_deleted_branches branche(s)."
    fi
}

# inspecting a CSR record in plain text, the last part should be the CSR path
alias csrinsp='openssl req -noout -text -in'
alias cerinsp='openssl x509 -noout -text -in'  # att: CER can have PEM or DER encodings
alias peminsp='openssl x509 -inform pem -noout -text -in'
alias derinsp='openssl x509 -inform der -noout -text -in'
# convert a p7b certificate to cer, do p7btocer file.p7b
alias p7btocer='openssl pkcs7 -inform DER -outform PEM -print_certs > certificate_bundle.cer -in'

# build pipeline, docker
alias docker-compose='docker compose'
# stop all running docker containers
alias dockerstop='docker ps -aq | xargs docker stop'
alias dockerstoprm='docker ps -aq | xargs docker stop | xargs docker rm'
alias dops='docker ps --format '\''table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'\'''
alias dokillvol='docker volume rm $(docker volume ls -q)'

# gpg related
alias gpt='gpg-tui -a -s colored'

# zellij instead of tmux/screen
alias zj='zellij'

# simple youtube play. Since yt 4k you need to stream vid and audio seperately
yplay() {
    YTDL_OUT=$(yt-dlp "$1" --get-url);
    URLS=($(echo "$YTDL_OUT" | tr ',' '\n'))
    vlc "${URLS[0]}" --input-slave "${URLS[1]}"
}

# play youtube audio looped in terminal
function ytp() {
    mpv --keep-open --loop --ytdl-format=bestaudio "$*"
}

# search youtube and play best audio version with mpv
function yta() {
    mpv --keep-open --loop --ytdl-format=bestaudio ytdl://ytsearch:"$*"
}

# show active network connections
alias conns='ss -tan'
alias connsd='ss -ta'
alias ports='ss -tulanp'
alias procports='sudo ss -tulanp'

# grep pdf's
pdfgrep () { find . -name '*.pdf' -exec bash -c "pdftotext '{}' - | grep -i --with-filename --label='{}' --color '$*'" \; ;}

# gs pdfmerge !!DOES NOT WORK WITH SPACES IN FILENAME?!!
pdfgsmerge () { gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged.pdf $* ;}

# compresses a pdf using ghostcript
pdfcompress() { ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf -q -dNOPAUSE -dBATCH -dSAFER -dPDFA=2 -dPDFACompatibilityPolicy=1 -dSimulateOverprint=true -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dAutoRotatePages=/None -dColorImageDownsampleType=/Bicubic -dColorImageResolution=150 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=150 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=150 $1 ;}

# extracts pages out of a pdf
pdfextract() { gs -dBATCH -sOutputFile=extracted_p$2-p$3.pdf -dFirstPage=$2 -dLastPage=$3 -sDEVICE=pdfwrite $1 ;}

# to make all PDF scan functions work, make sure gs >= 9.24 and adjust the
# imagemagick policies, as written here: https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion

# makes the input PDF look as if it has been scanned. Outputs to
# $filename_scanned.pdf appending small or bad for the other cases.
pdfscan() {
    OUT=$(basename "$1" .pdf)
    convert -density 150 "$1" -colorspace gray -linear-stretch 3.5%x10% \
            -blur 0x0.5 -attenuate 0.25 +noise Gaussian -rotate 0.5 temp.pdf
    gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
       -sColorConversionStrategy=LeaveColorUnchanged \
       dAutoFilterColorImages=true -dAutoFilterGrayImages=true \
       -dDownsampleMonoImages=true -dDownsampleGrayImages=true \
       -dDownsampleColorImages=true -sOutputFile="$OUT"_scanned.pdf temp.pdf
    rm temp.pdf
}

# takes a pdf and produces an output which looks like it has been scanned.
# src: https://gist.github.com/andyrbell/25c8632e15d17c83a54602f6acde2724
pdfscanimg() {
    OUT=$(basename "$1" .pdf)
    convert -density 150 "$1" -rotate "$([ $((RANDOM % 2)) -eq 1 ] && echo -)0.$((RANDOM % 4 + 5))" \
        -attenuate 0.4 +noise Multiplicative -attenuate 0.03 +noise Multiplicative -sharpen 0x1.0 \
        -colorspace Gray "$OUT"_scanned.pdf
}

pdfscansmall() {
    OUT=$(basename "$1" .pdf)
    convert "$1" -alpha Off -density 150 -colorspace gray -blur 0.5x0.5 \
            -rotate 0.4 -level 40%,60% "$OUT"_scanned-small.pdf
}

pdfscannbad() {
    OUT=$(basename "$1" .pdf)
    convert "$1" -colorspace gray \( +clone -blur 0x1 \) +swap -compose divide \
            -composite -linear-stretch 5%x0% -rotate 1.5 "$OUT"_scanned-bad.pdf
}

# find and grep
function fgr {
    NAM=""
    GREPTYPE="-i -H"
    if [ -n "$1" ]; then
	test -n "$2" && NAM="-name \"$2\""
	test -n "$3" && GREPTYPE=$3
	CMMD="find . $NAM -not -path '*/\.*' -exec egrep --colour=auto $GREPTYPE \"$1\" {} + 2>/dev/null"
	>&2 echo -e "Running: $CMMD\n"
	sh -c "$CMMD"
	echo ""
    else
	echo -e "Expected: fgr <search> [file filter] [grep opt]\n"
    fi
}

# grep through all file types with fzf
rga-fzf() {
    RG_PREFIX="rga --files-with-matches"
    local file
    file="$(
	FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
	    fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
	    --phony -q "$1" \
	    --bind "change:reload:$RG_PREFIX {q}" \
	    --preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	    xdg-open "$file"
}
alias rgaf='rga-fzf'
alias fzx='fzfx .'
alias fcd='cd "$(fzfx cd)"'

# launch ranger in the downloads folder
alias rando='ranger ~/Downloads'

# pretty print json output
ppjson () { echo "$1" | python -m json.tool ;}
alias prettyjson='python -m json.tool'

# inspect a json (all in the current dir) live with jq and fzf for preview
jsoninspect() {
    echo '' | fzf --print-query --preview "cat *.json | jq {q}"
}

# show disk use of subdirs sorted by size
alias subdirsize='du -d 1 -h | sort -hr | egrep -v ^0'

# find files with names which cant be used on exfat/ntfs
findbadnames() { find . -name '*[?<>\\:*|\"]*' ;}

# get synonyms from thesaurus.com
the() { ~/ext-progs/synonym/synonym "$1" ;}

# for python projects, source venv from .venv
alias svenv='source .venv/bin/activate'
alias mkvenvs='python -m venv .venv --system-site-packages'
alias mkvenv='python -m venv .venv'
alias mkuenv='uv venv .venv'
alias mkuenvs='uv venv .venv --system-site-packages'
alias ppt='poetry run -- pytest -vv'
alias pptlf='poetry run -- pytest -vv --last-failed'
alias ppted='poetry run -- pytest -vv --picked'
alias pptx='poetry run -- pytest -n 8 --dist worksteal --ff-inverse -vv'

# kubernetes k8s stuff
alias kctl='kubectl'
alias kpipesh='kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf | xargs -I{ppln} kubectl exec --stdin --tty {ppln} -- /bin/bash'
alias klistcont='kubectl get pods --all-namespaces -o jsonpath='\''{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}'\'' | sort'

# date conversions
alias epoch2date='date -d'

# pass and gopass fzf
gop(){
  QUERY=$1
  if [ -z "$QUERY" ]; then
    QUERY=''
  fi
  gopass show -n \
    "$(gopass ls --flat | fzf -q "$QUERY" --preview "gopass show {}")"
}

# eval "$(fzf --bash)"
