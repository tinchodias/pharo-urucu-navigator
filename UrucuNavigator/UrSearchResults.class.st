Class {
	#name : #UrSearchResults,
	#superclass : #UrAbstractSearchResults,
	#instVars : [
		'nodes',
		'currentIndex'
	],
	#category : #'UrucuNavigator-Model'
}

{ #category : #'instance creation' }
UrSearchResults class >> newWith: someNodes [
	^ self basicNew
		initializeWith: someNodes;
		yourself
]

{ #category : #accessing }
UrSearchResults >> currentIndex [
	^ currentIndex
]

{ #category : #accessing }
UrSearchResults >> currentNode [
	^ nodes at: currentIndex
]

{ #category : #accessing }
UrSearchResults >> goToNextResult [
	currentIndex := (currentIndex \\ nodes size) + 1
]

{ #category : #accessing }
UrSearchResults >> goToPreviousResult [
	currentIndex := currentIndex - 1.
	currentIndex < 1 ifTrue: [ currentIndex := nodes size ].
]

{ #category : #testing }
UrSearchResults >> hasResults [
	^ true
]

{ #category : #initialization }
UrSearchResults >> initializeWith: aNonEmptyCollection [
	self initialize.
	
	nodes := aNonEmptyCollection.
	currentIndex := 1.
]

{ #category : #accessing }
UrSearchResults >> nodes [
	^ nodes
]
