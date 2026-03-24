#!/bin/bash

# Build all .md files in posts/ into .html files using pandoc

TEMPLATE="templates/post.html"
POSTS_DIR="posts"
POSTS_HTML="posts.html"
HIDDEN="hidden-posts.txt"

# Build each markdown post into HTML
for md_file in "$POSTS_DIR"/*.md; do
    [ -f "$md_file" ] || continue
    html_file="${md_file%.md}.html"
    echo "Building $md_file -> $html_file"
    pandoc "$md_file" --template="$TEMPLATE" -o "$html_file"
done

# Regenerate the posts listing page
echo "Updating $POSTS_HTML"

cat > "$POSTS_HTML" <<'HEADER'
<!DOCTYPE html>
<html>
<head>
    <title>Posts</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <nav>
        <a href="index.html">Home</a>
        <a href="posts.html" class="active">Posts</a>
    </nav>
    <h1>Posts</h1>
    <ul>
HEADER

# Collect posts with dates, sort by date descending
for md_file in "$POSTS_DIR"/*.md; do
    [ -f "$md_file" ] || continue
    filename=$(basename "$md_file")
    # Skip hidden posts
    if [ -f "$HIDDEN" ] && grep -qxF "$filename" "$HIDDEN"; then
        echo "Skipping hidden post: $filename" >&2
        continue
    fi
    title=$(pandoc --template=templates/title.html "$md_file" -t html)
    date=$(pandoc --template=templates/date.html "$md_file" -t html)
    slug=$(basename "${md_file%.md}")
    echo "$date|$title|$slug"
done | sort -t'|' -k1 -r | while IFS='|' read -r date title slug; do
    cat >> "$POSTS_HTML" <<ENTRY
        <li>
            <a href="posts/${slug}.html">${title}</a>
            <span class="post-date"> — ${date}</span>
        </li>
ENTRY
done

cat >> "$POSTS_HTML" <<'FOOTER'
    </ul>
</body>
</html>
FOOTER

echo "Done!"
