Class {
	#name : #UrNodeTest,
	#superclass : #TestCase,
	#category : #'UrucuNavigator-Tests'
}

{ #category : #tests }
UrNodeTest >> testAddChild [

	| root1 child1 |
	root1 := UrNode for: 1.
	child1 := UrNode for: 11.
	root1 addChild: child1.
	
	self assert: root1 children asArray equals: { child1 }.
	self assert: child1 parent equals: root1.

]

{ #category : #tests }
UrNodeTest >> testChildrenLevelLink [

	| root1 root2 child1 child2 |
	root1 := UrNode for: 1.
	root2 := UrNode for: 2.
	child1 := UrNode for: 11.
	child2 := UrNode for: 21.
	root1 addChild: child1.
	root2 addChild: child2.
	child1 addOutgoingLinkTo: child2.
	
	self assert: root1 incomingLinks size equals: 0.
	self assert: root1 outgoingLinks size equals: 0.
	self assert: root1 allIncomingLinks size equals: 0.
	self assert: root1 allOutgoingLinks size equals: 1.
	
	self assert: root2 incomingLinks size equals: 0.
	self assert: root2 outgoingLinks size equals: 0.
	self assert: root2 allIncomingLinks size equals: 1.
	self assert: root2 allOutgoingLinks size equals: 0.

	self assert: child1 incomingLinks size equals: 0.
	self assert: child1 outgoingLinks size equals: 1.
	self assert: child1 incomingNodes asArray equals: {}.
	self assert: child1 outgoingNodes asArray equals: { child2 }.

	self assert: child2 incomingLinks size equals: 1.
	self assert: child2 outgoingLinks size equals: 0.
	self assert: child2 incomingNodes asArray equals: { child1 }.
	self assert: child2 outgoingNodes asArray equals: {}.

]

{ #category : #tests }
UrNodeTest >> testCrossedLevelLink [

	| root1 root2 child1 child2 |
	root1 := UrNode for: 1.
	root2 := UrNode for: 2.
	child1 := UrNode for: 11.
	child2 := UrNode for: 21.
	root1 addChild: child1.
	root2 addChild: child2.
	root1 addOutgoingLinkTo: child2.
	
	self assert: root1 incomingLinks size equals: 0.
	self assert: root1 outgoingLinks size equals: 1.
	self assert: root1 allIncomingLinks size equals: 0.
	self assert: root1 allOutgoingLinks size equals: 1.
	
	self assert: root2 incomingLinks size equals: 0.
	self assert: root2 outgoingLinks size equals: 0.
	self assert: root2 allIncomingLinks size equals: 1.
	self assert: root2 allOutgoingLinks size equals: 0.

]

{ #category : #tests }
UrNodeTest >> testRootLevelLink [

	| root1 root2 |
	root1 := UrNode for: 1.
	root2 := UrNode for: 2.
	
	root1 addOutgoingLinkTo: root2.
	
	self assert: root1 incomingLinks size equals: 0.
	self assert: root1 outgoingLinks size equals: 1.
	self assert: root1 allIncomingLinks size equals: 0.
	self assert: root1 allOutgoingLinks size equals: 1.
	self assert: root1 incomingNodes asArray equals: {}.
	self assert: root1 outgoingNodes asArray equals: { root2 }.
	
	self assert: root2 incomingLinks size equals: 1.
	self assert: root2 outgoingLinks size equals: 0.
	self assert: root2 allIncomingLinks size equals: 1.
	self assert: root2 allOutgoingLinks size equals: 0.
	self assert: root2 incomingNodes asArray equals: { root1 }.
	self assert: root2 outgoingNodes asArray equals: {}.


]

{ #category : #tests }
UrNodeTest >> testTopParent [

	| node1 node2 node3 |
	node1 := UrNode for: 1.
	node2 := UrNode for: 2.
	node3 := UrNode for: 3.

	node1 addChild: node2.
	node2 addChild: node3.
	
	self assert: node1 topParent equals: node1.
	self assert: node2 topParent equals: node1.
	self assert: node3 topParent equals: node1.

]

{ #category : #tests }
UrNodeTest >> testWithAllParents [

	| node1 node2 node3 |
	node1 := UrNode for: 1.
	node2 := UrNode for: 2.
	node3 := UrNode for: 3.

	node1 addChild: node2.
	node2 addChild: node3.
	
	self assert: node1 withAllParents equals: { node1 }.
	self assert: node2 withAllParents equals: { node2. node1 }.
	self assert: node3 withAllParents equals: { node3. node2. node1 }.

]
