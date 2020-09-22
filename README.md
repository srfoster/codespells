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

# Create Your Own Mod

Suppose we want a mod called `my-mod`

`raco codespells my-mod`

Now open `my-mod/main.rkt` in DrRacket or an editor of your choice.  You'll see
that the following code was generated for you:

```
#lang codespells

(define-classic-rune (hello)
  #:background "blue"
  #:foreground (circle 40 'solid 'blue)
  (spawn-this-mod-blueprint "HelloWorld"))

(define-classic-rune-lang my-mod-lang
  (hello))

(module+ main
  (codespells-workspace ;TODO: Change this to your local workspace if different
   (build-path (current-directory) ".." "CodeSpellsWorkspace"))

  (once-upon-a-time
   #:world (demo-world)
   #:aether (demo-aether
             #:lang (my-mod-lang #:with-paren-runes? #t))))
```

This is some minimal code that takes care of some of the details of setting up a mod for you:

1) Defines and provides a function called `hello`
2) Defines a Rune that compiles to `hello`
3) Creates a Rune language containing the `hello` Rune, and provides it
4) Configures the Rune language to look for the definition of `hello` in this file
5) Gives you some `(module+ main ...)` code so you can test your mod prior to releasing it.
6) Gives you a place to change the appearance or behavior of the `hello` Rune.

It default to being a Rune that spawns an Unreal Blueprint packaged with this mod.  

All you need to do now is:

* Open `my-mod/Unreal/MyMod/MyMod.uproject` in Unreal
* Put a Blueprint name `HelloWorld` in the `MyMod` Plugin Content folder
* Do `File > Package Project > Windows (64-bit)`

Now run `main.rkt` and you should get a demo world with a modded Aether containing
you Rune.  Casting the spell `(hello)` should spawn your `HelloWorld` blueprint!

# Installing Mods

Installing a Mod is as simple as requiring a Racket package and altering your Aether prior to launching the game:

https://github.com/srfoster/codespells/wiki/Mod-Installation-and-Mod-Basics

# Coming soon

More documentation/tutorials about

* What else you can do in the 3D word (aside from just spawning in Blueprints)
* What else you can do with your mod's Rune language (aside from simple expressions like `(hello)`)
