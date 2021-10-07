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
				package: 'UrucuNavigator';
				package: 'UrucuNavigator-DependencyAnalysis'
					with: [ spec requires: #('UrucuNavigator' 'UrucuNavigator-UI') ];
				package: 'UrucuNavigator-Tests'
					with: [ spec requires: #('UrucuNavigator') ];
				package: 'UrucuNavigator-UI'
					with: [ spec requires: #('Roassal3' 'UrucuNavigator') ];
				package: 'UrucuNavigator-UI-Tests'
					with: [ spec requires: #('UrucuNavigator-UI') ] ]
]

{ #category : #'external projects' }
BaselineOfUrucuNavigator >> declareRoassal3On: spec [
	spec
		baseline: 'Roassal3'
		with: [ spec repository: 'github://ObjectProfile/Roassal3:master/src' ]
]
