Class {
	#name : #UrSidesStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'canvasController',
		'leftLayout',
		'rightLayout',
		'outerMargin',
		'labelPrototype',
		'refreshDeferrer',
		'lastLeftShapes'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #private }
UrSidesStrategy >> ensureLabelOf: aRSShape isIn: aGroup andIsNotIn: anotherGroup [

	| label |
	label := aRSShape propertyAt: self className.

	(aGroup includes: label) ifTrue: [ ^ self ].

	anotherGroup remove: label ifAbsent: [].
	aGroup add: label.

	refreshDeferrer schedule
]

{ #category : #initialization }
UrSidesStrategy >> initialize [
	super initialize.

	leftLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignRight;
		yourself.

	rightLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignLeft;
		yourself.

	labelPrototype := RSLabel new
		scaleBy: 0.17;
		yourself.

	outerMargin := 2.

	refreshDeferrer := UrDeferrer
		send: #refreshLeftAndRightGroups
		to: self
		after: 50 milliSeconds
		maxDefer: 250 milliSeconds

]

{ #category : #private }
UrSidesStrategy >> labelFor: aRSShape [

	| label |
	label := labelPrototype copyWithAnnouncer
		text: aRSShape model object asString;
		yourself.

	^ { label } asGroup asShape
		color: canvasController canvas color;
		propertyAt: self className put: aRSShape;
		padding: 1;
		yourself

]

{ #category : #private }
UrSidesStrategy >> lineFrom: aRSShape to: itsLabel [

	^ RSBezier new
		controlPointsController: RSHorizontalCPAPController new;
		from: aRSShape;
		to: itsLabel;
		color: Color lightGray;
		withCenteredAttachPoint;
		dashArray: #(0.5);
		width: 0.25;
		yourself

]

{ #category : #private }
UrSidesStrategy >> refreshLeftAndRightGroups [

	| outerRectangle shapesToLabel stream leftLabels rightLabels leftShapes rightShapes |
	outerRectangle := canvasController layout enclosingRectangle.
	outerRectangle ifNil: [ ^self "FIX" ].

	shapesToLabel := canvasController canvas nodes.
	stream := (shapesToLabel sorted: [ :a :b | a position x < b position x ]) readStream.
	leftShapes := stream next: shapesToLabel size // 2.
	rightShapes := stream upToEnd.
	
	leftShapes := leftShapes sort: [ :a :b | a position y < b position y ].
	leftLabels := leftShapes collect: [ :each | each propertyAt: self className ] as: RSGroup.
	leftLayout on: leftLabels.
	leftLabels translateBy: (outerRectangle left + outerMargin) @ leftLabels encompassingRectangle floatCenter y negated.

	rightShapes := rightShapes sort: [ :a :b | a position y < b position y ].
	rightLabels := rightShapes collect: [ :each | each propertyAt: self className ] as: RSGroup.
	rightLayout on: rightLabels.
	rightLabels translateBy: (outerRectangle right - outerMargin - rightLabels width) @ rightLabels encompassingRectangle floatCenter y negated.

]

{ #category : #public }
UrSidesStrategy >> removedTopLabelShape: aRSShape [

	| label |
	label := aRSShape propertyAt: self className.
	label remove.
]

{ #category : #public }
UrSidesStrategy >> setupCanvasController: anUrCanvasController [ 
	
	canvasController := anUrCanvasController.

	canvasController canvas
		when: RSExtentChangedEvent
		send: #schedule
		to: refreshDeferrer

]

{ #category : #public }
UrSidesStrategy >> setupNewShapes: aCollection [

	| labels lines |
	labels := RSGroup new.
	lines := RSGroup new.
	
	aCollection do: [ :each |
		| label line |
		label := self labelFor: each.
		line := self lineFrom: each to: label.

		each propertyAt: self className put: label.
		each when: RSPositionChangedEvent send: #schedule to: refreshDeferrer.
			
		labels add: label.
		lines add: line ].
	
	canvasController canvas
		addAllShapes: labels;
		addAllShapes: lines.

	labels pushBack.
	lines pushBack.

]
