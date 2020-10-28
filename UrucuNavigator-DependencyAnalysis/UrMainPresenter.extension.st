Extension { #name : #UrMainPresenter }

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> example1 [

	| model |
	model := UrImageDependenciesMainModel new
		internalPackageNames: {'Hiedra'. "'Hiedra-Tests'. 'Athens-Cairo'. 'Growl'. 'Iceberg'"};
		yourself.

	^ (self new
		setModelBeforeInitialization: model;
		openWithSpec)
		withWindowDo: [ :window | 
			window
				extent: 500 @ 500;
				title: self name ]
]
