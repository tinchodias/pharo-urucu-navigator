Class {
	#name : #UrCollapse,
	#superclass : #UrNodeCommand,
	#category : #'UrucuNavigator-Commands'
}

{ #category : #execution }
UrCollapse >> execute [
	canvasController collapse: node
]

{ #category : #execution }
UrCollapse >> inverse [
	^ UrExpand new
		canvasController: canvasController;
		node: node;
		yourself
]
