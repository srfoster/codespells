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

Essentially, we need to create a new Rune language that combines the language with `teleport` and the language with `my-cool-particles`.  A Rune language is basically:

1) A Racket module name -- which tells Racket where to find definitions for identifiers like `teleport` and `my-cool-particles`.
2) A list of pairings from identifiers to Rune images -- like `teleport` to the Rune image with the concentric green circles, and `my-cool-particles` to the Rune image with the purple geometric pattern, etc.

Thus, there are two parts to combining two existing Rune languages.  First, we need a Racket module name.  We'll come back to that.

Second, we need to append together all of the identifier->image pairings.  That's the easy part.  You can just use `append-rune-langs` for that.  See below.

```
#lang codespells

(provide (all-from-out codespells-demo-mod)
         teleport)
(require codespells-demo-mod)


(define modded-lang
  (append-rune-langs #:name (current-file-name)
                     (demo-aether-lang)
                     (codespells-demo-mod-lang)))


(once-upon-a-time
   #:aether (demo-aether #:lang modded-lang)
   #:world  (demo-world))
```

Notice that the name of the language (the Racket module that provides definitions for identifiers) is `(current-file-name)`.  As long as the current file provides definitions for all of the Runes (which it does; see the `provide`), this is a suitable "name" for the Rune language.  I don't want to overwhelm anyone by doing a deep dive into the Racket module system.  But here's the basic idea:

 We provide `teleport` and everything from `codespells-demo-mod`.  So now its **as if** `"main.rkt"` contained the definitions for both.  

There are other ways to do it, but this is one of the simplest if you want to keep your modded CodeSpells configuration to one file.  This same strategy will let you combine together any number of mods.  Basically just: Assemble one big combo Rune language out of the ones provided by various mod packages; pass that new language to the aether (e.g. `(demo-aether #:lang COMBO-LANGUAGE)`); and make sure your Rune language's name references a Racket module that reprovides the definitions from the mods you're comboing together.

There's one other neat thing you can do: Not only can you combine together two other mods, you can also **release** that combo as a new mod.  The file above can be altered as follows:

```
#lang codespells

(provide (all-from-out codespells-demo-mod)
         teleport
         modded-lang ;Provide the combined Rune language
         )

(require codespells-demo-mod)

(define modded-lang
  (append-rune-langs #:name (current-file-name)
                     (demo-aether-lang)
                     (codespells-demo-mod-lang)))

(module+ main ;Wrap once-upon-a-time, so it doesn't run when other people require your mod
  (once-upon-a-time
    #:aether (demo-aether #:lang modded-lang)
    #:world  (demo-world)))
```

Now, this file -- just like `codespells-demo-mod` -- is providing a Rune language.  And we wrapped up the `once-upon-a-time` call in `(module+ main ...)` -- which means the 3D world will only launch if you execute this file directly, not if you `require` it as a library.

Let's say you packaged up this file in a Racket package called `my-combo-mod`.  It can be easily installed now with this configuration:

```
#lang codespells

(require my-combo-mod)

(once-upon-a-time
  #:world  (demo-world)
  #:aether (demo-aether #:lang modded-lang))
```

Notice how similar this configuration is to the one earlier where we installed `codespells-demo-mod`?  The point is that mods are just Racket packages, so they can depend on each other.  Yet, a mod is a mod -- so you install it the same way regardless of its dependencies on other mods.

And as a user of a mod, you don't have to know about what mods your installed mod depends on.  You can even specify version specific mod dependencies in your mod package's `info.rkt` file.  (I won't do a tutorial here.  Anyone who has dealt with `npm`, `pip`, `maven`, or any language's packaging system should be able to figure out how Racket's system works.  Same idea.)

# Create Your Own Mod

Suppose we want a mod called `my-mod`

`raco codespells new my-mod`

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

# Coming soon

More documentation/tutorials about

* What else you can do in the 3D word (aside from just spawning in Blueprints)
* What else you can do with your mod's Rune language (aside from simple expressions like `(hello)`)
