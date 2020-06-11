"
I'm a Spec presenter to navigate and search nodes.
"
Class {
	#name : #UrMainPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'viewPresenter',
		'searchPresenter',
		'currentCanvas',
		'currentCanvasController',
		'graphBuildingBlock',
		'highlightableForCurrentSearchResult',
		'highlightableForAllSearchResults'
	],
	#category : #'UrucuNavigator-UI-Spec'
}

{ #category : #specs }
UrMainPresenter class >> defaultSpec [
	<spec>
	
	^ SpBoxLayout newVertical 
			spacing: 5;
			add: #viewPresenter;
			add: #searchPresenter 
				withConstraints: [ :constraints | 
					constraints height: self labelHeight + 5 ];
		yourself.
				
]

{ #category : #private }
UrMainPresenter >> fillCurrentCanvas [

	currentCanvasController := UrCanvasController newOn: currentCanvas.
	graphBuildingBlock value: currentCanvasController.

	searchPresenter searchModel topParentNodes: currentCanvasController topLevelNodes.
	currentCanvas camera scale: 6.
	currentCanvas when: RSMouseClick do: [ currentCanvas morph takeKeyboardFocus ].
	
	highlightableForCurrentSearchResult := RSHighlightable new
		propertyKey: #searchResult;
		highlightShapes: [ :each | {each propertyAt: #RSLabeled} ];
		when: RSHighlightEvent do: [ :evt |
			self highlightSearchResultOn: evt shape intensity: 1 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightSearchResultOn: evt shape.
			self shouldHighlightAllSearchResults ifTrue: [
				self highlightSearchResultOn: evt shape intensity: 0.5 ] ].

	highlightableForAllSearchResults := RSHighlightable new
		highlightShapes: [ :each | {each propertyAt: #RSLabeled} ];
		propertyKey: #allSearchResults;
		when: RSHighlightEvent do: [ :evt |
			self highlightSearchResultOn: evt shape intensity: 0.5 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightSearchResultOn: evt shape ].
	

]

{ #category : #'private - searching' }
UrMainPresenter >> highlightAllSearchResults [

	| allSearchResults |
	allSearchResults := searchPresenter lastResultModel nodes.

	self shouldHighlightAllSearchResults
		ifTrue: [
			| shapesWithAllSearchResults |
			shapesWithAllSearchResults := allSearchResults
				collect: [:each | currentCanvas shapeFromModel: each ]
				thenReject: #isNil.
			highlightableForAllSearchResults doHighlightShapes: shapesWithAllSearchResults ]
		ifFalse: [ 
			highlightableForAllSearchResults unhighlightRecordedShapes: currentCanvas ].
	
	currentCanvas signalUpdate
]

{ #category : #'private - searching' }
UrMainPresenter >> highlightCurrentSearchResult [

	| enclosingShape currentSearchResultNode |
	searchPresenter lastResultModel hasResults ifFalse: [ ^self ].
	
	currentSearchResultNode := searchPresenter lastResultModel currentNode.
	enclosingShape := currentCanvas shapeFromModel: currentSearchResultNode topParent.
	currentCanvasController executeAndRegisterExpandIfPossible: enclosingShape.

	(enclosingShape shapeFromModel: currentSearchResultNode)
		ifNotNil: [ :shape | 
			highlightableForCurrentSearchResult doHighlight: shape ]
		ifNil: [
			(currentCanvas shapeFromModel: currentSearchResultNode topParent) ifNotNil:
				[ :shape | highlightableForCurrentSearchResult doHighlight: shape ] ].
		
	currentCanvas signalUpdate
]

{ #category : #'private - searching' }
UrMainPresenter >> highlightSearchResultOn: aRSLabelShape intensity: k [

	| highlightColor backgroundColor |
	highlightColor := self theme warningTextColor.
	backgroundColor := self theme warningTextColor alpha: 0.2.
	aRSLabelShape color: backgroundColor.
	aRSLabelShape
		border:
			(RSBorder new
				color: (highlightColor alpha: k);
				width: 0.8 * k;
				yourself).
	aRSLabelShape pushFront
]

{ #category : #initialization }
UrMainPresenter >> initializePresenters [
	viewPresenter := (self instantiate: SpRoassalPresenter)
		script: [ :newCanvas |
			currentCanvas := newCanvas.
			self fillCurrentCanvas ];
		yourself.

	searchPresenter := (self instantiate: UrSearchPresenter)
		newResultIndexBlock: [ self highlightCurrentSearchResult ];
		newResultsBlock: [ self highlightAllSearchResults ];
		toggledHighlightAllBlock: [ 
			self highlightAllSearchResults; highlightCurrentSearchResult ];
		yourself.

	self focusOrder
		add: searchPresenter;
		add: viewPresenter
]

{ #category : #private }
UrMainPresenter >> setModelBeforeInitialization: aGraphBuildingBlock [
	graphBuildingBlock := aGraphBuildingBlock
]

{ #category : #'private - searching' }
UrMainPresenter >> shouldHighlightAllSearchResults [
	^ searchPresenter isHighlightAllEnabled and: [ searchPresenter lastResultModel hasResults ]
]

{ #category : #'private - searching' }
UrMainPresenter >> unhighlightSearchResultOn: aRSLabel [
	aRSLabel
		border: nil;
		color: nil.

]
