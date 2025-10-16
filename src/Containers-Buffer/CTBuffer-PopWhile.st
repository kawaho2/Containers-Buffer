"CTBuffer - popWhile:
File: CTBuffer-PopWhile.st
"

CTFIFOBuffer>>popWhile: predicateBlock
    "Pop from head while predicateBlock value: (peekAt:0) is true. Return collection of popped items."
    | popped |
    popped := OrderedCollection new.
    [ (self notEmpty) and: [ predicateBlock value: (self peekAt: 0) ] ] whileTrue: [
        popped add: (self pop) ].
    ^ popped.

"Provide peekAt:0 if missing (fallback)"
CTFIFOBuffer>>peekHead
    ^ (self respondsTo: #peekAt:) ifTrue: [ self peekAt: 0 ] ifFalse: [ (self size > 0) ifTrue: [ self pop; self push: nil. ^ nil ] ifFalse: [ nil ] ].
