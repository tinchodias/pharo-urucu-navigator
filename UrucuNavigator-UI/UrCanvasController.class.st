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
		'visualStrategy',
		'labelStrategy'
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

	| edgeBuilder edges blockToEnsureEdges |
	edgeBuilder := visualStrategy newEdgeBuilderForTopLevelElements
		canvas: canvas;
		yourself.
		
	edgeBuilder shape
		popupText: [:model | model key object asString, '->', model value object asString ];
		addInteraction: visualStrategy hoverInteractionForEdges;
		addInteraction: self newMenuInteractionForEdges;
		when: RSMouseDoubleClick do: [:evt | self toggleEdge: evt shape ].

	"Collect all possible links"
	edges := OrderedCollection new.

	blockToEnsureEdges := [ :fromShape :toShape |
		"If it is present in the canvas..."
		(fromShape isNil or: [ toShape isNil ]) ifFalse: [
			"If it is not already there..."
			(fromShape isDirectlyConnectedTo: toShape) ifFalse: [
				| newEdge |
				newEdge := edgeBuilder edgeFrom: fromShape to: toShape.
				"Explanation: The shape of the edge builder is a prototype that is copied
				without the announcer in #edgeFrom:to:. We make it shared as an optimization."
				newEdge announcer: edgeBuilder shape announcer.
				"Collect it"
				edges add: newEdge ] ] ].
	
	someRSShapes do: [ :aRSShape |
		(aRSShape model allIncomingNodes flatCollect: #withAllParents)
			do: [ :fromModel |
				blockToEnsureEdges
					value: (canvas shapeFromModel: fromModel)
					value: aRSShape ].

		(aRSShape model allOutgoingNodes flatCollect: #withAllParents)
			do: [ :toModel |
				blockToEnsureEdges
					value: aRSShape
					value: (canvas shapeFromModel: toModel) ].
		].

	layout addLines: edges.
	edges do: [ :anEdge |
		(layout mockLineAt: anEdge ifPresent: [ : mockLine | mockLine length: (visualStrategy edgeLengthFor: anEdge) ]) ].
	
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
UrCanvasController >> addTopLevelNodesWithShapes: someUrNodes [

	| newShapes |
	topLevelNodes addAll: someUrNodes.
	newShapes := self shapesFor: someUrNodes.
	canvas addAll: newShapes.
	layout addNodes: newShapes.
	labelStrategy setupNewShapes: newShapes.
	
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

{ #category : #'dissolving-undissolving' }
UrCanvasController >> dissolve: aRSShape [ 

	| oldPosition newShapes childrenNodes |
	oldPosition := aRSShape position.

	self removeTopLevelShape: aRSShape.

	childrenNodes := aRSShape model children.
	newShapes := (self shapesFor: childrenNodes) asGroup.

	aRSShape nodes
		ifEmpty: [
			visualStrategy layoutNestedShapes: newShapes.
			oldPosition := oldPosition - (newShapes extent / 2).
			newShapes do: [ :new |
				new translateBy: oldPosition ] ]
		ifNotEmpty: [ :oldChildrenShapes |
			oldChildrenShapes with: newShapes do: [ :old :new |
				new position: oldPosition + old position ]
			].

	topLevelNodes addAll: childrenNodes.
	canvas addAll: newShapes.
	layout addNodes: newShapes.
	labelStrategy setupNewShapes: newShapes.
	self addEdgesFor: newShapes.
	self startForceAnimationAfterDissolve.

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
	visualStrategy expand: aRSShape nesting: nestedShapes.
	
	aRSShape pushFront.
	
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
	
	labelStrategy := UrSidesStrategy newWith: self.
	
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
		addInteraction: (RSDraggableForceInteraction new layout: layout; yourself);
		addInteraction: self newMenuInteractionForNodes;
		when: RSMouseDragStart do: [:evt | evt shape pushFront. self startForceAnimationInfinitely ];
		when: RSMouseDragEnd do: [:evt | self startForceAnimationFinitely ];
		when: RSMouseDoubleClick do: [:evt | self toggleNode: evt shape ];
		border: (RSBorder new width: 1; yourself);
		yourself.

	labelStrategy setupCanvasController.
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

{ #category : #initialization }
UrCanvasController >> newMenuInteractionForEdges [

	^ RSMenuActivable new
		menuDo: [ :menu :aRSShape | 
			
			menu
				add: 'Expand/Collapse Toggle'
				target: self
				selector: #toggleEdge:
				argument: aRSShape.

			menu
				add: 'Inspect'
				target: aRSShape
				selector: #inspect
				
			];
		yourself
]

{ #category : #initialization }
UrCanvasController >> newMenuInteractionForNodes [

	^ RSMenuActivable new
		menuDo: [ :menu :aRSShape | 
			
			(self isMarkedAsExpanded: aRSShape)
				ifTrue: [ 
					menu
						add: 'Collapse'
						target: self
						selector: #executeAndRegisterCollapseIfPossible:
						argument: aRSShape ]
				ifFalse: [
					menu
						add: 'Expand'
						target: self
						selector: #executeAndRegisterExpandIfPossible:
						argument: aRSShape ].
			
			aRSShape model hasChildren ifTrue: [
				menu
					add: 'Dissolve'
					target: self
					selector: #dissolve:
					argument: aRSShape ].

			aRSShape model isTopParent ifFalse: [	
				menu
					add: 'Un-Dissolve'
					target: self
					selector: #undissolve:
					argument: aRSShape ].

			menu
				add: 'Inspect'
				target: aRSShape
				selector: #inspect
				
				 ];
			yourself
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

{ #category : #private }
UrCanvasController >> removeTopLevelShape: aRSShape [ 

	topLevelNodes remove: aRSShape model.
	aRSShape remove.
	aRSShape connectedEdges do: [ :each | layout removeEdge: each ].
	layout removeNode: aRSShape.

	labelStrategy removedTopLabelShape: aRSShape.
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
			aRSShape size: endSize.
			aRSShape color: (visualStrategy colorFor: aRSShape model) ]

]

{ #category : #animations }
UrCanvasController >> startExpandAnimationOn: aRSShape [

	aRSShape newAnimation
		duration: self expandDuration;
		from: (visualStrategy sizeFor: aRSShape model) / aRSShape extent;
		to: 1@1;
		onStepDo: [ :t | self expand: aRSShape step: t ];
		when: RSAnimationEndEvent do: [
			aRSShape color: visualStrategy backgroundColor ]

]

{ #category : #animations }
UrCanvasController >> startForceAnimationAfterDissolve [
	
	self stopForceAnimation.

	forceAnimation := canvas newAnimation
		easing: RSEasingInterpolator cubicInOut;
		scale: (NSLinearScale new domain: #(0 0.1 1); range: #(0 0.2 0); yourself);
		duration: 2 seconds;
		onStepDo: [ :t | layout alpha: t; step ];
		yourself
]

{ #category : #animations }
UrCanvasController >> startForceAnimationFinitely [
	
	self stopForceAnimation.

	forceAnimation := canvas newAnimation
		easing: RSEasingInterpolator cubicInOut;
		range: self forceAlphaRangeAsArray reversed;
		duration: 3 seconds;
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
			easing: RSEasingInterpolator cubicOut;
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

{ #category : #'dissolving-undissolving' }
UrCanvasController >> undissolve: aRSShape [ 

	| parentNode childrenNodes childrenShapes originalPositions targetPosition |
	parentNode := aRSShape model parent.
	childrenNodes := parentNode children.
	childrenShapes := childrenNodes collect: [ :each |
		canvas shapeFromModel: each ].

	originalPositions := childrenShapes collect: #position.
	targetPosition := aRSShape position.
	canvas newAnimation 
		easing: RSEasingInterpolator cubicInOut;
		duration: 0.5 seconds;

		onStepDo: [ :t |
			childrenShapes doWithIndex: [ :e :i |
				e translateTo:
					((originalPositions at: i) 
						interpolateTo: targetPosition at: t) ].
			 ];

		when: RSAnimationEndEvent
		do: [ :evt |
			| collectionWithParentShape |

			childrenShapes do: [ :each |
				self removeTopLevelShape: each ].

			collectionWithParentShape := self shapesFor: { parentNode }.
			collectionWithParentShape first translateBy: aRSShape position.

			topLevelNodes add: parentNode.
			canvas addAll: collectionWithParentShape.
			layout addNodes: collectionWithParentShape.
			labelStrategy setupNewShapes: collectionWithParentShape.
			self addEdgesFor: collectionWithParentShape.
			
			self startForceAnimationFinitely ].

			
				
			

]

{ #category : #accessing }
UrCanvasController >> visualStrategy [
	^ visualStrategy
]
