Class {
	#name : #UrVisualStrategy,
	#superclass : #Object,
	#instVars : [
		'hoverInteractionForEdges',
		'hoverInteractionForShapes',
		'labelInteraction'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #accessing }
UrVisualStrategy >> currentTheme [
	^ Smalltalk ui theme
]

{ #category : #accessing }
UrVisualStrategy >> edgeLengthFor: anEdge [
	^ (anEdge from encompassingRectangle halfPerimeter
		+ anEdge to encompassingRectangle halfPerimeter) / 2
]

{ #category : #accessing }
UrVisualStrategy >> hoverInteractionForEdges [
	^ hoverInteractionForEdges
]

{ #category : #accessing }
UrVisualStrategy >> hoverInteractionForShapes [
	^ hoverInteractionForShapes
]

{ #category : #initialization }
UrVisualStrategy >> initialize [ 
	super initialize.
	
	hoverInteractionForEdges := self newHoverInteractionForEdges.
	hoverInteractionForShapes := self newHoverInteractionForShapes.
	labelInteraction := self newLabelInteraction.
	
"	highlightInteractionForCurrentSearchResult := RSHighlightable new
		propertyKey: #searchResult;
		highlightShapes: [ :each | {each propertyAt: #RSLabeled} ];
		when: RSHighlightEvent do: [ :evt |
			self highlightSearchResultOn: evt shape intensity: 1 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightSearchResultOn: evt shape.
			self shouldHighlightAllSearchResults ifTrue: [
				self highlightSearchResultOn: evt shape intensity: 0.5 ] ].

	highlightInteractionForAllSearchResults := RSHighlightable new
		propertyKey: #allSearchResults;
		highlightShapes: [ :each | {each propertyAt: #RSLabeled} ];
		when: RSHighlightEvent do: [ :evt |
			self highlightSearchResultOn: evt shape intensity: 0.5 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightSearchResultOn: evt shape ].
"
]

{ #category : #accessing }
UrVisualStrategy >> labelInteraction [
	^ labelInteraction
]

{ #category : #accessing }
UrVisualStrategy >> newEdgeBuilderForNestedElements [

	^ RSEdgeBuilder line
		color: (self currentTheme caretColor alpha: 0.15);
		width: 0.5;
"		interactionDo: [ :interactionBuilder |
			interactionBuilder
				popupText: [:model | model key model object asString, '->', model value model object asString ] ];
"		yourself.
]

{ #category : #accessing }
UrVisualStrategy >> newEdgeBuilderForTopLevelElements [

	^ RSEdgeBuilder line
		color: (self currentTheme caretColor alpha: 0.25);
		yourself
]

{ #category : #accessing }
UrVisualStrategy >> newHoverInteractionForEdges [

	^ RSHighlightable new
		highlightColor: self currentTheme caretColor;
		yourself

]

{ #category : #accessing }
UrVisualStrategy >> newHoverInteractionForShapes [

	^ RSHighlightable new
		highlightColor: [ :shape |
			shape color adjustBrightness: 0.16 ];
		highlightBorder: [ :shape | 
			RSBorder new
				color: self currentTheme textColor;
				width: 0.3;
				yourself ];
		yourself

]

{ #category : #accessing }
UrVisualStrategy >> newLabelInteraction [ 

	^ RSLabeled new
		model: #yourself;
		shapeBuilder: [ :aShape |
			RSComposite new
				shapes: {
					RSLabel new
						text: aShape model object asString;
						scaleBy: 0.15;
						yourself };
				yourself ];
		yourself
]

{ #category : #accessing }
UrVisualStrategy >> newShapeForNestedNode: aUrNode [

	^ RSComposite new
		  model: aUrNode;
		  addInteraction: (RSPopup new
				   text: [ :each | each object ];
				   yourself);
		  border: (RSBorder new
				   width: 0.1;
				   yourself);
		  color: (self colorFor: aUrNode);
		  size: (self sizeFor: aUrNode);
		  yourself
]

{ #category : #accessing }
UrVisualStrategy >> setupCanvas: aRSCanvas [

	aRSCanvas color: self currentTheme backgroundColor.
	aRSCanvas camera scale: 6.
	"aRSCanvas addInteraction: RSGraphCanvasMonitor."
	

]

{ #category : #accessing }
UrVisualStrategy >> setupLayout: layout [

	layout
		charge: -60;
		friction: 0.25;
		gravity: 0.1;
		enclosingForce: 1;
		enclosingThreshold: 20

]

{ #category : #accessing }
UrVisualStrategy >> sizeFor: aUrNode [
	^ (10 * (aUrNode children size + 1)) sqrt
]
