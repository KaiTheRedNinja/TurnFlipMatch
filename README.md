# TurnFlipMatch

## What is this game?
Inspired by a kid's toy I saw at my cousin's place. The game has a 2x2 grid of LEDs in the middle that flash with colours, and two handles that can rotate around the center. The user has to move and flip the handles (which have two colours on each side) to match the pattern in the center.

## Grid Colours
The four possible colours are:
- Red
- Green
- Blue
- Yellow

The holds have four colours each, one on either side. Each side has a clockwise and anticlockwise color. The clockwise colour is clockwise from the center of the hold, vice versa for the anticlockwise colour:

| Hold | Side 1, ACW | Side 1, CW | Side 2, ACW |  Side2, CW |
| --- | --- | --- | --- | --- |
|  1|  Red|  Green|  Blue|  Yellow|
|  2|  Red|  Yellow|  Blue| Green |

This arrangement (should?) make it possible for every possible arrangement of 4 colours arranged in a 2x2 grid (where at most one is empty) to be represented.
