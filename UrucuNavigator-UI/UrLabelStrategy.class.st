Class {
	#name : #UrLabelStrategy,
	#superclass : #Object,
	#instVars : [
		'shapeBuilder',
		'canvasController'
	],
	#category : #'UrucuNavigator-UI-Roassal3'
}

{ #category : #applying }
UrLabelStrategy >> applyAfterAddingElements: elements [
]

{ #category : #accessing }
UrLabelStrategy >> installOn: aUrCanvasController [
	canvasController := aUrCanvasController
]
