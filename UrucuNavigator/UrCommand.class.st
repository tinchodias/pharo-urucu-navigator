Class {
	#name : #UrCommand,
	#superclass : #Object,
	#instVars : [
		'navigator'
	],
	#category : #'UrucuNavigator-UI-Commands'
}

{ #category : #accessing }
UrCommand >> navigator [
	^ navigator
]

{ #category : #accessing }
UrCommand >> navigator: anObject [
	navigator := anObject
]
