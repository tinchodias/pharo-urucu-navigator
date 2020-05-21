Extension { #name : #UrMainPresenter }

{ #category : #'*UrucuNavigator-DependencyAnalysis' }
UrMainPresenter class >> example1 [

	| block |
	block := [ :aCanvasController |
		UrImageDependenciesBuilder new
			canvasController: aCanvasController;
			packageNames: {'Hiedra'. 'Hiedra-Tests'. 'Athens-Cairo'. "'Growl'. 'Iceberg'"};
			build ].

	^ (self new
		setModelBeforeInitialization: block;
		openWithSpec)
		withWindowDo: [ :window | 
			window
				extent: 1000 @ 800;
				title: self name ]
]
