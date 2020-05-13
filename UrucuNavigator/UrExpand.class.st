Class {
	#name : #UrExpand,
	#superclass : #UrNodeCommand,
	#category : #'UrucuNavigator-UI-Commands'
}

{ #category : #execution }
UrExpand >> execute [
	navigator expand: node
]

{ #category : #execution }
UrExpand >> inverse [
	^ UrCollapse new
		navigator: navigator;
		node: node;
		yourself
]
