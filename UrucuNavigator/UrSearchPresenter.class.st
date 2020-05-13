"
self new openWithSpec.
"
Class {
	#name : #UrSearchPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'textInput',
		'resultsLabel',
		'previousButton',
		'nextButton',
		'highlightAllButton',
		'searchModel',
		'lastResultModel',
		'newCurrentResultBlock',
		'newResultsBlock',
		'highlightAllEnabled',
		'toggledHighlightAllBlock'
	],
	#category : #'UrucuNavigator-UI'
}

{ #category : #specs }
UrSearchPresenter class >> defaultSpec [
	<spec>
	<script: 'self new openWithSpec'>
	
	^ (SpBoxLayout newHorizontal
			add: #textInput
				withConstraints: [ :constraints |
				 	constraints
					fill: true; expand: true;
						width: 200 ];
			add: #resultsLabel
				withConstraints: [ :constraints | 
					constraints
						fill: false];
			add: #previousButton
				withConstraints: [ :constraints | 
					constraints
						width: 60 ];
			add: #nextButton
				withConstraints: [ :constraints | 
					constraints
						width: 60 ];
			add: #highlightAllButton
				withConstraints: [ :constraints | 
					constraints
						width: 90 ];
			yourself)
]

{ #category : #actions }
UrSearchPresenter >> goToNextResult [
	lastResultModel goToNextResult.
	newCurrentResultBlock value.
	self refresh
]

{ #category : #actions }
UrSearchPresenter >> goToPreviousResult [
	lastResultModel goToPreviousResult.
	newCurrentResultBlock value.
	self refresh.
]

{ #category : #accessing }
UrSearchPresenter >> highlightAllEnabled: aBoolean [
	highlightAllEnabled := aBoolean.
	toggledHighlightAllBlock ifNotNil: [
		toggledHighlightAllBlock value ].

]

{ #category : #initialization }
UrSearchPresenter >> initializeWidgets [
	
	textInput := (self instantiate: SpTextInputFieldPresenter)
"		autoAccept: true;"
		placeholder: 'Search...';
		whenTextChangedDo: [ :newText | self search: newText ];
		yourself.

	resultsLabel := self instantiate: SpLabelPresenter. 

	previousButton := (self instantiate: SpButtonPresenter)
		icon: (self iconNamed: #back);
		label: 'Prev';
		action: [ self goToPreviousResult ];
		yourself.
	
	nextButton := (self instantiate: SpButtonPresenter)
		icon: (self iconNamed: #forward);
		label: 'Next';
		action: [ self goToNextResult ];
		yourself.

	highlightAllButton := (self instantiate: SpToggleButtonPresenter)
		label: 'Highlight all';
		whenChangedDo: [ :newValue | self highlightAllEnabled: newValue ];
		yourself.

	self focusOrder
		add: textInput;
		add: previousButton;
		add: nextButton;
		add: highlightAllButton.

	"Model initialization. TODO: move elsewhere"
	searchModel := UrSearch new.
	searchModel includeBlock: [ :node :text |
		node isTopParent and: [
		node object includesSubstring: text caseSensitive: true] ].
	lastResultModel := UrNoResults new.
	highlightAllEnabled := true.

	self refresh.
	

]

{ #category : #accessing }
UrSearchPresenter >> isHighlightAllEnabled [
	^ highlightAllEnabled
]

{ #category : #accessing }
UrSearchPresenter >> lastResultModel [
	^ lastResultModel
]

{ #category : #accessing }
UrSearchPresenter >> newResultIndexBlock: anObject [
	newCurrentResultBlock := anObject
]

{ #category : #accessing }
UrSearchPresenter >> newResultsBlock: aBlockClosure [ 
	newResultsBlock := aBlockClosure
]

{ #category : #actions }
UrSearchPresenter >> refresh [
	| hasResults |
	hasResults := lastResultModel notNil and: [ lastResultModel hasResults ].
	previousButton enabled: hasResults.
	nextButton enabled: hasResults.
	highlightAllButton state: self isHighlightAllEnabled.

	resultsLabel label:
		(hasResults
			ifFalse: [ '      ' ]
			ifTrue: [
				' {1}/{2} ' format: {
					lastResultModel currentIndex.
					lastResultModel nodes size } ])
]

{ #category : #actions }
UrSearchPresenter >> search: newText [
	searchModel text: newText.
	lastResultModel := searchModel execute.
	newResultsBlock value.
	newCurrentResultBlock value.
	self refresh
]

{ #category : #accessing }
UrSearchPresenter >> searchModel [
	^ searchModel
]

{ #category : #accessing }
UrSearchPresenter >> toggledHighlightAllBlock: aBlockClosure [ 
	toggledHighlightAllBlock := aBlockClosure
]
