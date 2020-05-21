Class {
	#name : #UrCommand,
	#superclass : #Object,
	#instVars : [
		'canvasController'
	],
	#category : #'UrucuNavigator-Commands'
}

{ #category : #accessing }
UrCommand >> canvasController [
	^ canvasController
]

{ #category : #accessing }
UrCommand >> canvasController: anObject [
	canvasController := anObject
]
