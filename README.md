# Urucu Navigator

This repository contains an experimental navigator of code dependencies with Pharo.

## Install

Evaluate the following script in a Pharo (7, 8 or 9 should work):

~~~smalltalk
Metacello new
    baseline: 'BaselineBuilder';
    repository: 'github://tinchodias/pharo-metacello-baseline-builder';
    load.
~~~

## Where to start

* Code dependencies: See examples in class side of `HiMNavigator`.
* Code dependencies in Spec2 + Search: `HiMNavigatorPresenter defaultSpec`.
* Extension to Roassal3 layout where rectangles repulse others: Run `RSRectangleRepulsionForceLayout` class side examples.

---

## What is *urucu*?

Urucú is one of the names of [this tree and fruit](https://es.wikipedia.org/wiki/Bixa_orellana) in South America:

![Plant](https://upload.wikimedia.org/wikipedia/commons/3/3c/Urucum_%28bixa_orellana%29_seeds.jpg)
