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


