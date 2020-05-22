Class {
	#name : #UrCanvasController,
	#superclass : #Object,
	#instVars : [
		'layout',
		'commandHistory',
		'labelStrategy',
		'topLevelNodes',
		'forceAnimation',
		'colorScale',
		'canvas',
		'highlightableForEdges',
		'highlightableForShapes',
		'protoNodeShape'
	],
	#category : #'UrucuNavigator-UI-Roassal3'
}

{ #category : #examples }
UrCanvasController class >> new [
	^ self shouldNotImplement
]

{ #category : #examples }
UrCanvasController class >> newOn: aRSCanvas [
	^ self basicNew
		initializeOn: aRSCanvas;
		yourself
]

{ #category : #visualization }
UrCanvasController >> addEdgesFor: someRSShapes [

	| edgeBuilder edges |
	edgeBuilder := RSEdgeBuilder line
		canvas: canvas;
		color: (self currentTheme caretColor alpha: 0.25);
		yourself.
		
	edgeBuilder shape
		popupText: [:model | model key object asString, '->', model value object asString ];
		addInteraction: self highlightableForEdges;
		when: RSMouseDoubleClick do: [:evt | self toggleEdge: evt shape ].

	"Dependencies"
	edges := OrderedCollection new.
	someRSShapes do: [ :toElement |
		| fromModels |
		fromModels := toElement model allIncomingNodes flatCollect: #withAllParents.
		fromModels do: [ :fromModel |
			"If it is present..."
			(canvas shapeFromModel: fromModel) ifNotNil: [ :fromElement |
				"If it is not already there..."
				(fromElement isDirectlyConnectedTo: toElement) ifFalse: [
					| newEdge |
					newEdge := edgeBuilder edgeFrom: fromElement to: toElement.
					"Explanation: The shape of the edge builder is a prototype that is copied
					without the announcer in #edgeFrom:to:. We make it shared as an optimization."
					newEdge announcer: edgeBuilder shape announcer.
					"Collect it"
					edges add: newEdge.
		] ] ] ].

	layout addEdges: edges.
	edges do: [ :anEdge |
		(layout mockEdgeAt: anEdge) length: (self edgeLengthFor: anEdge) ].
	
	edges do: #pushBack.

]

{ #category : #visualization }
UrCanvasController >> addNestedEdgesFor: someRSElements [

	| edgeBuilder |
	edgeBuilder := RSEdgeBuilder line
		canvas: canvas;
		color: (self currentTheme caretColor alpha: 0.15);
		width: 0.5;
"		interactionDo: [ :interactionBuilder |
			interactionBuilder
				popupText: [:model | model key model object asString, '->', model value model object asString ] ];
"		yourself.

	"Dependencies"
	someRSElements do: [ :toElement |
		| fromModels |
		fromModels := toElement model incomingNodes.
		fromModels do: [ :fromModel |
			"If it is present..."
			((canvas shapeFromModel: fromModel topParent) ifNotNil: [ :topLevelElement |
				topLevelElement shapeFromModel: fromModel ])
					ifNotNil: [ :fromElement |
					"If it is not already there..."
					(fromElement isDirectlyConnectedTo: toElement) ifFalse: [
						"Add it"
						edgeBuilder edgeFrom: fromElement to: toElement.
			] ] ] ].

]

{ #category : #visualization }
UrCanvasController >> addNodesFor: someHiMNodes [

	| shapes |

	shapes := self shapesFor: someHiMNodes.
	canvas addAll: shapes.
	layout addNodes: shapes.
	self addEdgesFor: shapes.
	
	labelStrategy applyAfterAddingElements: shapes.
]

{ #category : #accessing }
UrCanvasController >> build [
	self addNodesFor: topLevelNodes.
	self startForceAnimationFinitely.
]

{ #category : #accessing }
UrCanvasController >> canvas [
	^ canvas
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> collapse: aRSElement [ 
	| endSize |
	endSize := self sizeFor: aRSElement model.

	self startForceAnimationFinitely.

	aRSElement newAnimation
		duration: self expandDuration;
		from: 1@1;
		to: endSize/aRSElement extent;
		onStepDo: [ :t | self expand: aRSElement step: t ];
		when: RSAnimationEndEvent do: [ | position |
			aRSElement children copy do: [ :each |
				each connectedEdges copy do: #remove.
				each remove ].
			position := aRSElement position.
			aRSElement matrix
				loadIdentity;
				translation: position.
			aRSElement size: endSize ].

	self mark: aRSElement asExpanded: false.
]

{ #category : #visualization }
UrCanvasController >> colorFor: aHiMNode [
	^ self colorScale scale: aHiMNode topParent
]

{ #category : #accessing }
UrCanvasController >> colorScale [
	^ colorScale ifNil: [ colorScale := NSScale category20 ]
]

{ #category : #accessing }
UrCanvasController >> colorScale: aColorScale [
	colorScale := aColorScale
]

{ #category : #accessing }
UrCanvasController >> currentTheme [
	^ Smalltalk ui theme
]

{ #category : #visualization }
UrCanvasController >> edgeLengthFor: anEdge [
	^ (anEdge from encompassingRectangle halfPerimeter
		+ anEdge to encompassingRectangle halfPerimeter) / 2
]

{ #category : #commands }
UrCanvasController >> executeAndRegisterCollapseIfPossible: aRSShape [
	| aCommand |
	(self isMarkedAsExpanded: aRSShape) ifFalse: [ ^self ].

	aCommand := UrCollapse new
		canvasController: self;
		node: aRSShape;
		yourself.
	commandHistory executeAndRegister: aCommand.
]

{ #category : #commands }
UrCanvasController >> executeAndRegisterExpandIfPossible: aRSShape [
	| aCommand |
	(self isMarkedAsExpanded: aRSShape) ifTrue: [ ^self ].

	aCommand := UrExpand new
		canvasController: self;
		node: aRSShape;
		yourself.
	commandHistory executeAndRegister: aCommand.
]

{ #category : #commands }
UrCanvasController >> executeRedoIfPossible [
	commandHistory canRedo ifTrue: [ commandHistory redo ]
]

{ #category : #commands }
UrCanvasController >> executeUndoIfPossible [
	commandHistory canUndo ifTrue: [ commandHistory undo ]
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> expand: aRSShape [
	| nestedShapes |
	nestedShapes := self newNestedShapesForAll: aRSShape model children.

	RSRectanglePackLayout new
		gap: 0.09;
		preferredAngle: (25@10) angle;
		on: nestedShapes.
		
	aRSShape
		shapes: nestedShapes;
		padding: 1;
		pushFront.
	
	self addNestedEdgesFor: nestedShapes.

	self startForceAnimationFinitely.

	aRSShape newAnimation
		duration: self expandDuration;
		from: (self sizeFor: aRSShape model) / aRSShape extent;
		to: 1@1;
		onStepDo: [ :t | self expand: aRSShape step: t ].

	self mark: aRSShape asExpanded: true.
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> expand: aRSShape step: t [
	
	| position |
	position := aRSShape position.
	aRSShape matrix
		loadIdentity;
		translation: position;
		scaleBy: t.
	aRSShape resetBBox.
	aRSShape connectedEdges do: [ :anEdge |
		layout edges
			detect: [ :each | each realEdge == anEdge ]
			ifFound: [ :mockEdge |
				mockEdge length: (self edgeLengthFor: anEdge) ]
		 ]
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> expandDuration [
	^ 150 milliSeconds
]

{ #category : #animations }
UrCanvasController >> forceAlphaRangeAsArray [
	^ #(0 0.1)
]

{ #category : #visualization }
UrCanvasController >> highlightableForEdges [
	^ highlightableForEdges ifNil: [
		highlightableForEdges := RSHighlightable new
			highlightColor: self currentTheme caretColor;
			yourself ]
]

{ #category : #visualization }
UrCanvasController >> highlightableForShapes [
	^ highlightableForShapes ifNil: [
		highlightableForShapes := 
			RSHighlightable new
				highlightColor: [ :shape |
					shape color adjustBrightness: 0.16 ];
				highlightBorder: [ :shape |
					RSBorder new
						color: self currentTheme textColor;
						width: 0.3;
						yourself ];
				yourself ]
]

{ #category : #initialization }
UrCanvasController >> initializeOn: aRSView [
	self initialize.
	
	commandHistory := UrCommandHistory new.

	canvas := aRSView.
	canvas color: self currentTheme backgroundColor.

	layout := RSRectangleForceLayout new
		start;
		charge: -60;
		friction: 0.25;
		gravity: 0.1;
		enclosingForce: 1;
		enclosingThreshold: 20;
		yourself.

	"Apply forces from the window borders to the elements."
	canvas
		when: RSExtentChangedEvent
		do: [ :evt |
			| camera origin corner |
			camera := canvas canvas camera.
			origin := camera fromPixelToSpace: 0 @ 0.
			corner := camera fromPixelToSpace: canvas canvas extent.
			layout enclosingRectangle: (origin corner: corner).
			self startForceAnimationFinitely ].
	
	canvas
		when: RSKeyDown
		do: [ :evt | self processKeyDown: evt ].

	protoNodeShape := RSComposite new
		addInteraction: (RSPopup new text: [ :each | each object ]; yourself);
		addInteraction: (RSDraggableForce new layout: layout; yourself);
		addInteraction: self highlightableForShapes;
		when: RSMouseDragStart do: [:evt | evt shape pushFront. self startForceAnimationInfinitely ];
		when: RSMouseDragEnd do: [:evt | self startForceAnimationFinitely ];
		when: RSMouseDoubleClick do: [:evt | self toggleNode: evt shape ];
		yourself.

	self labelStrategy: UrTopLabelStrategy new.
	
	canvas addInteraction: RSGraphCanvasMonitor.
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> isMarkedAsExpanded: aRSShape [
	^ aRSShape propertyAt: #expanded ifAbsentPut: [ false ]
]

{ #category : #accessing }
UrCanvasController >> labelStrategy [
	^ labelStrategy
]

{ #category : #accessing }
UrCanvasController >> labelStrategy: aHiMLabelStrategy [
	labelStrategy ifNotNil: [ labelStrategy uninstallFrom: self. ].
	labelStrategy := aHiMLabelStrategy.
	labelStrategy installOn: self.
]

{ #category : #accessing }
UrCanvasController >> layout [
	^ layout
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> mark: aRSShape asExpanded: aBoolean [
	^ aRSShape propertyAt: #expanded put: aBoolean
]

{ #category : #visualization }
UrCanvasController >> newNestedShapesForAll: someHiMNodes [
	^ someHiMNodes
		collect: [ :each | 
			RSLabel new
				scaleBy: 0.15;
				model: each;
				text: each object asString;
				yourself ].
			
		
"	| builder renderer color |
	builder := RSUMLClassBuilder new.
	renderer := builder renderer.
	color := self currentTheme textColor.
	renderer border color: color.
	renderer methodShape color: color.
	renderer classNameShape color: color.
		
	builder modelDescriptor
		classname: #object;
		instVars: #();
		methods: [ :aHiMNode |


			| limit methods |
			limit := 5.
			methods := aHiMNode children collect: [:each | each object value ].
			methods size < limit ifFalse: [
				methods := (methods first: limit) copyWith: '...' ].
			methods

			
			];
		methodSelector: #asString.
	builder shape: (RSComposite new
		popupText: #object;
		shapes: [ :m | builder createShapesFor: m ]).
	builder shape scaleBy: 0.08.
	builder renderer classBoxShape
		color: [ :node | self currentTheme backgroundColor alpha: 0.9 ];
		cornerRadius: 3.

	^ builder shape elementsOn: someHiMNodes
	
	"

]

{ #category : #commands }
UrCanvasController >> processKeyDown: aRSKeyDownEvent [
	aRSKeyDownEvent commandKeyPressed
		ifFalse: [ ^ self ].
	aRSKeyDownEvent keyValue = $z asciiValue
		ifTrue: [ self executeUndoIfPossible ].
	aRSKeyDownEvent keyValue = $Z asciiValue
		ifTrue: [ self executeRedoIfPossible ]
]

{ #category : #accessing }
UrCanvasController >> protoNodeShape [
	^ protoNodeShape
]

{ #category : #visualization }
UrCanvasController >> shapesFor: someHiMNodes [
	^ someHiMNodes collect: [ :aMNode |
		protoNodeShape copyWithAnnouncer
			model: aMNode;
			color: (self colorFor: aMNode);
			size: (self sizeFor: aMNode);
			yourself ].

]

{ #category : #visualization }
UrCanvasController >> sizeFor: aHiMNode [
	^ (10 * (aHiMNode children size + 1)) sqrt
]

{ #category : #animations }
UrCanvasController >> startForceAnimationFinitely [
	
	self stopForceAnimation.

	forceAnimation := canvas newAnimation
		easing: RSEasing cubicInOut;
		range: self forceAlphaRangeAsArray reversed;
		duration: 2 seconds;
		onStepDo: [ :t | layout alpha: t; step ];
		yourself
]

{ #category : #animations }
UrCanvasController >> startForceAnimationInfinitely [
	
	self stopForceAnimation.
	
	"Composed animation"
	forceAnimation :=  canvas animationFrom: {

		"Start smoothly"
		canvas transitionAnimation
			easing: RSEasing cubicOut;
			duration: 500 milliSeconds;
			range: self forceAlphaRangeAsArray;
			onStepDo: [ :t | layout alpha: t; step ].

		"Continue on max alpha undefinitely"
		canvas transitionAnimation
			repeat;
			onStepDo: [ :t | layout step ] }.

]

{ #category : #animations }
UrCanvasController >> stopForceAnimation [
	forceAnimation ifNotNil: #stop
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> toggleEdge: aRSEdge [
	| isFromExpanded isToExpanded |
	isFromExpanded := self isMarkedAsExpanded: aRSEdge from.
	isToExpanded := self isMarkedAsExpanded: aRSEdge to.
	
	isFromExpanded & isToExpanded
		ifTrue: [
			self
				executeAndRegisterCollapseIfPossible: aRSEdge from;
				executeAndRegisterCollapseIfPossible: aRSEdge to ]
		ifFalse: [ 
			self
				executeAndRegisterExpandIfPossible: aRSEdge from;
				executeAndRegisterExpandIfPossible: aRSEdge to ]
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> toggleNode: aRSShape [
	(self isMarkedAsExpanded: aRSShape)
		ifTrue: [ self executeAndRegisterCollapseIfPossible: aRSShape ]
		ifFalse: [ self executeAndRegisterExpandIfPossible: aRSShape ]
]

{ #category : #accessing }
UrCanvasController >> topLevelNodes [
	^ topLevelNodes
]

{ #category : #accessing }
UrCanvasController >> topLevelNodes: someHiMNodes [
	topLevelNodes := someHiMNodes.

]
