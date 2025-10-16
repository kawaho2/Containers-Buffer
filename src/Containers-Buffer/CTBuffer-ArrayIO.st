"CTBuffer - toArray / fromArray:
File: CTBuffer-ArrayIO.st
"

CTFIFOBuffer>>toArray
    "Return an Array of elements in FIFO order."
    (self respondsTo: #asArray) ifTrue: [ ^ (self asArray copy) ].
    (self respondsTo: #internalArray and: #headIndex and: #size) ifTrue: [
        | arr head n out i |
        arr := self internalArray.
        head := self headIndex.
        n := self size.
        out := Array new: n.
        1 to: n do: [:k |
            i := ((head - 1 + (k - 1)) \\ arr size) + 1.
            out at: k put: (arr at: i) ].
        ^ out ].
    "Fallback: snapshot by iterator"
    | it out |
    it := self iterator.
    out := OrderedCollection new.
    [ it hasNext ] whileTrue: [ out add: it next ].
    ^ out asArray.

CTFIFOBuffer class>>fromArray: anArray capacity: capIfNil
    "Create and return a new buffer loaded from anArray.
    capIfNil if provided sets initial capacity; otherwise uses anArray size."
    | buf cap |
    cap := (capIfNil ifNil: [ anArray size ]).
    buf := self new: cap.
    anArray do: [:e | buf push: e ].
    ^ buf.
