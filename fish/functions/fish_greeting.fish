# Login banner — show off OS + distro + system info via fastfetch
function fish_greeting
    command -q fastfetch; and fastfetch
end
