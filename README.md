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
  #:aether (demo-aether))
```

Run: `racket main.rkt`

This should download the demo world, unzip it, run it, and start the spell server.

If it works, you should be able to run around on a small platform.  Pressing `C` should open a spellcrafting surface where you can write one spell: `(teleport)`

If all that works, either:

* Wait patiently as I release more content and more tools for the community to release content.
* Start hacking (just know that basically all my code is subject to change).

# Try Installing a Mod!

Run: `raco pkg install https://github.com/srfoster/codespells-demo-mod.git`

Now configure your game to run with that mod installed:

```
#lang codespells

(require codespells-demo-mod)

(once-upon-a-time
  #:world  (demo-world)
  #:aether (demo-aether #:lang (codespells-demo-mod-lang #:with-paren-runes? #t)))
```

Now, when you run this, you should have a new Rune on your surface.  Wrapping that Rune in parens gives you spell that spawns some purple fire -- which is an asset packaged up in `codespells-demo-mod`.  

Of course, you'll notice that the `teleport` Rune has disappeared!  It's common that you'll want to combine mods from various places, assembling all of their Runes into your surface.  Here's how you can make the new mod play nicely with the Rune that ships with the core `codespells` package.

Essentially, we need to create a new Rune language that combines the 

```
#lang codespells

(require codespells-demo-mod)
(provide (all-from-out codespells-demo-mod)
         teleport)

(define modded-lang
  (append-rune-langs #:name (current-file-name) 
                     (demo-aether-lang)
                     (codespells-demo-mod-lang)))


(once-upon-a-time
   #:aether (demo-aether #:lang modded-lang)
   #:world  (demo-world))
```

The new language appends together the one provided by `codespells-demo-mod` and the one used by default in the `demo-aether`.   I don't want to overwhelm anyone by doing a deep dive into the Racket module system.  But here's the basic idea:

We need to tell the new Rune language where the definitions of `teleport` (defined in `codespells`) and the definition of `my-cool-particles` (defined in `codespells-demo-mod`) are.  But they are in two different places! 

So we create use the module (in this case the file) we are in `main.rkt` as a place to combine them both.  We provide `teleport` and everything from `codespells-demo-mod`.  So now its **as if** this file contained the definitions for both.  Then we use `(current-file-name)` for the `#:name` parameter of `append-rune-langs`.  So now, the Rune language knows where to go to look for the definitions when it evaluates your code.

There are other ways to do it, but this is one of the simplest if you want to keep your modded CodeSpells configuration to one file.  This same strategy will let you combine together any number of mods.  Basically just: Assemble one big Rune language out of the ones provided by the mod packages; give that language to `(demo-aether)`; and make sure your current module reprovides the definitions from the mods you're importing.










