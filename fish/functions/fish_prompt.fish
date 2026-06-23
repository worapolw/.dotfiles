# Minimal one-line prompt — eza-style "drwx" path coloring
#   <os>  ~/dev/app/src/ui/button  main * ❯
#   os    : Nerd Font logo for the running OS (Apple on macOS, distro logo on
#           Linux), brand-colored. Needs a Nerd Font (Ghostty bundles one).
#           Glyphs are written as \uXXXX escapes and expanded by printf.
#   path  : each segment cycles through eza permission colors d→r→w→x
#             d = blue (0087ff)   r = yellow (ffd700)
#             w = red  (ff5f5f)   x = green  (00d700)
#           "/" separators are white (ffffff)
#   branch: teal (00d7d7), only inside a git repo
#   *     : bright yellow (ffff5f), shown when the working tree is dirty
#   ❯     : azure (00afff) on success, red (ff0000) when the last command failed

function fish_prompt
    set -l last_status $status

    # --- OS icon (brand-colored, detected from the running OS) ----------
    set -l os_icon
    set -l os_color ffffff
    switch (uname)
        case Darwin
            set os_icon (printf '\ue711')   # apple (nf-dev-apple)
            set os_color ffffff
        case Linux
            set os_icon (printf '\uf17c')   # tux (generic linux)
            set os_color f0c000
            if test -r /etc/os-release
                switch (string match -gr '^ID=(.*)' (cat /etc/os-release) | string trim -c '"')
                    case ubuntu; set os_icon (printf '\uf31b'); set os_color e95420
                    case debian; set os_icon (printf '\uf306'); set os_color d70a53
                    case arch;   set os_icon (printf '\uf303'); set os_color 1793d1
                    case fedora rhel centos; set os_icon (printf '\uf30a'); set os_color 3c6eb4
                    case alpine; set os_icon (printf '\uf300'); set os_color 0d597f
                end
            end
        case '*'
            set os_icon (printf '\uf17c')
            set os_color f0c000
    end
    if test -n "$os_icon"
        set_color $os_color
        echo -n "$os_icon "
        set_color normal
    end

    # --- Path with per-segment drwx colors ------------------------------
    set -l colors 0087ff ffd700 ff5f5f 00d700
    set -l sep ffffff

    # Collapse $HOME to ~ (default fish style)
    set -l home_re (string escape --style=regex -- $HOME)
    set -l p (string replace -r -- "^$home_re" '~' $PWD)

    # Split into non-empty segments
    set -l segs
    for part in (string split / -- $p)
        test -n "$part"; and set -a segs $part
    end

    # Leading "/" for absolute paths outside home
    if string match -q -- '/*' $p
        set_color $sep
        echo -n /
    end

    set -l idx 0
    for s in $segs
        if test $idx -gt 0
            set_color $sep
            echo -n /
        end
        set_color $colors[(math $idx % 4 + 1)]
        echo -n $s
        set idx (math $idx + 1)
    end
    set_color normal

    # --- Git branch + dirty marker --------------------------------------
    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
    if test -n "$branch"
        set_color 00d7d7
        echo -n " $branch"
        if not command git diff --quiet --ignore-submodules HEAD 2>/dev/null
            set_color ffff5f
            echo -n " *"
        end
        set_color normal
    end

    # --- Prompt arrow ---------------------------------------------------
    if test $last_status -eq 0
        set_color 00afff
    else
        set_color ff0000
    end
    echo -n " ❯ "
    set_color normal
end
