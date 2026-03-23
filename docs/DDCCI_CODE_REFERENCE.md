# DDC/CI Code Reference

This document now follows the softMCCS grouping order from `img/1.png` to `img/6.png`.

Rules used in the current UI:

- Group titles follow the softMCCS screenshots.
- If a row can be mapped to an existing code and current read/write path with high confidence, it is wired to a Tile.
- If the row exists in softMCCS but the current project does not have a reliable data source or mapping, it is rendered as `PlaceholderListTile` and left empty.
- `toggle` style controls continue to use `ComboBoxListTile`.

Status labels used below:

- `Implemented`: bound to an actual Tile and code path.
- `Placeholder`: present in UI, but left empty on purpose.

## Display Identification

| Item | Status | Tile / Source |
| --- | --- | --- |
| Manufacturer name | Implemented | `StaticTextListTile`, source `monitor.description` |
| Product code | Implemented | `StaticTextListTile`, source `ParsedCapabilities.model` |
| Serial number | Placeholder | `PlaceholderListTile` |
| Manufactured | Placeholder | `PlaceholderListTile` |
| EDID version | Placeholder | `PlaceholderListTile` |
| Input type | Placeholder | `PlaceholderListTile` |
| Preferred timing | Placeholder | `PlaceholderListTile` |
| Extension blocks | Placeholder | `PlaceholderListTile` |
| Raw data | Placeholder | `PlaceholderListTile` |
| DDC/CI | Implemented | `StaticTextListTile`, source `readCapabilitiesProvider` success/error state |

## Command Interface

| Item | Status | Tile / Source |
| --- | --- | --- |
| Capabilities string | Implemented | `StaticTextListTile`, source `ParsedCapabilities.raw` |
| Control codes supported | Implemented | `StaticTextListTile`, source `supportedCommands` and `supportedVcpCodes` |
| Current timing | Placeholder | `PlaceholderListTile` |
| MCCS compliance | Implemented | `StaticTextListTile`, source `ParsedCapabilities.mccsVersion` |
| Command-line editor | Placeholder | `PlaceholderListTile` |

## Display control

| Item | Status | Tile / Source |
| --- | --- | --- |
| Horizontal frequency - `0xAC` | Placeholder | `PlaceholderListTile` |
| Vertical frequency - `0xAE` | Placeholder | `PlaceholderListTile` |
| Display usage time - `0xC0` | Implemented | `TextListTile` |
| Display controller type - `0xC8` | Implemented | `TextListTile` |
| Display firmware level - `0xC9` | Implemented | `TextListTile` |
| OSD enable - `0xCA` | Implemented | `ComboBoxListTile` |
| OSD language - `0xCC` | Implemented | `ComboBoxListTile` with expanded softMCCS language option map |
| Power mode - `0xD6` | Implemented | `ComboBoxListTile` with explicit power mode option map |
| VCP version - `0xDF` | Implemented | `TextListTile` |

## Preset operations

| Item | Code | Status | Tile |
| --- | --- | --- | --- |
| Restore factory defaults | `0x04` | Implemented | `ActionListTile` |
| Restore factory luminance/contrast defaults | `0x05` | Implemented | `ActionListTile` |
| Restore factory geometry defaults | `0x06` | Implemented | `ActionListTile` |
| Restore factory color defaults | `0x08` | Implemented | `ActionListTile` |
| Settings | `0xB0` | Implemented | `ActionListTile` |

## Geometry

All rows in this group are currently wired, based on the code labels visible in the softMCCS screenshots, except the known placeholders listed at the end.

Implemented rows:

- `0x20` Horizontal position (phase)
- `0x22` Horizontal size
- `0x24` Horizontal pincushion
- `0x26` Horizontal pincushion balance
- `0x28` Horizontal convergence R/B
- `0x29` Horizontal convergence M/G
- `0x2A` Horizontal linearity
- `0x2C` Horizontal linearity balance
- `0x30` Vertical position (phase)
- `0x32` Vertical size
- `0x34` Vertical pincushion
- `0x36` Vertical pincushion balance
- `0x38` Vertical convergence R/B
- `0x39` Vertical convergence M/G
- `0x3A` Vertical linearity
- `0x3C` Vertical linearity balance
- `0x40` Vertical parallelogram
- `0x41` Vertical parallelogram balance
- `0x42` Horizontal keystone
- `0x43` Vertical keystone
- `0x44` Rotation
- `0x46` Top corner flare
- `0x48` Top corner hook
- `0x4A` Bottom corner flare
- `0x4B` Bottom corner hook
- `0x82` Horizontal mirror (H)
- `0x84` Vertical mirror (V)
- `0x86` Display scaling
- `0xDA` Scan mode (TV)

Placeholder rows in the same `Geometry` group:

- `0x95` Window position (T,L)
- `0x96` Window position (T,R)
- `0x97` Window position (B,L)
- `0x98` Window position (B,R)

## Image adjustment

`Image adjustment` is the real group. The following rows are group-internal items, not separate groups.

Implemented rows:

- `0x0B` Color temperature increment
- `0x0C` Color temperature request
- `0x0E` Clock
- `0x10` Luminance
- `0x11` Flash tone enhancement
- `0x12` Contrast
- `0x13` Backlight control
- `0x14` Select color preset
- `0x16` Red video gain
- `0x18` Green video gain
- `0x1A` Blue video gain
- `0x1F` Auto color setup
- `0x6C` Red video black level
- `0x6E` Green video black level
- `0x70` Blue video black level
- `0x87` Sharpness
- `0xA2` Auto setup on/off
- `0xD4` Stereo video mode
- `0xDC` Display application

Placeholder rows in the same `Image adjustment` group:

- `0x17` User color compensation
- `0x1C` Focus
- `0x2E`, `0x3E`, `0x56`, `0x58`
- `0x59` to `0x5E`
- `0x72`, `0x73`, `0x74`, `0x75`
- `0x7C`, `0x7D`, `0x7E`, `0x7F`, `0x81`
- `0x88`, `0x8A`, `0x8E`, `0x90`, `0x92`, `0x9A`
- `0x9C` to `0xA0`
- `0xA4`, `0xA5`, `0xA6`, `0xA7`, `0xAA`

## Audio functions

| Item | Status | Tile / Source |
| --- | --- | --- |
| Speaker volume - `0x62` | Implemented | `SiderListTile` |
| Microphone volume - `0x64` | Implemented | `SiderListTile` |
| Audio mute - `0x8D` | Implemented | `ComboBoxListTile` |
| Treble - `0x8F` | Implemented | `SiderListTile` |
| Bass - `0x91` | Implemented | `SiderListTile` |
| Balance - `0x93` | Implemented | `SiderListTile` |
| Stereo mode - `0x94` | Implemented | `ComboBoxListTile` |

## DPVL functions

The current UI only reproduces the rows as placeholders:

- Monitor status - `0xB7`
- Packet count
- Monitor x origin - `0xB9`
- Monitor y origin - `0xBA`
- Header error count - `0xBB`
- Body CRC error count - `0xBC`
- Client ID - `0xBD`
- Link shutdown is disabled

## Miscellaneous functions

| Item | Status | Tile / Source |
| --- | --- | --- |
| Degauss - `0x01` | Implemented | `ActionListTile` |
| New control value - `0x02` | Implemented | `NumericListTile` |
| Soft controls - `0x03` | Implemented | `ActionListTile` |
| Last value control - `0x52` | Implemented | `NumericListTile` |
| Performance preserve - `0x54` | Placeholder | `PlaceholderListTile` |
| Input select - `0x60` | Implemented | `ComboBoxListTile` with softMCCS-aligned input source options |
| Ambient light sensor - `0x66` | Implemented | `ComboBoxListTile` |
| Remote procedure call | Placeholder | `PlaceholderListTile` |
| EDID operation - `0x78` | Placeholder | `PlaceholderListTile` |
| TV channel up/down | Placeholder | `PlaceholderListTile` |
| Flat panel sub-pixel layout - `0xB2` | Placeholder | `PlaceholderListTile` |
| Source timing mode - `0xB4` | Placeholder | `PlaceholderListTile` |
| Display technology type - `0xB6` | Implemented | `TextListTile` |
| Display descriptor length - `0xC2` | Placeholder | `PlaceholderListTile` |
| Display descriptor to transmit - `0xC3` | Placeholder | `PlaceholderListTile` |
| Enable display of display descriptor - `0xC4` | Placeholder | `PlaceholderListTile` |
| Application enable key - `0xC6` | Placeholder | `PlaceholderListTile` |
| Display enable key - `0xC7` | Placeholder | `PlaceholderListTile` |
| Status indicators - `0xCD` | Placeholder | `PlaceholderListTile` |
| Auxiliary display size - `0xCE` | Placeholder | `PlaceholderListTile` |
| Auxiliary display data - `0xCF` | Placeholder | `PlaceholderListTile` |
| Output select - `0xD0` | Implemented | `ComboBoxListTile` |
| Operation mode | Placeholder | `PlaceholderListTile` |

## Manufacturer specific

The UI now follows the screenshot by showing a dedicated `Manufacturer specific` group.

- Placeholder rows:
  - `0xE0` to `0xFC`
  - `0xFE`
- Implemented rows:
  - `0xFD`
  - `0xFF`

## Current Implementation Notes

- The current screen is intentionally screenshot-shaped before it is fully data-complete.
- Unknown rows are left empty instead of being mapped to the wrong code.
- The UI still uses explicit hardcoded Tile calls in `main.dart`.
