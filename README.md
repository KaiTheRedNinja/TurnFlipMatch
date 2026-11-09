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
|  2|  Yellow|  Red|  Green| Blue |

This arrangement (should?) give quite a lot of possible layouts.

## Todo
- [x] Basic types
  - [x] Holds
  - [x] Main Grid
- [ ] Game Manager
  - [x] Random grid generation
  - [x] Win state detection
  - [ ] Automatic new grid generation
  - [ ] Points system
- [ ] Interaction
  - [ ] Animated interactive movement
  - [ ] Haptics
  - [ ] Gyroscope controls
- [ ] Polish (not required for game to work)
  - [ ] Victory animation
  - [ ] Skeomorphic UI
