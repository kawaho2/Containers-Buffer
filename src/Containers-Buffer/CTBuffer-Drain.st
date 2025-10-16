"CTBuffer - drainTo: destinationCollection
File: CTBuffer-Drain.st
"

CTFIFOBuffer>>drainTo: aCollection
    "Move all elements from buffer into aCollection in FIFO order; returns aCollection."
    (aCollection isNil) ifTrue: [ ^ aCollection ].
    (self respondsTo: #internalArray and: #headIndex and: #size) ifTrue: [
        | arr head n i |
        arr := self internalArray.
        head := self headIndex.
        n := self size.
        1 to: n do: [:k |
            i := ((head - 1 + (k - 1)) \\ arr size) + 1.
            aCollection add: (arr at: i) ].
        "reset buffer"
        self clear.
        ^ aCollection ].

    "Fallback: pop repeatedly"
    [ self notEmpty ] whileTrue: [ aCollection add: (self pop) ].
    ^ aCollection.

"Clear helper if not present"
CTFIFOBuffer>>clear
    (self respondsTo: #internalArray: and: #headIndex: and: #tailIndex:) ifTrue: [
        self internalArray: (Array new: self capacity).
        self headIndex: 1.
        self tailIndex: 1.
        ^ self ].
    "Fallback: pop until empty"
    [ self notEmpty ] whileTrue: [ self pop ].
    ^ self.
