" Run creating graph with 'signal' method of SysGVTree "
createGraphWith: signal
	| symbol |
	
	(symbol := self stsPossibleSelectorIn: self targetTextWidget) isNil
	ifTrue: [^nil]
	ifFalse: [
		symbol first isUppercase
			ifTrue: [
				| object |
				object := self owningImage globalNamespace at: symbol ifAbsent: [nil].
				object isNil
				ifFalse: [
					object isClass
					ifTrue: [ | tree coll |
						coll := OrderedCollection new.
						coll add: object.
						tree := OvtSvrGVTree new.
						tree dotFileName: 'tmp_f.gv'.
						tree outFileName: 'tmp_f.png'.
						tree perform: signal with: coll.
						tree openGVTree.
					].
				].
			].
		].

" Make tree with all subclasses and superclasses of classes from input collection. "
stsGraphFull
	self createGraphWith: #makeTreeComplete:

" Make tree with chain of superclasses of classes from input collection. "
stsGraph
	self createGraphWith: #makeTree:

