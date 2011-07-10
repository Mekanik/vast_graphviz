
Object subclass: #SysGVTree
    instanceVariableNames: 'relations definitions outFileName outStr dotFileName '
    classVariableNames: ''
    poolDictionaries: 'PlatformConstants PlatformFunctions '!

!SysGVTree class publicMethods !

new
	^super new initialize! !

!SysGVTree class privateMethods !

_PRAGMA_IS_

	"%%PRAGMA DECLARE
	(name: IS_SysGVTree isPool: true isConstant: false)
	(pool: IS_SysGVTree declarations: (
		(name: IS_dotFileName isConstant: false)
		(name: IS_makeTreeFull_ isConstant: false)
		(name: IS_outFileName isConstant: false)
		(name: IS_makeTree_ isConstant: false)
		(name: IS_instanceInterfaceSpec isConstant: false)
	))"! !

!SysGVTree publicMethods !

addToOut: str

	outStr isNil
	ifTrue: [
		outStr := String new.
	].

	outStr := outStr, str, '' crStr.
	!

deeper: class
	class isNil
	ifTrue: [ ^nil ].

	class subclasses do: [:e |
		definitions add: (e asString).
		relations add: (e asString), ' -> ', (class asString).
		self deeper: e.
	].		
!

dotFileName
	" Filename of graphviz source. "

	^dotFileName ifNil: [ dotFileName := 'out.gv' ]!

dotFileName: aString
	" Filename of graphviz source. "

	dotFileName := aString.
	self signalEvent: #dotFileName
		 with: aString.!

generateGVTreeText
	" Generate source in DOT language for graph. "
	| fsOut |
	self addToOut: 'digraph graphname {'.
	definitions do: [ :e |
		self addToOut: '	', e.
	].
	self addToOut: ''.
	relations do: [ :e |
		self addToOut: '	', e.
	].
	self addToOut: '}'.

	fsOut := CfsWriteFileStream openEmpty: (self dotFileName).
	fsOut nextPutAll: outStr.
	fsOut flush.
	fsOut close.
	fsOut := nil.
	
	self renderGVTree.
!

initialize
	outStr := String new.
	definitions := Set new.
	relations := Set new.
!

makeTree: col
" Make tree with chain of superclasses of classes from input collection. "
	col isEmpty
	ifTrue: [ ^nil ].

	col do: [ :class |
		self upper: class.
	].

	self generateGVTreeText.
!

makeTreeComplete: col
" Make tree with all subclasses and superclasses of classes from input collection. "
	col isEmpty
	ifTrue: [ ^nil ].

	col do: [ :class |
		self upper: class.
	].

	col do: [ :class |
		self deeper: class.
	].

	self generateGVTreeText!

makeTreeFull: col
" Make tree with all subclasses of classes from input collection. "

	col isEmpty
	ifTrue: [ ^nil ].

	col do: [ :class |
		self deeper: class.
	].

	self generateGVTreeText!

openGVTree
" Open diagram image in external image viewer. "
	OSHwnd new
		  shellExecute: nil
		  lpFile: (self outFileName)
		  lpParameters: nil
		  lpDirectory: nil
		  nShowCmd: SwNormal.
!

outFileName
	" Filename of diagram image. "

	^outFileName ifNil: [ dotFileName := 'out.png' ]!

outFileName: aString
	" Filename of diagram image. "

	outFileName := aString.
	self signalEvent: #outFileName
		 with: aString.!

renderGVTree
" Render source to diagram image with graphviz. "
	OSHwnd new
		  shellExecute: nil
		  lpFile: 'dot.exe'
		  lpParameters: ('-Tpng -Kdot  -o', (self outFileName), ' ',(self dotFileName))
		  lpDirectory: nil
		  nShowCmd: SwNormal.
	(Delay forSeconds: 1) wait.
!

upper: class
	class isNil
	ifTrue: [ ^nil ].

	definitions add: ('	', (class asString)).
	
	class superclass notNil
	ifTrue: [ | str |
		relations add: (class asString), ' -> ', (class superclass asString).
		self upper: (class superclass).
	].! !

SysGVTree initializeAfterLoad!