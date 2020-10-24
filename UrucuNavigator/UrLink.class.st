Class {
	#name : #UrLink,
	#superclass : #Object,
	#instVars : [
		'from',
		'to'
	],
	#category : #'UrucuNavigator-Graph'
}

{ #category : #'instance creation' }
UrLink class >> from: aNode to: anotherNode [
	^ self new
		from: aNode;
		to: anotherNode;
		yourself
]

{ #category : #accessing }
UrLink >> from [
	^ from
]

{ #category : #accessing }
UrLink >> from: anObject [
	from := anObject
]

{ #category : #printing }
UrLink >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: from object;
		nextPutAll: '->';
		print: to object;
		nextPut: $).
]

{ #category : #accessing }
UrLink >> to [
	^ to
]

{ #category : #accessing }
UrLink >> to: anObject [
	to := anObject
]
