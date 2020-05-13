Class {
	#name : #UrRectangleRepulsionForceLayout,
	#superclass : #RSForceBasedLayout,
	#instVars : [
		'repulsionForce'
	],
	#category : #'UrucuNavigator-Experimental'
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
	| labeled verticalNodes horizontalNodes |
	labeled := RSLabeled new.
"	labeled shape scaleBy: 0.5."
	labeled location middle.
	
	verticalNodes := (1 to: 10) collect: [ :each | 
		RSBox new
			width: 10;
			height: 100;
			color: Color random translucent;
			model: each;
			addInteraction: labeled;
			addInteraction: RSDraggable;
			yourself
		 ].
	horizontalNodes := (1 to: 10) collect: [ :each | 
		RSBox new
			width: 100;
			height: 10;
			color: Color random translucent;
			model: each;
			addInteraction: labeled;
			addInteraction: RSDraggable;
			yourself ].

	^ verticalNodes, horizontalNodes
]

{ #category : #initialization }
UrRectangleRepulsionForceLayout class >> openWithLayoutClass: layoutClass [

	| view nodes instance |
	nodes := self newBoxes.
	instance := layoutClass new
		nodes: nodes;
		yourself.

	view := RSCanvas new.
	view addAll: nodes.

	view newAnimation
		easing: RSEasing cubicInOut;
		from: 0.1;
		to: 0.0;
		duration: 5 seconds;
		onStepDo: [ :t | instance alpha: t; step ].
	
"	view addInteraction: RSActivityMonitorView."
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
				areas := anotherRect areasOutside:  eachRect.
				escapePoint := areas
					ifEmpty: [ 0 asPoint " <--- just arbitrary! "]
					ifNotEmpty: [ eachRect floatCenter - (areas detectMax: #area) floatCenter ].
				each translateTo: each position + (k * escapePoint) ] ].

		alreadyVisited add: each ].

]
