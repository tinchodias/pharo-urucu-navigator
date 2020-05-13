Extension { #name : #DAPackageDependency }

{ #category : #'*UrucuNavigator' }
DAPackageDependency >> accept: aVisitor [
	^ aVisitor perform: self visitSelector with: self.
]

{ #category : #'*UrucuNavigator' }
DAPackageDependency >> visitSelector [
	^ ('visit', self className, ':') asSymbol
]
