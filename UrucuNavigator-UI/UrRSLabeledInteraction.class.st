Class {
	#name : #UrRSLabeledInteraction,
	#superclass : #RSInteraction,
	#instVars : [
		'location',
		'labelFactoryBlock'
	],
	#category : #'UrucuNavigator-UI-Roassal3'
}

{ #category : #initialization }
UrRSLabeledInteraction >> initialize [
	super initialize.
	location := RSLocation new above
]

{ #category : #accessing }
UrRSLabeledInteraction >> labelFactoryBlock [
	^ labelFactoryBlock
]

{ #category : #accessing }
UrRSLabeledInteraction >> labelFactoryBlock: anObject [
	labelFactoryBlock := anObject
]

{ #category : #accessing }
UrRSLabeledInteraction >> labelFor: aShape [
	^ aShape properties
		at: self propertyKey
		ifAbsentPut: [ self newLabelFor: aShape ]
]

{ #category : #accessing }
UrRSLabeledInteraction >> location [
	^ location
]

{ #category : #private }
UrRSLabeledInteraction >> newLabelFor: aShape [
	| label |
	label := labelFactoryBlock value: aShape.
	location stick: label on: aShape.
	aShape parent addShape: label.
	aShape when: RSShapeRemovedEvent do: [ label remove ].
	^ label
]

{ #category : #hooks }
UrRSLabeledInteraction >> onShape: aShape [
	aShape isInACanvas
		ifTrue: [ self labelFor: aShape ]
		ifFalse: [
			aShape
				when: RSShapeAddedEvent
				do: [ :evt | self labelFor: evt shape ] ]
]

{ #category : #accessing }
UrRSLabeledInteraction >> propertyKey [
	^ self className
]
