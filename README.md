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

Open the navigator with:

```Smalltalk
UrNavigatorPresenter example1
```

There is also an experimental Roassal3 layout where rectangles repulse other.
See `RSRectangleRepulsionForceLayout` examples on class-side.

---

## License

The code is licensed under [MIT](LICENSE).

## What is *urucu*?

Urucú is one of the names of [this tree and fruit](https://es.wikipedia.org/wiki/Bixa_orellana) in South America:

![Plant](https://upload.wikimedia.org/wikipedia/commons/3/3c/Urucum_%28bixa_orellana%29_seeds.jpg)
