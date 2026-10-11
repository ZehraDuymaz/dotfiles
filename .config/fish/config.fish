source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting / disable fastfetch
function fish_greeting
    # Leave this completely empty
end

zoxide init fish | source

# Smart Play: Accepts either a URL or a search term
function play
    echo "🎶 Loading: $argv"
    # Check if the input contains "http"
    if string match -q "*http*" $argv
        mpv --no-video --term-playing-msg="🎵 NOW PLAYING: \${media-title}" $argv
    else
        # Use ytsearch for text queries so it actually searches YouTube
        mpv --no-video --term-playing-msg="🎵 NOW PLAYING: \${media-title}" "ytdl://ytsearch:$argv"
    end
end

# YouTube Search: Fetch top 5 results like an API request
function ytfind
    echo "🔍 Fetching top 5 results for: $argv..."
    echo --------------------------------------
    # Use yt-dlp to scrape 5 results and format the output beautifully
    yt-dlp "ytsearch5:$argv" --print "🎵 %(title)s | 📺 %(channel)s" --print "   🔗 https://youtu.be/%(id)s" --print ""
end

# Interactive YouTube search and player
function ytplay
    if test -z "$argv"
        echo "Usage: ytplay <search terms >"
        return 1
    end

    echo "🔍 Searching YouTube for: $argv..."
    echo "========================================"

    # Grab the top 5 titles and video IDs quickly
    set -l results (yt-dlp --flat-playlist --print "🎵 %(title)s | 📺 %(channel)s###%(id)s" "ytsearch5:$argv" 2>/dev/null)

    if test (count $results) -eq 0
        echo "❌ No results found."
        return 1
    end

    set -l index 1
    set -l ids

    # Loop through and print the numbered menu
    for item in $results
        set -l parts (string split "###" $item)
        set -l title $parts[1]
        set -l id $parts[2]
        set -a ids $id

        echo "[$index] $title"
        set index (math $index + 1)
    end

    echo "========================================"
    # Ask the user for a choice
    read -P "Select a track (1-5) or q to cancel: " choice

    if test "$choice" = q -o -z "$choice"
        echo "Canceled."
        return 0
    end

    # Validate choice and play
    if test "$choice" -ge 1 -a "$choice" -le (count $ids)
        set -l chosen_id $ids[$choice]
        echo ""
        echo "🎶 Now Playing selection [$choice]..."
        mpv --no-video --term-playing-msg="🎵 NOW PLAYING: \${media-title}" "https://youtu.be/$chosen_id"
    else
        echo "❌ Invalid number."
    end
end
