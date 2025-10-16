"CTBuffer - peekAt: nth (0-based from head)
File: CTBuffer-PeekAt.st
"

CTFIFOBuffer>>peekAt: offset
    "Return the element at offset (0-based) from head without removing it. Nil if out of range."
    (offset isKindOf: Integer) ifFalse: [ ^ nil ].
    (offset < 0 or: [ offset >= self size ]) ifTrue: [ ^ nil ].

    "Optimized if internalArray and headIndex known"
    (self respondsTo: #internalArray and: #headIndex) ifTrue: [
        | arr head idx |
        arr := self internalArray.
        head := self headIndex.
        idx := ((head - 1 + offset) \\ arr size) + 1.
        ^ arr at: idx ].

    "Fallback: snapshot by popping then pushing back (stable for small sizes)"
    | tmp i v |
    tmp := OrderedCollection new.
    1 to: (offset) do: [:i | tmp add: (self pop) ].
    v := self pop.
    tmp do: [:e | self push: e ].
    self push: v.
    ^ v.

"Symmetric for LIFO"
CTLIFOBuffer>>peekAt: offset
    "For LIFO peekAt: 0 returns top"
    (offset isKindOf: Integer) ifFalse: [ ^ nil ].
    (offset < 0 or: [ offset >= self size ]) ifTrue: [ ^ nil ].
    (self respondsTo: #internalArray and: #tailIndex) ifTrue: [
        | arr tail idx |
        arr := self internalArray.
        tail := self tailIndex.
        idx := ((tail - 2 - offset) \\ arr size) + 1.
        ^ arr at: idx ].
    "Fallback: pop offset times"
    | tmp i v |
    tmp := OrderedCollection new.
    1 to: offset do: [:i | tmp add: (self pop) ].
    v := self pop.
    tmp reverseDo: [:e | self push: e ].
    self push: v.
    ^ v.
