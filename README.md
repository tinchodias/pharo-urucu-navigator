# Urucu Navigator

[![Complete Test](https://github.com/tinchodias/pharo-urucu-navigator/actions/workflows/test.yml/badge.svg)](https://github.com/tinchodias/pharo-urucu-navigator/actions/workflows/test.yml)

An experimental navigator of code dependencies with Pharo and [Roassal3](https://github.com/ObjectProfile/Roassal3).

![Demo GIF](https://media.giphy.com/media/jERUcF0GFZPOTngb09/giphy.gif)


## Install

Evaluate the following script in a Pharo (9  or 10 should work):

~~~smalltalk
Metacello new
    baseline: 'UrucuNavigator';
    repository: 'github://tinchodias/pharo-urucu-navigator';
    load.
~~~

## Where to start

Open the navigator with:

```Smalltalk
UrMainPresenter example2medium
```

There is also an experimental Roassal3 layout where rectangles repulse other.
See `RSRectangleRepulsionForceLayout` examples on class-side.

## License

The code is licensed under [MIT](LICENSE).

## What is the *urucu* word? 

Urucú is one of the names of [this tree and fruit](https://es.wikipedia.org/wiki/Bixa_orellana) in South America:

![Plant](https://upload.wikimedia.org/wikipedia/commons/3/3c/Urucum_%28bixa_orellana%29_seeds.jpg)
