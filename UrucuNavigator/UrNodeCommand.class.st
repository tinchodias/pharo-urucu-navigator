Class {
	#name : #UrNodeCommand,
	#superclass : #UrCommand,
	#instVars : [
		'node'
	],
	#category : #'UrucuNavigator-UI-Commands'
}

{ #category : #accessing }
UrNodeCommand >> node [
	^ node
]

{ #category : #accessing }
UrNodeCommand >> node: anObject [
	node := anObject
]
