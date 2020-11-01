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
		'labelPrototype',
		'refreshDeferrer'
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
		maxDefer: 200 milliSeconds

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

	| outerRectangle |
	outerRectangle := canvasController layout enclosingRectangle.
	outerRectangle ifNil: [ ^self "FIX" ].

	leftLabels remove: nil ifAbsent: [  ]. "WHY??????"
	leftLabels sort: [ :a :b |
		(a propertyAt: self className) position y <
		(b propertyAt: self className) position y ].
	leftLayout on: leftLabels.
	leftLabels translateBy: (outerRectangle left + outerMargin) @ leftLabels encompassingRectangle floatCenter y negated.

	rightLabels sort: [ :a :b |
		(a propertyAt: self className) position y <
		(b propertyAt: self className) position y ].
	rightLayout on: rightLabels.
	rightLabels translateBy: (outerRectangle right - outerMargin - rightLabels width) @ rightLabels encompassingRectangle floatCenter y negated.

]

{ #category : #public }
UrSidesStrategy >> removedTopLabelShape: aRSShape [

	| label |
	label := aRSShape propertyAt: self className.
	leftLabels remove: label ifAbsent: [].
	rightLabels remove: label ifAbsent: [].

	label ifNotNil: [ "WHY???"
		label remove ].
]

{ #category : #public }
UrSidesStrategy >> setupCanvasController: anUrCanvasController [ 
	
	canvasController := anUrCanvasController.

	leftLabels := RSGroup new.
	rightLabels := RSGroup new.

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

	| splitterX |
	splitterX := canvasController canvas nodes encompassingRectangle floatCenter x.
	
	evt shape position x < splitterX
		ifTrue: [ self ensureLabelOf: evt shape isIn: leftLabels andIsNotIn: rightLabels ]
		ifFalse: [ self ensureLabelOf: evt shape isIn: rightLabels andIsNotIn: leftLabels ].

]
