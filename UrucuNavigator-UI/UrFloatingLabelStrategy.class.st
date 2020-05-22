Class {
	#name : #UrFloatingLabelStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'edgeBuilder'
	],
	#category : #'UrucuNavigator-UI-Roassal3'
}

{ #category : #applying }
UrFloatingLabelStrategy >> applyAfterAddingElements: elements [
	
	elements do: [ :each |
		| label edge mockEdge |
		label := self shapeBuilder elementOn: each model object.
		edge := self edgeBuilder "withBorderAttachPoint" from: each; to: label; edge.
		canvasController canvas add: label; add: edge.
		canvasController layout
			addNodes: { label };
			addEdges: { edge }.
		mockEdge := canvasController layout mockEdgeAt: edge.
		mockEdge 
			length: (canvasController edgeLengthFor: edge);
			strength: 5. ]

	
]

{ #category : #applying }
UrFloatingLabelStrategy >> edgeBuilder [ 
	^ edgeBuilder ifNil: [
		edgeBuilder := RSSingleEdgeBuilder line
			width: 0.25;
			color: (canvasController currentTheme textColor alpha: 0.25);
			dashArray: #(0.25);
			yourself ]

]

{ #category : #accessing }
UrFloatingLabelStrategy >> edgeBuilder: anObject [
	edgeBuilder := anObject
]

{ #category : #accessing }
UrFloatingLabelStrategy >> shapeBuilder [
	^ shapeBuilder ifNil: [
		shapeBuilder := RSShapeBuilder composite
			shapes: [ :m | 
				TSGroup with:
					(TSLabel new
						text: m asString;
						color: (canvasController currentTheme textColor alpha: 0.75);
						yourself) ];
			scaleBy: 0.15;
			yourself ]
]
