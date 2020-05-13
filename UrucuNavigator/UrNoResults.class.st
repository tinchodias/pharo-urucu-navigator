Class {
	#name : #UrNoResults,
	#superclass : #UrAbstractSearchResults,
	#category : #'UrucuNavigator-Model'
}

{ #category : #accessing }
UrNoResults >> currentIndex [
	^ self error
]

{ #category : #accessing }
UrNoResults >> currentNode [
	^ self error
]

{ #category : #accessing }
UrNoResults >> goToNextResult [
	^ self error
]

{ #category : #accessing }
UrNoResults >> goToPreviousResult [
	^ self error
]

{ #category : #accessing }
UrNoResults >> hasResults [
	^ false
]

{ #category : #accessing }
UrNoResults >> nodes [
	^ #()

]
