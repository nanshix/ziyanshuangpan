## generate video from png pictures with ffmpeg
1. use 5 organ pngs: 心 肾 肝 脾 肺
2. create a simple script (shell or python) to build the ffmpeg filtergraph
3. target duration: 15-25s total (3-4s per organ)
4. add calm background music, trimmed to match video length
5. per-organ recipe:
   - start from still image with subtle zoom-in (1-2%)
   - apply soft dark gradient overlay for title legibility
   - show title for ~1.0-1.5s, then fade it out while image stays
   - crossfade to next organ (no hard cuts)
