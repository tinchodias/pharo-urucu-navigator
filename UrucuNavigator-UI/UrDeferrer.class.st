Class {
	#name : #UrDeferrer,
	#superclass : #OmDeferrer,
	#instVars : [
		'maxDefer',
		'firstSchedule'
	],
	#category : #'UrucuNavigator-UI-Experimental'
}

{ #category : #'instance creation' }
UrDeferrer class >> send: selector to: object after: aDuration maxDefer: anotherDuration [

	^ (self send: selector to: object after: aDuration)
		  maxDefer: anotherDuration;
		  yourself
]

{ #category : #accessing }
UrDeferrer >> maxDefer [
	^ maxDefer
]

{ #category : #accessing }
UrDeferrer >> maxDefer: aDuration [

	maxDefer := aDuration
]

{ #category : #scheduling }
UrDeferrer >> runMessageProcess [
	process := [
		
		"Loop until enough time passed since last #schedule"
		[ DateAndTime now < (lastSchedule + duration min: firstSchedule + maxDefer) ]
			whileTrue: [ duration wait ].
			
		"Execute deferred action (if not flushed before) and clean up"
		self flush.
	] fork
]

{ #category : #scheduling }
UrDeferrer >> schedule [
	lastSchedule := DateAndTime now.

	process ifNil: [ 
		firstSchedule := lastSchedule.

		DefaultExecutionEnvironment beActiveDuring: [ self runMessageProcess ]]
]
