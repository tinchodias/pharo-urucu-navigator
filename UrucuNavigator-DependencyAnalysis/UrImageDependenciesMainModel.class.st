Class {
	#name : #UrImageDependenciesMainModel,
	#superclass : #UrMainModel,
	#instVars : [
		'dependenciesBuilder',
		'visualStrategy'
	],
	#category : #'UrucuNavigator-DependencyAnalysis'
}

{ #category : #initialization }
UrImageDependenciesMainModel >> initialize [
	super initialize.
	
	dependenciesBuilder := UrImageDependenciesBuilder new.
	visualStrategy := UrImageDependenciesVisualStrategy new.

]

{ #category : #accessing }
UrImageDependenciesMainModel >> internalPackageNames: aCollection [

	self flag: #todo. "This duplication smells bad".
	dependenciesBuilder internalPackageNames: aCollection.
	visualStrategy internalPackageNames: aCollection.
]

{ #category : #accessing }
UrImageDependenciesMainModel >> setupController: aUrCanvasController [

	dependenciesBuilder buildTopLevelNodes.
	
	aUrCanvasController
		addTopLevelNodesWithShapes: dependenciesBuilder topLevelNodes.

]

{ #category : #accessing }
UrImageDependenciesMainModel >> visualStrategy [

	^ visualStrategy
]
