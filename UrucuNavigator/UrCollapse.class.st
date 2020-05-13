Class {
	#name : #UrCollapse,
	#superclass : #UrNodeCommand,
	#category : #'UrucuNavigator-UI-Commands'
}

{ #category : #execution }
UrCollapse >> execute [
	navigator collapse: node
]

{ #category : #execution }
UrCollapse >> inverse [
	^ UrExpand new
		navigator: navigator;
		node: node;
		yourself
]
