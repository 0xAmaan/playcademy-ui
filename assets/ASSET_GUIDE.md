# Word Warriors - Asset Guide

## Sprites Needed

### Warrior Character
**What**: Small pixel art knight/warrior sprite (idle pose)
**Size**: ~32x32px or 64x64px
**Where to find**:
1. **Kenney.nl** - https://kenney.nl/assets?q=medieval
   - Look for "Tiny Dungeon" pack
   - Search "medieval characters"

2. **itch.io** - https://itch.io/game-assets/free/tag-medieval
   - Search: "medieval pixel art free"
   - Good packs: "Tiny RPG Character Asset Pack"

3. **OpenGameArt** - https://opengameart.org/art-search-advanced?keys=warrior&field_art_type_tid%5B%5D=9
   - Filter by "Sprites" and "CC0" license

**What to download**: Single warrior sprite PNG (knight with sword/shield)

### UI Icons
- Star icon (for rewards) - ~16x16px
- Sword icon - ~24x24px
- Shield icon - ~24x24px
- Gem/coin icon (optional)

**Where**: Same sites as above, or use emoji as fallback (⭐🗡️🛡️)

---

## Fonts Needed

### Header Font (Medieval/Pixel Style)
**What**: Bold, readable font for titles like "Word Warriors", "VICTORY!"
**Recommendations**:
1. **Press Start 2P** (pixel font) - https://fonts.google.com/specimen/Press+Start+2P
2. **MedievalSharp** (medieval) - https://fonts.google.com/specimen/MedievalSharp
3. **Cinzel** (elegant medieval) - https://fonts.google.com/specimen/Cinzel

**How to download**: Click "Download family" button, extract .ttf file

### Body Font (Readable)
**What**: Clean sans-serif for questions/definitions
**Recommendations**:
1. **Quicksand** (friendly, rounded) - https://fonts.google.com/specimen/Quicksand
2. **Nunito** (clean, kid-friendly) - https://fonts.google.com/specimen/Nunito

---

## How to Import to Godot

### Sprites
1. Download PNG files
2. Drop them into `assets/sprites/` folder in your project
3. Godot will auto-import them

### Fonts
1. Download .ttf files
2. Drop them into `assets/fonts/` folder
3. Use in code:
```gdscript
var custom_font = FontFile.new()
custom_font.load_dynamic_font("res://assets/fonts/PressStart2P-Regular.ttf")
label.add_theme_font_override("font", custom_font)
```

---

## Next Steps After Importing

Once you have assets in the folders, tell me and I'll:
1. Create a script to load them
2. Add warrior sprite to screens
3. Apply custom fonts to UI
4. Test everything renders correctly
