Class {
	#name : #UrRectangleRepulsionForceLayout,
	#superclass : #RSForceBasedLayout,
	#instVars : [
		'repulsionForce'
	],
	#category : #'UrucuNavigator-UI-Experimental'
}

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> exampleBoth [
	self
		exampleON;
		exampleOFF
]

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> exampleOFF [
	^ self openWithLayoutClass: RSForceBasedLayout
]

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> exampleON [
	^ self openWithLayoutClass: UrRectangleRepulsionForceLayout
]

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> newBoxes [
	| labeled boxes proto colorScale |
	labeled := RSLabeled new.
	labeled shapeBuilder labelShape scaleBy: 0.5.
	labeled location middle.

	proto :=
		RSBox new
			addInteraction: labeled;
			addInteraction: RSDraggable;
			yourself.

	colorScale := RSColorPalette qualitative flatui113.
	
	boxes := (1 to: 20) collect: [ :each | 
		proto copyWithAnnouncer
			color: ((colorScale scale: each) alpha: 70 percent);
			model: each;
			yourself ].

	boxes withIndexDo: [ :each :index |
		index even
			ifTrue: [ each width: 10; height: 100 ]
			ifFalse: [ each width: 100; height: 10 ] ].

	^ boxes
]

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> openWithLayoutClass: layoutClass [

	| view nodes instance |
	nodes := self newBoxes.
	instance := layoutClass new
		addNodes: nodes;
		yourself.

	view := RSCanvas new.
	view addAll: nodes.

	view newAnimation
		easing: RSEasing cubicInOut;
		from: 0.1;
		to: 0.0;
		duration: 7 seconds;
		onStepDo: [ :t | instance alpha: t; step ].
	
	view addInteraction: RSSimpleCanvasMonitor.
	view camera scale: 2.
	view open setLabel: instance className.

]

{ #category : #events }
UrRectangleRepulsionForceLayout >> initialize [
	super initialize.

	repulsionForce := 0.5

]

{ #category : #events }
UrRectangleRepulsionForceLayout >> step [
	self stepRectangleRepulsionForces.
	super step.

]

{ #category : #events }
UrRectangleRepulsionForceLayout >> stepRectangleRepulsionForces [
	"Apply a repulsion force between elements that overlap."

	| k alreadyVisited |
	k := repulsionForce * alpha.
	
	alreadyVisited := OrderedCollection new.
	
	nodes do: [ :each |
		| eachRect |
		eachRect := each encompassingRectangle.

		alreadyVisited do: [ :another |
			| anotherRect escapePoint areas |
			anotherRect := another encompassingRectangle.

			(anotherRect intersects: eachRect) ifTrue: [ 
				areas := anotherRect areasOutside: eachRect.
				escapePoint := areas
					ifEmpty: [ 0 asPoint " <--- just arbitrary! "]
					ifNotEmpty: [ eachRect floatCenter - (areas detectMax: #area) floatCenter ].
				each translateTo: each position + (k * escapePoint) ] ].

		alreadyVisited add: each ].

]
