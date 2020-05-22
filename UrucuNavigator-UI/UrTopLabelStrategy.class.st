Class {
	#name : #UrTopLabelStrategy,
	#superclass : #UrLabelStrategy,
	#instVars : [
		'labeledInteraction'
	],
	#category : #'UrucuNavigator-UI-Roassal3'
}

{ #category : #initialization }
UrTopLabelStrategy >> initialize [
	super initialize.
	
	labeledInteraction := RSLabeled new.
	labeledInteraction shapeBuilder labelShape scaleBy: 0.15.
	labeledInteraction model: [ :shape | shape model object ].

]

{ #category : #applying }
UrTopLabelStrategy >> installOn: aUrCanvasController [
	super installOn: aUrCanvasController.
	canvasController protoNodeShape addInteraction: labeledInteraction
]
