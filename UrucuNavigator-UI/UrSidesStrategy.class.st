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
UrSidesStrategy >> bezierLineFrom: aRSShape to: itsLabel [

	^ RSBezier new
		controlPointsController: RSHorizontalCPAPController new;
"		controlPointsController: (RSBlockCPController new
	        block: [:ed | | f t ap |
	            ap := ed attachPoint.
	            f := ap startingPointOf: ed.
	            t := ap endingPointOf: ed.
	            Array 
	                with: f
	                with: t x @ f y
	                with: f x @ t y
	                with: t. ]);
"		from: aRSShape;
		to: itsLabel;
		color: Color lightGray;
		withCenteredAttachPoint;
		dashArray: #(2);
		width: 0.75;
		yourself

]

{ #category : #initialization }
UrSidesStrategy >> initialize [
	super initialize.

	outerMargin := 10.

	refreshDeferrer := UrDeferrer
		send: #refreshLeftAndRightGroups
		to: self
		after: 50 milliSeconds
		maxDefer: 1 second.

	leftLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignRight;
		yourself.

	rightLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignLeft;
		yourself.

	labelPrototype := RSLabel new
		addInteraction: self newHighlightable;
		yourself.

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
		padding: 3@1;
		yourself

]

{ #category : #private }
UrSidesStrategy >> lineFrom: aRSShape to: itsLabel [

	^ self bezierLineFrom: aRSShape to: itsLabel

]

{ #category : #initialization }
UrSidesStrategy >> newHighlightable [

	^ RSHighlightable new
		highlightShapes: [ :aRSLabel |
			| composite line to |
			composite := aRSLabel parent.
			line := composite connectedEdges first.
			to := line from.
			{ line. to. composite. } ];
		when: RSHighlightEvent
			do: [ :evt | evt shape pushFront ];
		highlightBorder: (RSBorder new width: 1.5; color: Color black; yourself);
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

{ #category : #private }
UrSidesStrategy >> straightLineFrom: aRSShape to: itsLabel [

	^ RSLine new
		from: aRSShape;
		to: itsLabel;
		color: Color lightGray;
		withCenteredAttachPoint;
		dashArray: #(2);
		width: 0.75;
		yourself

]
