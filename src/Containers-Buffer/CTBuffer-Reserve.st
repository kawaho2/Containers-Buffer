"CTBuffer - reserve capacity helper
File: CTBuffer-Reserve.st
Adds -reserve: which ensures capacity >= requested (no-op if already large).
Works with both FIFO (CTFIFOBuffer) and LIFO (CTLIFOBuffer).

If the buffer exposes an internal array (internalArray / storage / bufferArray),
we use an efficient grow path. Otherwise we fall back to snapshot + rebuild.
"

Object subclass: #BufferReserveHelpers
    instanceVariableNames: ''
    classVariableNames: ''
    package: 'Containers-Buffer-Helpers'.

"Public method added as a category method for buffers (evaluates on receiver)"
CTFIFOBuffer>>reserve: newCapacity
    "Ensure this buffer can hold at least newCapacity elements without shrinking current data."
    (newCapacity <= 0) ifTrue: [ ^ self ].
    (self respondsTo: #capacity) ifFalse: [ ^ self ].
    (self capacity >= newCapacity) ifTrue: [ ^ self ].

    "Optimized path: direct internal array replacement if available"
    (self respondsTo: #internalArray) ifTrue: [
        | oldArr newArr cur size head tail i |
        oldArr := self internalArray.
        size := self size.
        newArr := Array new: newCapacity.
        head := (self respondsTo: #headIndex) ifTrue: [ self headIndex ] ifFalse: [ 1 ].
        "copy current elements into newArr in-order"
        1 to: size do: [:k |
            i := ((head - 1 + (k - 1)) \\ oldArr size) + 1.
            newArr at: k put: (oldArr at: i) ].
        "install"
        self internalArray: newArr.
        self headIndex: 1.
        self tailIndex: (size + 1).
        ^ self ].

    "Fallback: snapshot + rebuild using public API"
    | snapshot |
    snapshot := OrderedCollection new.
    [ self isEmpty ] whileFalse: [ snapshot add: (self pop) ].
    "Now buffer is empty; ensure capacity by creating a new instance of same class with newCapacity"
    | newBuf |
    newBuf := (self class new: newCapacity).
    snapshot do: [:e | newBuf push: e ].
    "Replace contents by mutating self if possible (fast path), else return newBuf"
    (self respondsTo: #internalArray: and: #headIndex: and: #tailIndex:) ifTrue: [
        self internalArray: (newBuf internalArray).
        self headIndex: (newBuf headIndex).
        self tailIndex: (newBuf tailIndex).
        ^ self ].
    ^ newBuf.
