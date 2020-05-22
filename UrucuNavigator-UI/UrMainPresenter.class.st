Class {
	#name : #UrMainPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'viewPresenter',
		'searchPresenter',
		'currentCanvas',
		'currentCanvasController',
		'graphBuildingBlock'
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
]

{ #category : #'private - searching' }
UrMainPresenter >> highlightAllSearchResults [
	| highlightableForCurrentSearchResult allSearchResults elementsForAllSearchResults |

	allSearchResults := searchPresenter lastResultModel nodes.

	highlightableForCurrentSearchResult := RSHighlightable new
		highlightShapes: [ :each | {each propertyAt: #RSLabeled} ];
		propertyKey: #allSearchResults;
		when: RSHighlightEvent do: [ :evt |
			self highlightCompositeElementWithLabel: evt shape intensity: 0.5 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightCompositeElementWithLabel: evt shape ].
	
	elementsForAllSearchResults := allSearchResults
		collect: [:each | currentCanvas shapeFromModel: each ]
		thenReject: #isNil.
	
	self shouldHighlightAll
		ifTrue: [
			highlightableForCurrentSearchResult doHighlightShapes: elementsForAllSearchResults ]
		ifFalse: [ 
			highlightableForCurrentSearchResult unhighlightRecordedShapes: currentCanvas ].
	
	currentCanvas signalUpdate
]

{ #category : #'private - searching' }
UrMainPresenter >> highlightCompositeElementWithLabel: aRSCompositeShape intensity: k [

	| ranges font label highlightColor searchedText highlightShapeBuilder backgroundColor |
	"search result model"
	label := aRSCompositeShape shapes last.
	searchedText := searchPresenter searchModel text.
	ranges := label text allRangesOfSubstring: searchedText.

	"visualize"
	highlightColor := self theme warningTextColor.
	backgroundColor := self theme backgroundColor alpha: 0.5.
	aRSCompositeShape color: backgroundColor.
	aRSCompositeShape border: (RSBorder new color: (highlightColor alpha: k); width: 3 * k; yourself).
	aRSCompositeShape pushFront.

	highlightShapeBuilder := RSBox new
		color: (highlightColor alpha: k * 0.5);
"		border: (TSBorder new color: (highlightColor alpha: k * 0.5); width: 2 * k; yourself);"
		yourself.

	font := label font.
	ranges do: [ :interval |
		| boxElement x partial |
		boxElement := highlightShapeBuilder element
			extent: (font widthOfString: searchedText)@font height;
			yourself.
		partial := font widthOfString: (label text copyFrom: 1 to: (interval first - 1)).
		x := partial + ((boxElement width - label width) / 2) - 2.
		boxElement position: x@0.
		aRSCompositeShape shapes addFirst: boxElement ]

]

{ #category : #'private - searching' }
UrMainPresenter >> highlightCurrentSearchResult [
	| highlightableForCurrentSearchResult topLevelElement aHiMNode |
	searchPresenter lastResultModel hasResults ifFalse: [ ^self ].
	
	aHiMNode := searchPresenter lastResultModel currentNode.

	highlightableForCurrentSearchResult := RSHighlightable new
		propertyKey: #searchResult;
		highlightShapes: [ :each | {each attributeAt: #RSLabeled} ];
		when: RSHighlightEvent do: [ :evt |
			self highlightCompositeElementWithLabel: evt element intensity: 1 ];
		when: RSUnHighlightEvent do: [ :evt |
			self unhighlightCompositeElementWithLabel: evt element.
			self shouldHighlightAll 
				ifTrue: [ self highlightCompositeElementWithLabel: evt element intensity: 0.5 ] ].

	self flag: #todo.
	highlightableForCurrentSearchResult highlightShape. "TODO: Needed to ensure a slot has been initialized."

	topLevelElement := currentCanvas shapeFromModel: aHiMNode topParent.
	currentCanvasController executeAndRegisterExpandIfPossible: topLevelElement.

	(topLevelElement shapeFromModel: aHiMNode)
		ifNotNil: [ :element | 
			highlightableForCurrentSearchResult doHighlight: element ]
		ifNil: [
			(currentCanvas shapeFromModel: aHiMNode topParent) ifNotNil:
				[ :element | highlightableForCurrentSearchResult doHighlight: element ] ].
		
	currentCanvas signalUpdate
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
UrMainPresenter >> shouldHighlightAll [
	^ searchPresenter isHighlightAllEnabled and: [ searchPresenter lastResultModel hasResults ]
]

{ #category : #'private - searching' }
UrMainPresenter >> unhighlightCompositeElementWithLabel: aRSComposite [
	| label normalColor |
	normalColor := self theme textColor.
	label := aRSComposite shapes last.
	label color: normalColor.
	
	aRSComposite
		border: nil;
		color: nil.
	
	aRSComposite shapes removeFirst: aRSComposite shapes size - 1
]
