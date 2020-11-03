Class {
	#name : #UrImageDependenciesVisualStrategy,
	#superclass : #UrVisualStrategy,
	#instVars : [
		'colorScaleForPackageNames',
		'colorForInternalPackage',
		'internalPackageNames'
	],
	#category : #'UrucuNavigator-DependencyAnalysis'
}

{ #category : #accessing }
UrImageDependenciesVisualStrategy >> colorFor: aUrNode [

	^ self colorForTopParent: aUrNode topParent object
]

{ #category : #private }
UrImageDependenciesVisualStrategy >> colorForTopParent: aPackageName [

	^ (internalPackageNames includes: aPackageName)
		  ifTrue: [ colorForInternalPackage ]
		  ifFalse: [
				| base |
				base := aPackageName readStream upTo: $-.
				(colorScaleForPackageNames scale: base)
					mixed: 0.75
					with: self currentTheme backgroundColor ]
]

{ #category : #initialization }
UrImageDependenciesVisualStrategy >> initialize [
	super initialize.

"	colorScaleForPackageNames := RSColorPalette qualitative set311."
	colorScaleForPackageNames := NSScale category20c.
	colorForInternalPackage := colorScaleForPackageNames scale: nil.
]

{ #category : #accessing }
UrImageDependenciesVisualStrategy >> internalPackageNames [
	^ internalPackageNames
]

{ #category : #accessing }
UrImageDependenciesVisualStrategy >> internalPackageNames: aCollection [
	internalPackageNames := aCollection
]
