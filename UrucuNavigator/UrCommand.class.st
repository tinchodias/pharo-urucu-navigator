Class {
	#name : #UrCommand,
	#superclass : #Object,
	#instVars : [
		'navigator'
	],
	#category : #'UrucuNavigator-Commands'
}

{ #category : #accessing }
UrCommand >> navigator [
	^ navigator
]

{ #category : #accessing }
UrCommand >> navigator: anObject [
	navigator := anObject
]
