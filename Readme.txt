---------
KSMod 3.2
---------



Copyright © 2005 - 2021 by Brett Kuntz. All rights reserved.



v1.1 Changes:
-------------
Fixed the Kill Counter which was counting misc related things as Kills (such as dieing, or getting Faction, ect)

v1.2 Changes:
-------------
Made the search loop in the auto-update proc ultra fast.

v1.3 Changes:
-------------
Fixed the preservation of the ECX register in the KillSounds proc. Although this wasn't an issue now, in future versions of GW, the ECX register may be used and earlier versions of KSMod will cause GW to crash.

v1.4 Changes:
-------------
Updated for massive April build.

v1.5 Changes:
-------------
Updated for July build or something.

v1.6 Changes:
-------------
Anet changed the way Graphics.dll was loaded, and thus it causes 1.5 to hang upon load. This was fixed.

v1.7 Changes:
-------------
Updated for November build.

v2.0 Changes:
-------------
Added Settings.ini file and HighDefComposite option.

v2.1 Changes:
-------------
Changed the way the auto-updater works, should be able to conquer even more GW updates. Updated to latest build.

v2.2 Changes:
-------------
Updated to latest build.

v2.3 Changes:
-------------
Updated to latest build.

v2.4 Changes:
-------------
Updated to latest build.

v2.5 Changes:
-------------
Updated to latest build and included new EXE Loader.

v2.6 Changes:
-------------
Fixed bugs in loader. Added Command Line switches to INI file.

v3.0 Changes:
-------------
-Rebuilt KSMod from the ground up. New code and much better support for newer OS's like Windows Vista and Windows 7. Hense the 3.0 major version change!
-New loader does a much better and more thorough job, it should also be more compatible with different system configurations.
-Added commenting to Settings.ini.
-Added Multi-Launch capabilities. KSMod will now virtualize Guild Wars in an environment so you can run multiple copies of the game using the same gw.exe and gw.dat! This should increase your multi-client performance significantly!
-Added two Disk I/O performance tweaks aimed at new-age computer systems. Virtualization must be enabled.

v3.1 Changes:
-------------
Fixed small compatibility bugs.

v3.2 Changes:
-------------
Fixed more small compatibility bugs.



Desc:
-----

UT99_Sound_FX: Adds the oldschool Unreal Tournament '99 (UT99) Sound Effects to Guild Wars, plus some of the new ones from DotA. A UT Sound is played every time players or NPCs are killed. To achieve chain kills you must kill the next player or NPC within 10 seconds of the last. Every new kill resets the 10 second timer, the highest chain kill availble is 15 (Godlike). Disabled by default.

High_Def_Composite: Forces the engine to load the High Definition Textures whenever possible. Make sure to use the -image command line option to download all the High Definition Textures. Enabled by default.

Virtualization: Virtualizes the Guild Wars engine and data streams allowing a user to run mutliple copies of the game while maintaining system performance. Disabled by default.

VR_DisableCache: Requires Virtualization: Disable GW's cache options, will greatly speed up disk I/O on high memory systems. Recommend Windows 7 and 2GB+ memory. Disabled by default.

Command_Line: Loads GW with these command line switches. Useful for things like -perf and -nosound. Empty by default.



Install:
--------

Extract + copy KSMod.exe, KSMod.dll, and Settings.ini into your Guild Wars folder (same dir as GW.exe), run the KSMod.exe loader.

Run the loader as many times as you want for as many GW clients as you want open.