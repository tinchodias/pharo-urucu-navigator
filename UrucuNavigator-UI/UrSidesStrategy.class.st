Class {
	#name : #UrSidesStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'leftLayout',
		'rightLayout',
		'outerMargin',
		'labelPrototype',
		'refreshDeferrer',
		'lastLeftShapes',
		'highlightInteraction'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #public }
UrSidesStrategy >> addInteractionsTo: aRSShape line: line label: label [

	| shapesToHighlightOnHover |
	shapesToHighlightOnHover := { line. label. aRSShape }.
	shapesToHighlightOnHover do: [ :each |
		each
			propertyAt: #shapesToHighlightOnHover 
			put: shapesToHighlightOnHover ].
	line addInteraction: highlightInteraction.
	label addInteraction: highlightInteraction.

]

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
		maxDefer: 0.5 second.

	leftLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignRight;
		yourself.

	rightLayout := RSVerticalLineLayout new
		gapSize: 0;
		alignLeft;
		yourself.

	labelPrototype := RSLabel new.
	
	highlightInteraction := self newHighlightable.

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

"	^ self bezierLineFrom: aRSShape to: itsLabel"
	^ self straightLineFrom: aRSShape to: itsLabel

]

{ #category : #initialization }
UrSidesStrategy >> newHighlightable [

	| aBorder |
	aBorder := RSBorder new
		width: 1.25;
		color: canvasController visualStrategy currentTheme textColor;
		yourself.

	^ RSHighlightable new
		highlightShapes: [ :aRSShape |
			aRSShape propertyAt: #shapesToHighlightOnHover ];
		when: RSHighlightEvent
			do: [ :evt | evt shape pushFront ];
		highlightBorder: aBorder;
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
UrSidesStrategy >> setupCanvasController [
	
	canvasController canvas
		when: RSExtentChangedEvent
		send: #schedule
		to: refreshDeferrer.

	canvasController protoNodeShape
		addInteraction: highlightInteraction;
		when: RSPositionChangedEvent
			send: #schedule
			to: refreshDeferrer.

]

{ #category : #public }
UrSidesStrategy >> setupNewShapes: aCollection [

	| labels lines |
	labels := RSGroup new.
	lines := RSGroup new.
	
	aCollection do: [ :aRSShape |
		| label line |
		label := self labelFor: aRSShape.
		line := self lineFrom: aRSShape to: label.

		aRSShape propertyAt: self className put: label.
		self addInteractionsTo: aRSShape line: line label: label.
		
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
