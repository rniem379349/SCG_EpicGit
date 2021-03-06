"
!Epic

An epic is a feature or overarching objective. This is a fairly generalized feature within a system that meets user requirements to achieve business as usual. The epic will have a collection of ${class:name=EUseCase}$ that will help define behavior that needs to be available for users.


The ${example:GtDocumentExamples>>#exampleComUrl|label=#host|expanded=false}$  website is accessed ${example:GtDocumentExamples>>#exampleComAccessPerHour|label=#size|expanded=false}$ times every hour by ${example:GtDocumentExamples>>#exampleComUniqueAccessPerHour|label=#size|expanded=false}$ unique users.
"
Class {
	#name : #EEpic,
	#superclass : #Object,
	#instVars : [
		'title',
		'use_cases',
		'references',
		'announcer'
	],
	#category : #'Epic-Model'
}

{ #category : #adding }
EEpic >> addUseCase: aUseCase [
	self use_cases add: aUseCase
]

{ #category : #accessing }
EEpic >> announcer [ 
	^announcer
]

{ #category : #accessing }
EEpic >> announcer: anAnnouncer [
	announcer := anAnnouncer 
]

{ #category : #accessing }
EEpic >> children [
	^ self use_cases 
]

{ #category : #ui }
EEpic >> customEntityElementFor: aReference [
	"generate a UI element for a missing reference, used in the Referenced Entities view"
	| container label button separator referencedEntity |
	
	referencedEntity :=  aReference copyReplaceAll: ' - missing' with: ''.
	
	container := BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical exact: 30.
			 ].
	
	separator := BlElement new
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent.
			 ].
	
	label := BrLabel new
		look: BrGlamorousListLabelLook;
		text: aReference asRopedText.
	
	button := RequirementClassAdditionInterface new initializeWithFutureClassName: referencedEntity andElement: self.
	
	container addChild: label.
	container addChild: separator.
	container addChild: button.
	^container
]

{ #category : #'entity references' }
EEpic >> getReferencesFrom: aCollectionOfUseCases [
	| useCaseReferences uniqueReferences |
	uniqueReferences := Set new.
	aCollectionOfUseCases do: [ :aUseCase | 
		useCaseReferences := aUseCase getReferencesFrom: aUseCase children.
		uniqueReferences addAll: useCaseReferences.
		 ].
	references := uniqueReferences asOrderedCollection.
	^references
]

{ #category : #ui }
EEpic >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
		text:
			'An ${class:name=Epic}$ is a feature or overarching objective. This is a fairly generalized feature within a system that meets user requirements to achieve business as usual. The epic will have a collection of ${class:name=EUseCase}$ that will help define behavior that needs to be available for users.

Under Use Cases you can see a list of all ${class:name=EUseCase}$.
			
In progress report, you can see the progress of each ${class:name=EUseCase}$ that exists in this Epic.

Under Use Case Details, you will see all aspects of each of the ${class:name=EUseCase}$ in a detailed view, including the ${class:name=EActor}$. 

The ${example:GtDocumentExamples>>#exampleComUrl|label=#host|expanded=false}$  website is accessed ${example:GtDocumentExamples>>#exampleComAccessPerHour|label=#size|expanded=false}$ times every hour by ${example:GtDocumentExamples>>#exampleComUniqueAccessPerHour|label=#size|expanded=false}$ unique users.

'.
	^ (aDocument gtTextFor: aView)
		title: 'View Details';
		priority: 1
]

{ #category : #ui }
EEpic >> gtEpicInformationFor: aView [
	<gtView>
	^ aView textEditor
	title: 'Information';
	priority: 0;
	text: [ 'Epic: ', title ]
]

{ #category : #'entity references' }
EEpic >> gtReferencesFor: aView [
	<gtView>
	| listView |
   listView := aView list
		title: 'Referenced Entities';
		items: [ self getReferencesFrom: self children ].
	listView itemStencil: [ :x | 
			(x class = ByteString) 
			ifTrue: [ self customEntityElementFor: x ]
			ifFalse: [ listView buildTextElementFor: x ]
			 ].
	listView actionButtonIcon: BrGlamorousVectorIcons refresh 
			label: 'Refresh'
			action: [ self announcer announce: ERequirementStateChangedAnnouncement new ].
	listView updateWhen: ERequirementStateChangedAnnouncement in: [ self announcer ].
	^listView
]

{ #category : #ui }
EEpic >> gtTreeViewOn: aView [
	<gtView>
	(self use_cases isEmpty) ifTrue: [^ aView empty].
	^ aView columnedTree
		title: 'Tree' translated;
		items: [self children];
		children: [ :each | each children ];
		column: 'Type' format: [ :eachElement | eachElement treeViewShortString ].
]

{ #category : #ui }
EEpic >> gtUseCaseColumnsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Use Cases';
		priority: 2;
		items: [ self use_cases ];
		column: 'Index' item: [ :anElement :anIndex | anIndex ] width: 20;
		column: 'Name' item: [ :anElement | anElement title ]
]

{ #category : #ui }
EEpic >> gtUseCaseDetailedColumnsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Use Case Details';
		priority: 4;
		items: [ self use_cases ];
		column: 'Index' item: [ :anElement :anIndex | anIndex ] width: 50;
		column: 'Name' item: [ :anElement | anElement title ];
		column: 'Task' item: [ :anElement | anElement task ]
]

{ #category : #ui }
EEpic >> gtUseCaseProgressColumnsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Progress Report';
		priority: 3;
		items: [ self use_cases ];
		column: 'Index' item: [ :anElement :anIndex | anIndex ] width: 50;
		column: 'Name' item: [ :anElement | anElement title ];
		column: 'Status' item: [ :anElement | anElement state ]
]

{ #category : #initialization }
EEpic >> initialize [
	super initialize.
	announcer := Announcer new.
	title := 'Feature of this epic'.
	use_cases := OrderedCollection new.
	references := OrderedCollection new.
	
]

{ #category : #removing }
EEpic >> removeUseCase: aUseCase [
	self use_cases remove: aUseCase
]

{ #category : #accessing }
EEpic >> title [
	^ title
]

{ #category : #accessing }
EEpic >> title: aString [
	title := aString
]

{ #category : #helper }
EEpic >> treeViewShortString [
	^ 'Epic: ', self title 
]

{ #category : #accessing }
EEpic >> use_cases [
	^ use_cases
]

{ #category : #accessing }
EEpic >> use_cases: anObject [
	use_cases := anObject
]
