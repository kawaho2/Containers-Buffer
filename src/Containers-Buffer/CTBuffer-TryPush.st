"CTBuffer - tryPush: timeout:
File: CTBuffer-TryPush.st
"

CTFIFOBuffer>>tryPush: anObject timeout: ms
    "Try to push anObject into buffer; if full, retry until ms milliseconds exhausted. Return true if pushed, false otherwise."
    | deadline ok |
    (ms <= 0) ifTrue: [ ^ (self size < self capacity) ifTrue: [ self push: anObject. ^ true ] ifFalse: [ ^ false ] ].
    deadline := (Time millisecondClockValue + ms).
    [ (self size < self capacity) and: [ (self push: anObject) ifNotNil: [ true ] ] ] whileFalse: [
        (Time millisecondClockValue > deadline) ifTrue: [ ^ false ].
        (Delay forMilliseconds: 1) wait ].
    ^ true.
