"CTBuffer - snapshot iterator (stable while buffer mutates)
File: CTBuffer-Iterator.st
"

Object subclass: #CTBufferIterator
    instanceVariableNames: 'snapshot index'
    classVariableNames: ''
    package: 'Containers-Buffer-Iteration'.

CTBufferIterator>>initializeFrom: aBuffer
    snapshot := OrderedCollection new.
    "If buffer has asArray, use it; else pop/push snapshot approach"
    (aBuffer respondsTo: #asArray) ifTrue: [
        snapshot := (aBuffer asArray) asOrderedCollection.
        index := 0.
        ^ self ].

    "Try efficient internalArray copy"
    (aBuffer respondsTo: #internalArray and: #headIndex and: #size) ifTrue: [
        | arr head n i |
        arr := aBuffer internalArray.
        head := aBuffer headIndex.
        n := aBuffer size.
        1 to: n do: [:k |
            i := ((head - 1 + (k - 1)) \\ arr size) + 1.
            snapshot add: (arr at: i) ].
        index := 0.
        ^ self ].

    "Fallback: destructive safe snapshot - pop everything and push back"
    | temp |
    temp := OrderedCollection new.
    [ aBuffer notEmpty ] whileFalse: [ "nothing" ].
    [ aBuffer notEmpty ] whileTrue: [ temp add: (aBuffer pop) ].
    temp do: [:e | aBuffer push: e. snapshot add: e ].
    index := 0.
    ^ self.

CTBufferIterator>>hasNext
    ^ index < snapshot size.

CTBufferIterator>>next
    (self hasNext) ifFalse: [ self error: 'No next' ].
    index := index + 1.
    ^ snapshot at: index.

"Factory"
CTFIFOBuffer>>iterator
    ^ (CTBufferIterator new initializeFrom: self).

CTLIFOBuffer>>iterator
    ^ (CTBufferIterator new initializeFrom: self).
