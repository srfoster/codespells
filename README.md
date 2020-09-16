codespells
==========

A very early-stage release of CodeSpells.  Features are, as yet, minimal (compared to what you may have seen on the YouTube channel and blog).
Only works on Windows, for now. 

# Quick Installation

* Install Racket: https://racket-lang.org
* Install this repo as a package: `raco pkg install https://github.com/srfoster/codespells.git`

# Hello world

Make a directory of your choice.  I call mine `CodeSpellsWorkspace`.

Put the following in a file called `main.rkt`.

```
#lang codespells

(once-upon-a-time
  #:world  (demo-world)
  #:aether (aether-world))
```

Run: `racket main.rkt`

This should download the demo world, unzip it, run it, and start the spell server.

If it works, you should be able to run around on a small platform.  Pressing `C` should open a spellcrafting surface where you can write one spell: `(teleport)`

If all that works, either:

* Wait patiently as I release more content and more tools for the community to release content.
* Start hacking (just know that basically all my code is subject to change).

