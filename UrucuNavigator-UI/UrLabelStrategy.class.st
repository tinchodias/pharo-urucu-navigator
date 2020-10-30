Class {
	#name : #UrLabelStrategy,
	#superclass : #Object,
	#category : #'UrucuNavigator-UI-Core'
}

{ #category : #accessing }
UrLabelStrategy >> removedTopLabelShape: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
UrLabelStrategy >> setupCanvasController: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
UrLabelStrategy >> setupNewShapes: arg1 [ 
	^ self subclassResponsibility
]
