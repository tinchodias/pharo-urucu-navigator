Class {
	#name : #UrVisualStrategy,
	#superclass : #Object,
	#instVars : [
		'hoverInteractionForEdges',
		'hoverInteractionForShapes'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #accessing }
UrVisualStrategy >> colorFor: aUrNode [
	^ self subclassResponsibility
]

{ #category : #accessing }
UrVisualStrategy >> currentTheme [

	^ Smalltalk ui theme
]

{ #category : #accessing }
UrVisualStrategy >> edgeLengthFor: anEdge [
	^ (anEdge from encompassingRectangle halfPerimeter
		+ anEdge to encompassingRectangle halfPerimeter) / 2
]

{ #category : #'expanding-collapsing' }
UrVisualStrategy >> expand: aRSComposite nesting: nestedShapes [

	self layoutNestedShapes: nestedShapes.
	
	aRSComposite
		shapes: nestedShapes;
		padding: 5.

]

{ #category : #accessing }
UrVisualStrategy >> hoverInteractionForEdges [
	^ hoverInteractionForEdges
]

{ #category : #initialization }
UrVisualStrategy >> initialize [ 
	super initialize.
	
	hoverInteractionForEdges := self newHoverInteractionForEdges.
	
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

{ #category : #'expanding-collapsing' }
UrVisualStrategy >> layoutNestedShapes: nestedShapes [

	RSRectanglePackLayout new
		gap: 0.5;
		preferredAngle: (25@10) angle;
		on: nestedShapes

]

{ #category : #accessing }
UrVisualStrategy >> newEdgeBuilderForNestedElements [

	^ RSEdgeBuilder line
		color: (self currentTheme caretColor alpha: 0.15);
		width: 1.5;
"		interactionDo: [ :interactionBuilder |
			interactionBuilder
				popupText: [:model | model key model object asString, '->', model value model object asString ] ];
"		yourself.
]

{ #category : #accessing }
UrVisualStrategy >> newEdgeBuilderForTopLevelElements [

	^ RSEdgeBuilder line
		width: 4;
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
UrVisualStrategy >> newShapeForNestedNode: aUrNode [

	^ RSComposite new
		  model: aUrNode;
		  addInteraction: (RSPopup new
				   text: [ :each | each object ];
				   yourself);
		  border: (RSBorder new
				   width: 1;
				   yourself);
		  color: (self colorFor: aUrNode);
		  size: (self sizeFor: aUrNode);
		  yourself
]

{ #category : #accessing }
UrVisualStrategy >> setupCanvas: aRSCanvas [

	aRSCanvas color: self currentTheme backgroundColor.
	"aRSCanvas addInteraction: RSGraphCanvasMonitor."
	

]

{ #category : #accessing }
UrVisualStrategy >> setupLayout: layout [

	layout
		charge: -240;
		friction: 0.75;
"		strength: 1;"
		gravity: 0.1;
		enclosingForce: 1;
		enclosingThreshold: 25

]

{ #category : #accessing }
UrVisualStrategy >> sizeFor: aUrNode [
	^ (100 * (aUrNode children size + 1)) sqrt
]
