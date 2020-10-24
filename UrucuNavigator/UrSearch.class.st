Class {
	#name : #UrSearch,
	#superclass : #Object,
	#instVars : [
		'text',
		'topParentNodes',
		'includeBlock'
	],
	#category : #'UrucuNavigator-Search'
}

{ #category : #accessing }
UrSearch >> execute [
	| matchingNodes |
	matchingNodes := Array streamContents: [ :stream |
		topParentNodes do: [ :each |
			each withAllChildrenDo: [ :node |
				(includeBlock cull: node cull: text) ifTrue: [
					stream nextPut: node ] ] ] ].

	^ matchingNodes
		ifEmpty: [ UrNoResults new ] 
		ifNotEmpty: [ UrSearchResults newWith: matchingNodes ]
]

{ #category : #accessing }
UrSearch >> includeBlock [
	^ includeBlock
]

{ #category : #accessing }
UrSearch >> includeBlock: aBlockClosure [
	includeBlock:= aBlockClosure
]

{ #category : #initialization }
UrSearch >> initialize [
	super initialize.
	
	includeBlock := [ :aUrNode :aString |
		aUrNode object includesSubstring: aString caseSensitive: true ].
]

{ #category : #accessing }
UrSearch >> text [
	^ text
]

{ #category : #accessing }
UrSearch >> text: aString [
	text := aString
]

{ #category : #accessing }
UrSearch >> topParentNodes [
	^ topParentNodes
]

{ #category : #accessing }
UrSearch >> topParentNodes: aCollection [
	topParentNodes := aCollection
]
