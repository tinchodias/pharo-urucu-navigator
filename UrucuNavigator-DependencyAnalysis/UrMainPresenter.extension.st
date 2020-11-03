Extension { #name : #UrMainPresenter }

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> example1small [

	^ self exampleImageDependencies: { 'Hiedra' }

]

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> example2medium [

	^ self exampleImageDependencies: {
		'Hiedra'. 'Hiedra-Tests'. 'Athens-Cairo' }

]

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> example3large [

	^ self exampleImageDependencies: {
		'Hiedra'. 'Hiedra-Tests'. 'Athens-Cairo'. 'Growl'. 'Iceberg' }

]

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> exampleImageDependencies: packageNames [

	| model |
	model := UrImageDependenciesMainModel new
		internalPackageNames: packageNames;
		yourself.

	^ (self new
		setModelBeforeInitialization: model;
		openWithSpec)
		withWindowDo: [ :window | 
			window
				extent: 800 @ 500;
				title: self name ]
]
