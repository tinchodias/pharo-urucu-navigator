Class {
	#name : #UrSidesStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'leftLabels',
		'rightLabels',
		'canvasController'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #'as yet unclassified' }
UrSidesStrategy >> ensureLabelOf: aRSShape isIn: aGroup andIsNotIn: anotherGroup [

	| label |
	label := aRSShape propertyAt: self className.
	
	anotherGroup remove: label ifAbsent: [].
	aGroup addIfNotPresent: label.

]

{ #category : #'as yet unclassified' }
UrSidesStrategy >> removedTopLabelShape: aRSShape [

	| label |
	label := aRSShape propertyAt: self className.
	leftLabels remove: label ifAbsent: [].
	rightLabels remove: label ifAbsent: [].
	label remove.
]

{ #category : #'as yet unclassified' }
UrSidesStrategy >> setupCanvasController: anUrCanvasController [ 
	
	leftLabels := RSGroup new.
	rightLabels := RSGroup new.
	
	canvasController := anUrCanvasController.

]

{ #category : #'as yet unclassified' }
UrSidesStrategy >> setupNewShapes: aCollection [

	| labels lines |
	labels := RSGroup new.
	lines := RSGroup new.
	
	aCollection do: [ :each |
		| label line |
		label := RSLabel new
			scaleBy: 0.2;
			text: each model object asString;
			yourself.

		label := { label } asGroup asShape
			color: canvasController canvas color;
			padding: 1;
			yourself.

		line := RSBezier new
			controlPointsController: RSHorizontalCPAPController new;
			from: each;
			to: label;
			color: Color lightGray;
			withCenteredAttachPoint;
			dashArray: #(0.5);
			width: 0.25;
			yourself.

"		line := RSPolyline new
			controlPointsController: RSHorizontalCPAPController new;
			from: each;
			to: label; 
			withHorizontalAttachPoint;
			dashArray: #(0.25);
			width: 0.25;
			yourself.
"
		each propertyAt: self className put: label.

		each when: RSPositionChangedEvent send: #updatedPosition: to: self.
			
		labels add: label.
		lines add: line ].
	
	canvasController canvas
		addAllShapes: labels;
		addAllShapes: lines.

	lines pushBack
]

{ #category : #'as yet unclassified' }
UrSidesStrategy >> updatedPosition: evt [

	| splitterX outerRectangle margin layout |
	splitterX := canvasController canvas nodes encompassingRectangle floatCenter x.
	outerRectangle := canvasController layout enclosingRectangle.
	margin := 2.
	
	evt shape position x < splitterX
		ifTrue: [ self ensureLabelOf: evt shape isIn: leftLabels andIsNotIn: rightLabels ]
		ifFalse: [ self ensureLabelOf: evt shape isIn: rightLabels andIsNotIn: leftLabels ].
	
	layout := RSVerticalLineLayout new
		gapSize: 0;
		yourself.
	
	layout alignRight.	
	layout on: leftLabels.
	leftLabels translateBy: (outerRectangle left + margin) @ 0.

	layout alignLeft.	
	layout on: rightLabels.
	rightLabels translateBy: (outerRectangle right - margin - rightLabels width) @ 0.

]
