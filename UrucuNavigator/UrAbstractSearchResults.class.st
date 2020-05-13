Class {
	#name : #UrAbstractSearchResults,
	#superclass : #Object,
	#category : #'UrucuNavigator-Model'
}

{ #category : #accessing }
UrAbstractSearchResults >> currentIndex [
	^ self subclassResponsibility

]

{ #category : #accessing }
UrAbstractSearchResults >> currentNode [
	^ self subclassResponsibility

]

{ #category : #accessing }
UrAbstractSearchResults >> goToNextResult [
	^ self subclassResponsibility

]

{ #category : #accessing }
UrAbstractSearchResults >> goToPreviousResult [
	^ self subclassResponsibility

]

{ #category : #accessing }
UrAbstractSearchResults >> hasResults [
	^ self subclassResponsibility

]

{ #category : #accessing }
UrAbstractSearchResults >> nodes [
	^ self subclassResponsibility

]
