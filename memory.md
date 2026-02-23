# Memory
- Goal: Generate a 9:16 (1080x1920) calm video from five organ PNGs with zen-style overlays and music.
- Files: heart.png, kidney.png, liver.png, spleen.png, lung.png; music.mp3; build_video.sh; intro.txt (vertical title text).
- Current look:
  - Intro (2.6s) uses heart image as background with 50% transparent overlay rectangle and vertical title "籽言双盘" from intro.txt, with fade in/out.
  - Each organ segment: 1s overlay (50% transparent) with title, fade in/out; then 5s full image; subtle zoom.
  - Crossfades between organs.
  - Font: /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc (smooth CJK).
- Output requested: next render should be named 4.mp4.
