Class {
	#name : #UrCommandHistory,
	#superclass : #Object,
	#instVars : [
		'commandsToUndo',
		'commandsToRedo'
	],
	#category : #'UrucuNavigator-UI-Commands'
}

{ #category : #accessing }
UrCommandHistory >> canRedo [
	^ commandsToRedo notEmpty
]

{ #category : #accessing }
UrCommandHistory >> canUndo [
	^ commandsToUndo notEmpty
]

{ #category : #accessing }
UrCommandHistory >> commandsToRedo [
	^ commandsToRedo
]

{ #category : #accessing }
UrCommandHistory >> commandsToUndo [
	^ commandsToUndo
]

{ #category : #accessing }
UrCommandHistory >> executeAndRegister: aCommand [
	aCommand execute.
	commandsToUndo addLast: aCommand.
	commandsToRedo removeAll.

]

{ #category : #initialization }
UrCommandHistory >> initialize [
	super initialize.
	
	commandsToRedo := LinkedList new.
	commandsToUndo := LinkedList new.
]

{ #category : #accessing }
UrCommandHistory >> redo [
	| aCommand |
	aCommand := commandsToRedo removeFirst.
	aCommand execute.
	commandsToUndo addLast: aCommand.

]

{ #category : #accessing }
UrCommandHistory >> undo [
	| aCommand |
	aCommand := commandsToUndo removeLast.
	aCommand inverse execute.

	commandsToRedo addFirst: aCommand
]
