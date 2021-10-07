"
An UrMainPresenterTest is a test class for testing the behavior of UrMainPresenter
"
Class {
	#name : #UrMainPresenterTest,
	#superclass : #TestCase,
	#instVars : [
		'window'
	],
	#category : #'UrucuNavigator-UI-Tests-Core'
}

{ #category : #tests }
UrMainPresenterTest >> tearDown [

	window ifNotNil: [ window close ]
]

{ #category : #tests }
UrMainPresenterTest >> testExample2medium [

	window := UrMainPresenter example2medium.
	

]
