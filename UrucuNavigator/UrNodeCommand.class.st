Class {
	#name : #UrNodeCommand,
	#superclass : #UrCommand,
	#instVars : [
		'node'
	],
	#category : #'UrucuNavigator-Commands'
}

{ #category : #accessing }
UrNodeCommand >> node [
	^ node
]

{ #category : #accessing }
UrNodeCommand >> node: anObject [
	node := anObject
]
