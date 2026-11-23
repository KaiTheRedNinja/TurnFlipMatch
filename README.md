# TurnFlipMatch

<img width="603" height="1311" alt="Example" src="https://github.com/user-attachments/assets/69494af5-3633-4178-aa6b-a863c9e9d96e" />

## How to Play
1. Download TestFlight from the App Store
2. Download TurnFlipMatch [here](https://testflight.apple.com/join/fT48EBJt)
3. Launch the app and play the tutorial!

## What is this game?
Inspired by a kid's toy I saw at my cousin's place. The game has a 2x2 grid of LEDs in the middle that flash with colours, and two handles that can rotate around the center. The user has to move and flip the handles (which have two colours on each side) to match the pattern in the center.

My sister and I found the physical toy very addictive to play with, and I wanted to try and capture the same feeling but with a portable (and less conspicuous) app. This was mostly an exercise in working with gestures and rotation - since the holds only rotate horizontally, I have to do a lot of trigonometry to figure out what the gesture movements correspond to in radial coordinates.

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
- [x] Game Manager
  - [x] Random grid generation
  - [x] Win state detection
  - [x] Automatic new grid generation
  - [x] Points system
- [x] Interaction
  - [x] Animated interactive movement
  - [x] Haptics
  - [x] ~~Gyroscope controls~~ tried and failed
- [x] Polish (not required for game to work)
  - [x] Victory animation
  - [x] Skeomorphic UI
- [x] Tutorial
  - [x] Rotating
  - [x] Flipping
