Class {
	#name : #UrExpand,
	#superclass : #UrNodeCommand,
	#category : #'UrucuNavigator-Commands'
}

{ #category : #execution }
UrExpand >> execute [
	canvasController expand: node
]

{ #category : #execution }
UrExpand >> inverse [
	^ UrCollapse new
		canvasController: canvasController;
		node: node;
		yourself
]
