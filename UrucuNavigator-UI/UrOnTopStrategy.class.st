Class {
	#name : #UrOnTopStrategy,
	#superclass : #UrLabelStrategy,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #'as yet unclassified' }
UrOnTopStrategy >> removedTopLabelShape: aRSShape [

	(aRSShape propertyAt: #RSLabeled) remove
]

{ #category : #'as yet unclassified' }
UrOnTopStrategy >> setupCanvasController: x [

	x protoNodeShape addInteraction: x visualStrategy labelInteraction
]

{ #category : #'as yet unclassified' }
UrOnTopStrategy >> setupNewShapes: aCollection [
]
