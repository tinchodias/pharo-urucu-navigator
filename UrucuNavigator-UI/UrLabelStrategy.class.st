Class {
	#name : #UrLabelStrategy,
	#superclass : #Object,
	#instVars : [
		'canvasController'
	],
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #'instance creation' }
UrLabelStrategy class >> newWith: anUrCanvasController [

	^ self basicNew
		initializeWith: anUrCanvasController;
		yourself

]

{ #category : #initialization }
UrLabelStrategy >> initializeWith: anUrCanvasController [

	canvasController := anUrCanvasController.
	
	self initialize.

]

{ #category : #public }
UrLabelStrategy >> removedTopLabelShape: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #public }
UrLabelStrategy >> setupCanvasController [

	self subclassResponsibility
]

{ #category : #public }
UrLabelStrategy >> setupNewShapes: arg1 [ 
	^ self subclassResponsibility
]
