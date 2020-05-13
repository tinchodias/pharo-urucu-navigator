Class {
	#name : #BaselineOfUrucuNavigator,
	#superclass : #BaselineOf,
	#category : #BaselineOfUrucuNavigator
}

{ #category : #baseline }
BaselineOfUrucuNavigator >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			self declareRoassal3On: spec.
			spec
				package: 'UrucuNavigator'
				with: [ spec requires: #('Roassal3') ] ]
]

{ #category : #'external projects' }
BaselineOfUrucuNavigator >> declareRoassal3On: spec [
	spec
		baseline: 'Roassal3'
		with: [ spec repository: 'github://ObjectProfile/Roassal3:master/src' ]
]
