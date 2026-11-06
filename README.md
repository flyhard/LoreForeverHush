# Lore Forever Hush

A small World of Warcraft: Forever addon that makes [Lore Forever](https://www.curseforge.com/projects/1715510) pause while [Spoken](https://www.curseforge.com/wow/addons/spoken-player) is reading a line, and continue when Spoken is done.

## What it does

- When Spoken starts a line, any Lore Forever narration that is playing is stopped (the same as `/lore stop`). A Lore Forever story that starts by itself while Spoken is talking is stopped too.
- About 1.5 seconds after Spoken goes quiet, Lore Forever continues through its own play/pause key (`LoreForever_PlaylistToggle`). Stories recorded in pieces pick up at the piece they stopped in. A story recorded as a single file starts over, because WoW cannot start a sound partway through.

## Requirements

Both **Spoken** and **Lore Forever** must be installed and enabled. The addon lists them as dependencies, so WoW won't load it without them.

## Install

Copy the `LoreForeverHush` folder (with `LoreForeverHush.toc` and `LoreForeverHush.lua`) into `World of Warcraft\_forever_\Interface\AddOns`, then `/reload`.

## Commands

- `/lfhush` turns it on or off. `/lfhush on` and `/lfhush off` set it directly.

## How it works

- Spoken's public API (`Spoken:IsPlaying()`, `Spoken:RegisterCallback("CLIP_STARTED", ...)`) tells it when Spoken speaks.
- Lore Forever has no public API, so the addon wraps `PlaySoundFile` to note the sound handles of files under `Interface\AddOns\LoreForever*`, and checks them with `C_Sound.IsPlaying`.

## License

MIT
