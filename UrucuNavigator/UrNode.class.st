"
I'm a directed graph node that's hierarchical: can have a parent and multiple children.

"
Class {
	#name : #UrNode,
	#superclass : #Object,
	#instVars : [
		'children',
		'object',
		'outgoingLinks',
		'incomingLinks',
		'parent'
	],
	#category : #'UrucuNavigator-Graph'
}

{ #category : #'instance creation' }
UrNode class >> for: anObject [
	^ self new object: anObject; yourself
]

{ #category : #accessing }
UrNode >> addChild: anotherNode [
	anotherNode basicParent: self.
	children add: anotherNode.
]

{ #category : #accessing }
UrNode >> addOutgoingLinkTo: anotherNode [
	
	| link |
	link := UrLink from: self to: anotherNode.
	self basicAddOutgoingLink: link.
	anotherNode basicAddIncomingLink: link.
	^ link
]

{ #category : #accessing }
UrNode >> allIncomingLinks [
	^ Array streamContents: [ :stream |
		self withAllChildrenDo: [:each | 
			stream nextPutAll: each incomingLinks ] ]
]

{ #category : #accessing }
UrNode >> allIncomingNodes [
	^ Array streamContents: [ :stream |
		self withAllChildrenDo: [:each | 
			each incomingLinks do: [ :link |
				stream nextPut: link from ] ] ]
]

{ #category : #accessing }
UrNode >> allOutgoingLinks [
	^ Array streamContents: [ :stream |
		self withAllChildrenDo: [:each | 
			stream nextPutAll: each outgoingLinks ] ]
]

{ #category : #accessing }
UrNode >> allOutgoingNodes [
	^ Array streamContents: [ :stream |
		self withAllChildrenDo: [:each | 
			each outgoingLinks do: [ :link |
				stream nextPut: link from ] ] ]
]

{ #category : #accessing }
UrNode >> basicAddIncomingLink: link [
	incomingLinks add: link

]

{ #category : #accessing }
UrNode >> basicAddOutgoingLink: link [
	outgoingLinks add: link

]

{ #category : #accessing }
UrNode >> basicParent: anotherNode [
	parent := anotherNode
]

{ #category : #accessing }
UrNode >> children [
	^ children
]

{ #category : #testing }
UrNode >> hasChildren [
	^ children notEmpty
]

{ #category : #accessing }
UrNode >> incomingLinks [
	^ incomingLinks
]

{ #category : #accessing }
UrNode >> incomingNodes [
	^ Array streamContents: [ :stream |
		incomingLinks do: [ :link |
			stream nextPut: link from ] ]
]

{ #category : #accessing }
UrNode >> initialize [
	super initialize.
	
	incomingLinks := OrderedCollection new.
	outgoingLinks := OrderedCollection new.
	children := OrderedCollection new.
]

{ #category : #testing }
UrNode >> isTopParent [
	^ parent isNil
]

{ #category : #accessing }
UrNode >> object [
	^ object
]

{ #category : #accessing }
UrNode >> object: anObject [
	object := anObject
]

{ #category : #accessing }
UrNode >> outgoingLinks [
	^ outgoingLinks
]

{ #category : #accessing }
UrNode >> outgoingNodes [
	^ Array streamContents: [ :stream |
		outgoingLinks do: [ :link |
			stream nextPut: link to ] ]
]

{ #category : #accessing }
UrNode >> parent [
	^ parent
]

{ #category : #printing }
UrNode >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: object;
		nextPut: $)
		
]

{ #category : #accessing }
UrNode >> topParent [
	^ parent ifNil: [ self ] ifNotNil: [ parent topParent ]
]

{ #category : #enumerating }
UrNode >> withAllChildrenDo: aBlockClosure [ 
	aBlockClosure value: self.
	children do: [ :each |
		each withAllChildrenDo: aBlockClosure ]
]

{ #category : #accessing }
UrNode >> withAllParents [
	^ Array streamContents: [:stream | self withAllParentsDo: [ :each | stream nextPut: each ] ]
]

{ #category : #enumerating }
UrNode >> withAllParentsDo: aBlockClosure [ 
	aBlockClosure value: self.
	parent ifNotNil: [ parent withAllParentsDo: aBlockClosure ]
]
