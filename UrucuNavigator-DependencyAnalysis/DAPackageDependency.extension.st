Extension { #name : #DAPackageDependency }

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
DAPackageDependency >> accept: aVisitor [
	^ aVisitor perform: self visitSelector with: self.
]

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
DAPackageDependency >> visitSelector [
	^ ('visit', self className, ':') asSymbol
]
