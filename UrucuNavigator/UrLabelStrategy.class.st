Class {
	#name : #UrLabelStrategy,
	#superclass : #Object,
	#instVars : [
		'navigator',
		'shapeBuilder'
	],
	#category : #'UrucuNavigator-UI'
}

{ #category : #applying }
UrLabelStrategy >> applyAfterAddingElements: elements [
]

{ #category : #applying }
UrLabelStrategy >> applyBeforeCreatingElementsWith: shapeBuilder [

]

{ #category : #accessing }
UrLabelStrategy >> navigator [
	^ navigator
]

{ #category : #accessing }
UrLabelStrategy >> navigator: anObject [
	navigator := anObject
]

{ #category : #accessing }
UrLabelStrategy >> shapeBuilder [
	^ shapeBuilder ifNil: [
		shapeBuilder := RSShapeBuilder composite
			shapes: [ :m | 
				TSGroup with:
					(TSLabel new
						text: m asString;
						color: (navigator currentTheme textColor alpha: 0.75);
						yourself) ];
			scaleBy: 0.15;
			yourself ]
]

{ #category : #accessing }
UrLabelStrategy >> shapeBuilder: aShapeBuilder [
	shapeBuilder := aShapeBuilder
]
