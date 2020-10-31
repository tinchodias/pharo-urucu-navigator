Class {
	#name : #UrSidesStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'leftLabels',
		'rightLabels',
		'canvasController',
		'leftLayout',
		'rightLayout',
		'outerMargin',
		'labelPrototype'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #private }
UrSidesStrategy >> ensureLabelOf: aRSShape isIn: aGroup andIsNotIn: anotherGroup [

	| label |
	label := aRSShape propertyAt: self className.
	
	anotherGroup remove: label ifAbsent: [].
	aGroup addIfNotPresent: label.

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
		scaleBy: 0.2;
		yourself.

	outerMargin := 2.

]

{ #category : #private }
UrSidesStrategy >> labelFor: aRSShape [

	| label |
	label := labelPrototype copyWithAnnouncer
		text: aRSShape model object asString;
		yourself.

	^ { label } asGroup asShape
		color: canvasController canvas color;
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

{ #category : #public }
UrSidesStrategy >> removedTopLabelShape: aRSShape [

	| label |
	label := aRSShape propertyAt: self className.
	leftLabels remove: label ifAbsent: [].
	rightLabels remove: label ifAbsent: [].
	label remove.
]

{ #category : #public }
UrSidesStrategy >> setupCanvasController: anUrCanvasController [ 
	
	leftLabels := RSGroup new.
	rightLabels := RSGroup new.
	
	canvasController := anUrCanvasController.

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
		each when: RSPositionChangedEvent send: #updatedPosition: to: self.
			
		labels add: label.
		lines add: line ].
	
	canvasController canvas
		addAllShapes: labels;
		addAllShapes: lines.

	labels pushBack.
	lines pushBack.

]

{ #category : #private }
UrSidesStrategy >> updatedPosition: evt [

	| splitterX outerRectangle |
	splitterX := canvasController canvas nodes encompassingRectangle floatCenter x.
	outerRectangle := canvasController layout enclosingRectangle.
	
	evt shape position x < splitterX
		ifTrue: [ self ensureLabelOf: evt shape isIn: leftLabels andIsNotIn: rightLabels ]
		ifFalse: [ self ensureLabelOf: evt shape isIn: rightLabels andIsNotIn: leftLabels ].
	
	leftLayout on: leftLabels.
	leftLabels translateBy: (outerRectangle left + outerMargin) @ 0.

	rightLayout on: rightLabels.
	rightLabels translateBy: (outerRectangle right - outerMargin - rightLabels width) @ 0.

]
