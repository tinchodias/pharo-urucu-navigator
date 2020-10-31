Class {
	#name : #UrLabelStrategy,
	#superclass : #Object,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #public }
UrLabelStrategy >> removedTopLabelShape: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #public }
UrLabelStrategy >> setupCanvasController: anUrCanvasController [

	^ self subclassResponsibility
]

{ #category : #public }
UrLabelStrategy >> setupNewShapes: arg1 [ 
	^ self subclassResponsibility
]
