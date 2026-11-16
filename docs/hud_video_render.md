# Rendering the HUD loop to video (M6-HUD)

> Goal: a short, seamless, muted looping clip of the holographic HUD
> that can be used as the optional video background
> (`HudVideoBackground`). The clip is **original code-drawn animation**
> recorded from the app itself — no copied footage, logos, or movie
> layouts (DECISIONS.md #39, #44).

## 1. Record the demo gallery

1. Run the app on a real device or emulator.
2. Open the HUD demo gallery (`HudDemoGallery` — title
   "HUD DEMO — illustrative values").
3. Set the animation level to **Full** and make sure "POS ACTIVE" is
   off, so the core runs at 600 particles / 60 fps.
4. Record the screen at **720p** with the device's built-in screen
   recorder (Android: screen recorder in Quick Settings; iOS: Control
   Centre screen recording; emulator: `adb screenrecord`).
   - Keep the phone still, portrait orientation, and record at least
     **12 seconds** of the core + data rain section so there is
     enough material to trim a clean loop.
   - Record the hero/core section, not the whole scrolling gallery:
     scroll to the "1 · HUD CORE" section and hold it.
5. Copy the raw recording to your computer, e.g. `hud_demo_raw.mp4`.

Tip: the core rotates once every ~18 seconds (`0.35 rad/s`), so a
perfect rotation-matched loop would be long. Instead trim a **6–8 s**
clip: the motion is slow and the rings/particles are dense, so a cut
at a fixed interval is visually seamless. If you can see the cut,
use the crossfade variant in step 3.

## 2. Trim to a loop and encode (exact command)

Requires `ffmpeg` (`sudo apt install ffmpeg` / `brew install ffmpeg`).

```bash
ffmpeg -y -i hud_demo_raw.mp4 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30,trim=0:8,setpts=PTS-STARTPTS" \
  -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p \
  -movflags +faststart -an hud_loop.mp4
```

What this does:

- `scale=1280:720` + `pad` — 720p, letterboxed if the recording is
  portrait (the video is shown with `BoxFit.cover`, so the centre
  crop is what matters).
- `fps=30` — 30 fps is enough for a background loop and keeps the
  file small.
- `trim=0:8` — take the first 8 seconds as the loop.
- `libx264 -crf 23 -pix_fmt yuv420p` — H.264, widely compatible
  (`video_player` on Android/iOS), correct colour format.
- `-an` — no audio (the background is always muted anyway).

Check the result:

```bash
ls -lh hud_loop.mp4          # must be < 5 MB
ffprobe -v error -show_entries format=duration,size \
  -show_entries stream=width,height,codec_name,avg_frame_rate \
  -of default=noprint_wrappers=1 hud_loop.mp4
```

If the file is over 5 MB, re-encode with a higher CRF and/or a
shorter clip — exact fallback command:

```bash
ffmpeg -y -i hud_demo_raw.mp4 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30,trim=0:6,setpts=PTS-STARTPTS" \
  -c:v libx264 -preset slow -crf 28 -pix_fmt yuv420p \
  -movflags +faststart -an hud_loop.mp4
```

### Seamless-loop variant (if the cut is visible)

Crossfade the end into the start over 1 second so the loop point
disappears (needs a 9 s source trim for an 8 s output):

```bash
ffmpeg -y -i hud_demo_raw.mp4 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30,trim=0:9,setpts=PTS-STARTPTS,split[a][b];[a]trim=0:8,setpts=PTS-STARTPTS[v0];[b]trim=8:9,setpts=PTS-STARTPTS[v1];[v0][v1]xfade=transition=fade:duration=1:offset=7,format=yuv420p" \
  -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p \
  -movflags +faststart -an hud_loop.mp4
```

## 3. Place the file and enable it

1. Copy the finished clip to `mobile_app/assets/hud_loop.mp4`.
2. Declare the asset in `mobile_app/pubspec.yaml` (owned by the
   foundation agent — ask them to add it under `flutter: assets:`):

   ```yaml
   flutter:
     assets:
       - assets/hud_loop.mp4
   ```

3. Enable it in Settings (or via `HudSettings`):
   - `hud_video_background` = `true`
   - `hud_video_background_path` = `assets/hud_loop.mp4`
4. Screens that should use it wrap their content in:

   ```dart
   HudVideoBackground(
     videoAssetPath: 'assets/hud_loop.mp4',
     child: /* screen content */,
   )
   ```

   The widget plays the clip muted and looped, pauses it when the
   screen is hidden or the app is backgrounded, and falls back to
   `HudBackground` if the file is missing or the player fails — so a
   missing video never breaks a screen.

## 4. Notes

- **No video file is bundled by default.** The HUD works fully
  without it (`HudBackground` is the fallback). Only add the clip
  when the loop has been rendered and checked (< 5 MB, 720p, H.264).
- Re-render after any HUD visual change so the video matches the
  live widgets.
- Do not ship a recording that shows real shop data: record the
  demo gallery (illustrative values) or a build with demo data only.
