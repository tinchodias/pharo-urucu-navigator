Class {
	#name : #UrCanvasController,
	#superclass : #Object,
	#instVars : [
		'layout',
		'commandHistory',
		'topLevelNodes',
		'forceAnimation',
		'canvas',
		'protoNodeShape',
		'visualStrategy'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #examples }
UrCanvasController class >> new [
	^ self shouldNotImplement
]

{ #category : #examples }
UrCanvasController class >> newOn: aRSCanvas visualStrategy: aUrVisualStrategy [
	^ self basicNew
		initializeOn: aRSCanvas
			visualStrategy: aUrVisualStrategy;
		yourself
]

{ #category : #visualization }
UrCanvasController >> addEdgesFor: someRSShapes [

	| edgeBuilder edges |
	edgeBuilder := visualStrategy newEdgeBuilderForTopLevelElements
		canvas: canvas;
		yourself.
		
	edgeBuilder shape
		popupText: [:model | model key object asString, '->', model value object asString ];
		addInteraction: visualStrategy hoverInteractionForEdges;
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
		(layout mockEdgeAt: anEdge) length: (visualStrategy edgeLengthFor: anEdge) ].
	
	edges do: #pushBack.

]

{ #category : #visualization }
UrCanvasController >> addNestedEdgesFor: someRSElements [

	| edgeBuilder |
	edgeBuilder := visualStrategy newEdgeBuilderForNestedElements
		canvas: canvas;
		yourself.

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

{ #category : #accessing }
UrCanvasController >> addTopLevelNodes: someUrNodes [

	| newShapes |
	topLevelNodes addAll: someUrNodes.
	newShapes := self shapesFor: someUrNodes.
	canvas addAll: newShapes.
	layout addNodes: newShapes.
	self addEdgesFor: newShapes.
	self startForceAnimationFinitely.
]

{ #category : #accessing }
UrCanvasController >> canvas [
	^ canvas
]

{ #category : #'expanding-collapsing' }
UrCanvasController >> collapse: aRSShape [

	self startForceAnimationFinitely.
	self startCollapseAnimationOn: aRSShape.
	self mark: aRSShape asExpanded: false.

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
	self startExpandAnimationOn: aRSShape.

	self mark: aRSShape asExpanded: true.
]

{ #category : #animations }
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
				mockEdge length: (visualStrategy edgeLengthFor: anEdge) ]
		 ]
]

{ #category : #animations }
UrCanvasController >> expandDuration [
	^ 150 milliSeconds
]

{ #category : #animations }
UrCanvasController >> forceAlphaRangeAsArray [
	^ #(0 0.1)
]

{ #category : #initialization }
UrCanvasController >> initializeOn: aRSCanvas visualStrategy: aUrVisualStrategy [
	self initialize.

	visualStrategy := aUrVisualStrategy.
	commandHistory := UrCommandHistory new.
	topLevelNodes := OrderedCollection new.

	canvas := aRSCanvas.
	visualStrategy setupCanvas: aRSCanvas.

	layout := RSRectangleForceLayout new.
	visualStrategy setupLayout: layout.
	layout start.

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

	"Listen for key bindings"	
	canvas
		when: RSKeyDown
		do: [ :evt | self processKeyDown: evt ].

	"Initialize stuff for node shapes"
	protoNodeShape := RSComposite new
		addInteraction: (RSPopup new text: [ :each | each object ]; yourself);
		addInteraction: (RSDraggableForce new layout: layout; yourself);
		addInteraction: visualStrategy labelInteraction;
		addInteraction: visualStrategy hoverInteractionForShapes;
		when: RSMouseDragStart do: [:evt | evt shape pushFront. self startForceAnimationInfinitely ];
		when: RSMouseDragEnd do: [:evt | self startForceAnimationFinitely ];
		when: RSMouseDoubleClick do: [:evt | self toggleNode: evt shape ];
		yourself.

]

{ #category : #'expanding-collapsing' }
UrCanvasController >> isMarkedAsExpanded: aRSShape [
	^ aRSShape propertyAt: #expanded ifAbsentPut: [ false ]
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
UrCanvasController >> newNestedShapesForAll: someUrNodes [
	^ someUrNodes collect: [ :each | 
		visualStrategy newShapeForNestedNode: each ]

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
UrCanvasController >> shapesFor: someUrNodes [
	^ someUrNodes collect: [ :node |
		protoNodeShape copyWithAnnouncer
			model: node;
			color: (visualStrategy colorFor: node);
			size: (visualStrategy sizeFor: node);
			yourself ]

]

{ #category : #animations }
UrCanvasController >> startCollapseAnimationOn: aRSShape [
	| endSize |
	endSize := visualStrategy sizeFor: aRSShape model.

	aRSShape newAnimation
		duration: self expandDuration;
		from: 1@1;
		to: endSize / aRSShape extent;
		onStepDo: [ :t | self expand: aRSShape step: t ];
		when: RSAnimationEndEvent do: [ | position |
			aRSShape children copy do: [ :each |
				each connectedEdges copy do: #remove.
				each remove ].
			position := aRSShape position.
			aRSShape matrix
				loadIdentity;
				translation: position.
			aRSShape size: endSize ].

]

{ #category : #animations }
UrCanvasController >> startExpandAnimationOn: aRSShape [

	aRSShape newAnimation
		duration: self expandDuration;
		from: (visualStrategy sizeFor: aRSShape model) / aRSShape extent;
		to: 1@1;
		onStepDo: [ :t | self expand: aRSShape step: t ].

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
