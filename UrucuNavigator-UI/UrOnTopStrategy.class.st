Class {
	#name : #UrOnTopStrategy,
	#superclass : #UrLabelStrategy,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #public }
UrOnTopStrategy >> removedTopLabelShape: aRSShape [

	(aRSShape propertyAt: #RSLabeled) remove
]

{ #category : #public }
UrOnTopStrategy >> setupCanvasController: anUrCanvasController [

	anUrCanvasController protoNodeShape addInteraction:
		anUrCanvasController visualStrategy labelInteraction
]

{ #category : #public }
UrOnTopStrategy >> setupNewShapes: aCollection [
]
