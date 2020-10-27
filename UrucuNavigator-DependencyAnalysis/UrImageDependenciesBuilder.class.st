Class {
	#name : #UrImageDependenciesBuilder,
	#superclass : #Object,
	#instVars : [
		'packageNames',
		'relationGraph',
		'nodeByDAPackage',
		'nodeByBehavior'
	],
	#category : #'UrucuNavigator-DependencyAnalysis'
}

{ #category : #building }
UrImageDependenciesBuilder >> buildTopLevelNodes [
	relationGraph := DAPackageRelationGraph onPackagesNamed: packageNames.
	relationGraph build.

	relationGraph packages do: [:aDAPackage |
		self ensureAddNodeForPackage: aDAPackage.

"		(relationGraph classesFor: aDAPackage) do: [ :aClass |
			aClass isMeta ifFalse: [
				self ensureAddNodeForClassNamed: aClass name in: aDAPackage] ].

		(relationGraph methodsFor: aDAPackage) do: [ :aMethod | 
			self ensureAddNodeForMethod: aMethod in: aDAPackage ].
"
		aDAPackage dependencies do: [:each | each accept: self ] ]

]

{ #category : #private }
UrImageDependenciesBuilder >> ensureAddNodeForClassNamed: aString in: aPackage [
	self assert: [ (aString endsWith: ' class') not ].

	^ nodeByBehavior
		at: aString
		ifAbsentPut: [ | node |
			node := UrNode for: aString.
			(self ensureAddNodeForPackage: aPackage) addChild: node.
			node ]
]

{ #category : #private }
UrImageDependenciesBuilder >> ensureAddNodeForMethod: aRGMethodDefinition in: aDAPackage [
	| classNode className |
	className := aRGMethodDefinition methodClass instanceSide name.
	
	classNode := self
		ensureAddNodeForClassNamed: className
		in: aDAPackage.

	^ classNode children
		detect: [ :each | each object = aRGMethodDefinition selector ]
		ifNone: [ | node |
			node := UrNode for: aRGMethodDefinition selector.
			classNode addChild: node.
			node ]
]

{ #category : #private }
UrImageDependenciesBuilder >> ensureAddNodeForPackage: aDAPackage [
	^ nodeByDAPackage
		at: aDAPackage
		ifAbsentPut: [ UrNode for: aDAPackage packageName ]
]

{ #category : #initialization }
UrImageDependenciesBuilder >> initialize [
	super initialize.
	
	nodeByDAPackage := Dictionary new.
	nodeByBehavior := Dictionary new.
]

{ #category : #accessing }
UrImageDependenciesBuilder >> internalPackageNames: aCollection [
	packageNames := aCollection
]

{ #category : #accessing }
UrImageDependenciesBuilder >> topLevelNodes [
	^ nodeByDAPackage values
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDACompositeDependency: aDACompositeDependency [
	aDACompositeDependency dependencies do: [ :each | each accept: self ]
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDAExtensionDependency: aDAExtensionDependency [ 

	| from to |
	from := self ensureAddNodeForMethod: aDAExtensionDependency method in: aDAExtensionDependency source.
	to := self ensureAddNodeForClassNamed: aDAExtensionDependency theClass instanceSide name in: aDAExtensionDependency target.
	from addOutgoingLinkTo: to.
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDAInheritanceDependency: aDAInheritanceDependency [
	
	| from to |
	from := self ensureAddNodeForClassNamed: aDAInheritanceDependency theClass name in: aDAInheritanceDependency source.
	to := self ensureAddNodeForClassNamed: aDAInheritanceDependency superclass name in: aDAInheritanceDependency target.
	from addOutgoingLinkTo: to.
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDAMessageSendDependency: aDAMessageSendDependency [

	| from to |
	from := self ensureAddNodeForPackage: aDAMessageSendDependency source.
	to := self ensureAddNodeForPackage: aDAMessageSendDependency target.
	
	from addOutgoingLinkTo: to.
	
	self flag: #todo. "Not true!"
	"from withAllChildrenDo: [:node |
		node addOutgoingLinkTo: to ]."
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDAPoolDictionaryDependency: aDAPoolDictionaryDependency [ 
	self flag: #todo "should be implemented"
]

{ #category : #visiting }
UrImageDependenciesBuilder >> visitDAReferenceDependency: aDAReferenceDependency [ 

	| from to |
	from := self ensureAddNodeForMethod: aDAReferenceDependency method in: aDAReferenceDependency source.
	to := self ensureAddNodeForClassNamed: aDAReferenceDependency reference instanceSide name in: aDAReferenceDependency target.
	from addOutgoingLinkTo: to.
]
