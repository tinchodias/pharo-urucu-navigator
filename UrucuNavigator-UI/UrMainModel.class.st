Class {
	#name : #UrMainModel,
	#superclass : #Object,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #accessing }
UrMainModel >> setupController: aUrCanvasController [
	^ self subclassResponsibility
]

{ #category : #accessing }
UrMainModel >> visualStrategy [
	^ self subclassResponsibility
]
