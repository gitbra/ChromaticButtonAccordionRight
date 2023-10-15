# Chromatic button accordion, right hand - Plugin for MuseScore

*(Tested in MuseScore 3.6.2)*

I am learning the chromatic button accordion and use MuseScore a lot to prepare my music. I needed an assistant to see at glance which buttons the right hand should press for a track, and to check the fingering in the annotations.

For what it's worth, here is the plugin for doing that! Enjoy.


## Setup

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

Put the QML file into the folder `C:\GoToFolderOf\MuseScore\plugins\`, then run MuseScore.

1. Work on your track
2. Activate the plugin `ChromaticButtonAccordionRight` in the manager (if not done already)
3. Call the plugin from the menu
4. Look at the docked accordion

![](screenshot.png)

The accordion refreshes itself every 5 seconds.


## Known limitations

- Not tested under MuseScore 4
- First track only
- First voice only for the fingering
- Selections are ignored
- 8va/8vb are unsupported
- Grace notes are unsupported
- Long notes are several notes
