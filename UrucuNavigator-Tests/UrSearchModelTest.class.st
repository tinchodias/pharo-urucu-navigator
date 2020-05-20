Class {
	#name : #UrSearchModelTest,
	#superclass : #TestCase,
	#instVars : [
		'search',
		'root1',
		'root2',
		'child1',
		'child2',
		'results'
	],
	#category : #'UrucuNavigator-Tests'
}

{ #category : #tests }
UrSearchModelTest >> setUp [
	root1 := UrNode for: 'root1'.
	root2 := UrNode for: 'root2'.
	child1 := UrNode for: 'child1'.
	child2 := UrNode for: 'child2'.
	root1 addChild: child1.
	root2 addChild: child2.
	root1 addOutgoingLinkTo: child2.

	search := UrSearch new.
	search topParentNodes: { root1. root2 }.

]

{ #category : #tests }
UrSearchModelTest >> testSearchEmptyText [
	
	search text: ''.
	results := search execute.
	
	self assertEmpty: results nodes.
	self deny: results hasResults.
]

{ #category : #tests }
UrSearchModelTest >> testSearchOneChild [
	
	search text: 'child1'.
	results := search execute.
	
	self assert: results nodes equals: { child1 }.
	self assert: results currentIndex equals: 1.
	
	results goToNextResult.
	self assert: results currentIndex equals: 1.

	results goToPreviousResult.
	self assert: results currentIndex equals: 1.

]

{ #category : #tests }
UrSearchModelTest >> testSearchTwoRoots [
	
	search text: 'roo'.
	results := search execute.
	
	self assert: results nodes equals: { root1. root2 }.
	self assert: results currentIndex equals: 1.
	
	results goToNextResult.
	self assert: results currentIndex equals: 2.
	results goToNextResult.
	self assert: results currentIndex equals: 1.

	results goToPreviousResult.
	self assert: results currentIndex equals: 2.
	results goToPreviousResult.
	self assert: results currentIndex equals: 1.

]
