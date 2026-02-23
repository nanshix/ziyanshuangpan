#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build_video.sh music.mp3 output.mp4
# Defaults:
#   music.mp3, output.mp4

MUSIC_FILE="${1:-music.mp3}"
OUTPUT_FILE="${2:-output.mp4}"

if [[ ! -f "$MUSIC_FILE" ]]; then
  echo "Missing music file: $MUSIC_FILE"
  echo "Please place your audio file (mp3) in this folder and retry."
  exit 1
fi

FONT_FILE="/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc"
if [[ ! -f "$FONT_FILE" ]]; then
  echo "Missing font file: $FONT_FILE"
  exit 1
fi

OVERLAY_DUR="1.0"
REAL_DUR="5.0"
DUR="6.0"          # seconds per image (1.0 overlay + 5.0 real)
INTRO_DUR="2.6"
XF_DUR="0.8"       # crossfade duration
TOTAL="29.4"       # intro 2.6 + (5*6.0 - 4*0.8) = 29.4
FPS="30"
W="1080"
H="1920"
SIZE="${W}x${H}"
BOX_W=$((W*70/100))
BOX_H=$((BOX_W*3/2))
BOX_X=$(((W-BOX_W)/2))
BOX_Y=$(((H-BOX_H)/2))
FADE_DUR="0.8"
FADE_OUT_START="$(awk "BEGIN{printf \"%.2f\", ${OVERLAY_DUR}-${FADE_DUR}}")"

INTRO_FADE_IN="0.5"
INTRO_FADE_OUT="0.5"
INTRO_FADE_OUT_START="$(awk "BEGIN{printf \"%.2f\", ${INTRO_DUR}-${INTRO_FADE_OUT}}")"

# Intro title timing (seconds)
INTRO_TITLE_IN="0.4"
INTRO_TITLE_HOLD="1.6"
INTRO_TITLE_OUT="0.6"
INTRO_TITLE_END="${INTRO_DUR}"
INTRO_TEXT_FILE="intro.txt"

OFFSET_1="5.2"
OFFSET_2="10.4"
OFFSET_3="15.6"
OFFSET_4="20.8"

# Title timing (seconds)
TITLE_IN="0.2"
TITLE_HOLD="0.6"
TITLE_OUT="0.2"
TITLE_END="1.0"

ffmpeg -y \
  -loop 1 -t "$DUR" -i heart.png \
  -loop 1 -t "$DUR" -i kidney.png \
  -loop 1 -t "$DUR" -i liver.png \
  -loop 1 -t "$DUR" -i spleen.png \
  -loop 1 -t "$DUR" -i lung.png \
  -stream_loop -1 -i "$MUSIC_FILE" \
  -filter_complex "
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${DUR},format=yuva420p,
      fade=t=in:st=0:d=${FADE_DUR}:alpha=1,
      fade=t=out:st=${FADE_OUT_START}:d=${FADE_DUR}:alpha=1[box0];
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${DUR},format=yuva420p,
      fade=t=in:st=0:d=${FADE_DUR}:alpha=1,
      fade=t=out:st=${FADE_OUT_START}:d=${FADE_DUR}:alpha=1[box1];
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${DUR},format=yuva420p,
      fade=t=in:st=0:d=${FADE_DUR}:alpha=1,
      fade=t=out:st=${FADE_OUT_START}:d=${FADE_DUR}:alpha=1[box2];
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${DUR},format=yuva420p,
      fade=t=in:st=0:d=${FADE_DUR}:alpha=1,
      fade=t=out:st=${FADE_OUT_START}:d=${FADE_DUR}:alpha=1[box3];
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${DUR},format=yuva420p,
      fade=t=in:st=0:d=${FADE_DUR}:alpha=1,
      fade=t=out:st=${FADE_OUT_START}:d=${FADE_DUR}:alpha=1[box4];
    color=c=black@0.50:s=${BOX_W}x${BOX_H}:d=${INTRO_DUR},format=yuva420p,
      fade=t=in:st=0:d=${INTRO_FADE_IN}:alpha=1,
      fade=t=out:st=${INTRO_FADE_OUT_START}:d=${INTRO_FADE_OUT}:alpha=1[introbox];
    [0:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.01,1+0.0003*on)':d=78:s=${SIZE}:fps=${FPS},
         trim=duration=${INTRO_DUR},setpts=PTS-STARTPTS[introbase];
    [introbase][introbox]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
      drawtext=fontfile=${FONT_FILE}:textfile=${INTRO_TEXT_FILE}:fontsize=110:fontcolor=white@0.95:line_spacing=18:
               x=(w-text_w)/2:y=(h-text_h)/2:
               alpha='if(lt(t,${INTRO_TITLE_IN}),t/${INTRO_TITLE_IN},if(lt(t,${INTRO_TITLE_IN}+${INTRO_TITLE_HOLD}),1,if(lt(t,${INTRO_TITLE_END}),(${INTRO_TITLE_END}-t)/${INTRO_TITLE_OUT},0)))'
      [intro];
    [0:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.02,1+0.0005*on)':d=135:s=${SIZE}:fps=${FPS}[base0];
    [base0][box0]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
         drawtext=fontfile=${FONT_FILE}:text='心':fontsize=96:fontcolor=white@0.92:
                  x=(w-text_w)/2:y=(h-text_h)/2:
                  alpha='if(lt(t,${TITLE_IN}),t/${TITLE_IN},if(lt(t,${TITLE_IN}+${TITLE_HOLD}),1,if(lt(t,${TITLE_END}),(${TITLE_END}-t)/${TITLE_OUT},0)))'
         [v0];
    [1:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.02,1+0.0005*on)':d=135:s=${SIZE}:fps=${FPS}[base1];
    [base1][box1]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
         drawtext=fontfile=${FONT_FILE}:text='肾':fontsize=96:fontcolor=white@0.92:
                  x=(w-text_w)/2:y=(h-text_h)/2:
                  alpha='if(lt(t,${TITLE_IN}),t/${TITLE_IN},if(lt(t,${TITLE_IN}+${TITLE_HOLD}),1,if(lt(t,${TITLE_END}),(${TITLE_END}-t)/${TITLE_OUT},0)))'
         [v1];
    [2:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.02,1+0.0005*on)':d=135:s=${SIZE}:fps=${FPS}[base2];
    [base2][box2]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
         drawtext=fontfile=${FONT_FILE}:text='肝':fontsize=96:fontcolor=white@0.92:
                  x=(w-text_w)/2:y=(h-text_h)/2:
                  alpha='if(lt(t,${TITLE_IN}),t/${TITLE_IN},if(lt(t,${TITLE_IN}+${TITLE_HOLD}),1,if(lt(t,${TITLE_END}),(${TITLE_END}-t)/${TITLE_OUT},0)))'
         [v2];
    [3:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.02,1+0.0005*on)':d=135:s=${SIZE}:fps=${FPS}[base3];
    [base3][box3]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
         drawtext=fontfile=${FONT_FILE}:text='脾':fontsize=96:fontcolor=white@0.92:
                  x=(w-text_w)/2:y=(h-text_h)/2:
                  alpha='if(lt(t,${TITLE_IN}),t/${TITLE_IN},if(lt(t,${TITLE_IN}+${TITLE_HOLD}),1,if(lt(t,${TITLE_END}),(${TITLE_END}-t)/${TITLE_OUT},0)))'
         [v3];
    [4:v]scale=${SIZE}:force_original_aspect_ratio=decrease,
         pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,
         zoompan=z='min(1.02,1+0.0005*on)':d=135:s=${SIZE}:fps=${FPS}[base4];
    [base4][box4]overlay=x=${BOX_X}:y=${BOX_Y}:shortest=1,
         drawtext=fontfile=${FONT_FILE}:text='肺':fontsize=96:fontcolor=white@0.92:
                  x=(w-text_w)/2:y=(h-text_h)/2:
                  alpha='if(lt(t,${TITLE_IN}),t/${TITLE_IN},if(lt(t,${TITLE_IN}+${TITLE_HOLD}),1,if(lt(t,${TITLE_END}),(${TITLE_END}-t)/${TITLE_OUT},0)))'
         [v4];
    [v0][v1]xfade=transition=fade:duration=${XF_DUR}:offset=${OFFSET_1}[v01];
    [v01][v2]xfade=transition=fade:duration=${XF_DUR}:offset=${OFFSET_2}[v012];
    [v012][v3]xfade=transition=fade:duration=${XF_DUR}:offset=${OFFSET_3}[v0123];
    [v0123][v4]xfade=transition=fade:duration=${XF_DUR}:offset=${OFFSET_4}[vfinal];
    [intro][vfinal]concat=n=2:v=1:a=0[vout];
    [5:a]atrim=0:${TOTAL},afade=t=out:st=28.2:d=1.2,volume=0.85[aout]
  " \
  -map "[vout]" -map "[aout]" \
  -t "$TOTAL" \
  -r "$FPS" \
  -c:v libx264 -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  "$OUTPUT_FILE"

echo "Done: $OUTPUT_FILE"
