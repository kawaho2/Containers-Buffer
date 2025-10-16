"CTBuffer - overwrite stats (droppedCount)
File: CTBuffer-Stats.st

Adds a droppedCount ivar to buffers and increments when push overwrites oldest item.
If CTBuffer already has similar telemetry, adapt accordingly.
"

"Assuming CTBuffer classes can accept extra ivar 'droppedCount' - add it via class browser if missing."

CTFIFOBuffer>>droppedCount
    (self respondsTo: #droppedCountVar) ifTrue: [ ^ droppedCountVar ].
    ^ 0.

CTFIFOBuffer>>droppedCount: anInteger
    droppedCountVar := anInteger.

"Wrap push: to increment counter when buffer is full"
CTFIFOBuffer>>pushWithStats: anObject
    "Push but increment droppedCount if this push overwrites an existing oldest element."
    (self size = self capacity) ifTrue: [
        self droppedCount: (self droppedCount + 1).
        "the underlying implementation likely overwrites the head element - call existing push which does overwrite"
    ].
    "Call existing push: implementation - if push: is final name leave it, else change"
    self push: anObject.

"Convenience"
CTFIFOBuffer>>resetStats
    self droppedCount: 0.
    ^ self.
