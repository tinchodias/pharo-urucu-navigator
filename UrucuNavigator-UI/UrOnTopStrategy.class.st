Class {
	#name : #UrOnTopStrategy,
	#superclass : #UrLabelStrategy,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #public }
UrOnTopStrategy >> newLabelInteraction [ 

	^ RSLabeled new
		model: #yourself;
		shapeBuilder: [ :aShape |
			RSComposite new
				shapes: {
					RSLabel new
						text: aShape model object asString;
						yourself };
				yourself ];
		yourself
]

{ #category : #public }
UrOnTopStrategy >> removedTopLabelShape: aRSShape [

	(aRSShape propertyAt: #RSLabeled) remove
]

{ #category : #public }
UrOnTopStrategy >> setupCanvasController [

	canvasController protoNodeShape addInteraction:
		self newLabelInteraction
]

{ #category : #public }
UrOnTopStrategy >> setupNewShapes: aCollection [
]
