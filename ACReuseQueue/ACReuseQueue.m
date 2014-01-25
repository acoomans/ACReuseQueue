//
//  ACReuseQueue.m
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "ACReuseQueue.h"

NSString * const ACReuseQueueEmptyException = @"ACReuseQueueEmptyException";


@interface ACReuseQueue ()
@property (nonatomic, strong) NSMutableDictionary *dictionaryOfSetsOfUnusedObjects;
@property (nonatomic, strong) NSMutableDictionary *dictionaryOfSetsOfUsedObjects;
@property (nonatomic, strong) NSMutableDictionary *dictionaryOfRegisteredClassesOrNibs;
- (id<ACReusableObject>)newReuseObjectWithIdentifier:(NSString *)identifier;
@end

@implementation ACReuseQueue

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllUnusedObjects)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)defaultQueue {
    static ACReuseQueue *_reuseQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reuseQueue = [[ACReuseQueue alloc] init];
    });
    return _reuseQueue;
}


#pragma mark - private accessors

- (NSMutableDictionary *)dictionaryOfSetsOfUnusedObjects {
    if (!_dictionaryOfSetsOfUnusedObjects) {
        _dictionaryOfSetsOfUnusedObjects = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryOfSetsOfUnusedObjects;
}

- (NSMutableDictionary *)dictionaryOfSetsOfUsedObjects {
    if (!_dictionaryOfSetsOfUsedObjects) {
        _dictionaryOfSetsOfUsedObjects = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryOfSetsOfUsedObjects;
}

- (NSMutableSet*)setOfUnusedObjectsWithIdentifier:(NSString*)identifier {
    NSMutableSet *unusedSet = self.dictionaryOfSetsOfUnusedObjects[identifier];
    if (!unusedSet) {
        unusedSet = [[NSMutableSet alloc] init];
        self.dictionaryOfSetsOfUnusedObjects[identifier] = unusedSet;
    }
    return unusedSet;
}

- (NSMutableSet*)setOfUsedObjectsWithIdentifier:(NSString*)identifier {
    NSMutableSet *usedSet = self.dictionaryOfSetsOfUsedObjects[identifier];
    if (!usedSet) {
        usedSet = [[NSMutableSet alloc] init];
        self.dictionaryOfSetsOfUsedObjects[identifier] = usedSet;
    }
    return usedSet;
}

- (NSMutableDictionary *)dictionaryOfRegisteredClassesOrNibs {
    if (!_dictionaryOfRegisteredClassesOrNibs) {
        _dictionaryOfRegisteredClassesOrNibs = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryOfRegisteredClassesOrNibs;
}


#pragma mark - counts

- (NSUInteger)unusedCount {
    NSUInteger unusedCount = 0;
    for (NSSet *set in [self.dictionaryOfSetsOfUnusedObjects allValues]) {
        unusedCount += [set count];
    }
    return unusedCount;
}

- (NSUInteger)usedCount {
    NSUInteger usedCount = 0;
    for (NSSet *set in [self.dictionaryOfSetsOfUsedObjects allValues]) {
        usedCount += [set count];
    }
    return usedCount;
}

- (NSUInteger)count {
    return self.unusedCount + self.usedCount;
}


#pragma mark - Enqueueing and dequeuing objects

- (void)enqueueReusableObject:(id<ACReusableObject>)reusableObject {
    if (![reusableObject respondsToSelector:@selector(reuseIdentifier)] ||
        !reusableObject.reuseIdentifier) return;

    [[self setOfUsedObjectsWithIdentifier:reusableObject.reuseIdentifier] removeObject:reusableObject];
    [[self setOfUnusedObjectsWithIdentifier:reusableObject.reuseIdentifier] addObject:reusableObject];
}


- (id<ACReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier {

    id<ACReusableObject> reusableObject = [[self setOfUnusedObjectsWithIdentifier:identifier] anyObject];
    
    if (!reusableObject) {
        reusableObject = [self newReuseObjectWithIdentifier:identifier];
        
        if (reusableObject == nil) {
            [NSException raise:ACReuseQueueEmptyException format:@"No class or nib was registered with the ACReuseQueue for identifier %@", identifier];
        }
    }
    
    [[self setOfUsedObjectsWithIdentifier:identifier] addObject:reusableObject];
    [[self setOfUnusedObjectsWithIdentifier:identifier] removeObject:reusableObject];
    
    if ([reusableObject respondsToSelector:@selector(prepareForReuse)]) {
        [reusableObject prepareForReuse];
    }
    
    return reusableObject;
}

#pragma mark - Registring classes or nibs

- (void)registerNib:(UINib *)nib forObjectReuseIdentifier:(NSString *)identifier {
    self.dictionaryOfRegisteredClassesOrNibs[identifier] = nib;
}

- (void)registerNibWithName:(NSString *)nibName bundle:(NSBundle *)nibBundle forObjectReuseIdentifier:(NSString *)identifier {
    [self registerNib:[UINib nibWithNibName:nibName bundle:nibBundle] forObjectReuseIdentifier:identifier];
}

- (void)registerClass:(Class)objectClass forObjectReuseIdentifier:(NSString *)identifier {
    if (objectClass) {
        self.dictionaryOfRegisteredClassesOrNibs[identifier] = NSStringFromClass(objectClass);
    } else {
        [self.dictionaryOfRegisteredClassesOrNibs removeObjectForKey:identifier];
    }
}

#pragma mark - creating objects

- (id<ACReusableObject>)newReuseObjectWithIdentifier:(NSString *)identifier {
    
    id object = nil;
    
    id classOrNib = self.dictionaryOfRegisteredClassesOrNibs[identifier];
    
    if ([classOrNib isKindOfClass:NSString.class]) {
        Class cls = NSClassFromString(classOrNib);
        object = [cls alloc];
        if ([object respondsToSelector:@selector(initWithReuseIdentifier:)]) {
            object = [object initWithReuseIdentifier:identifier];
        } else {
            object = [object init];
            if ([object respondsToSelector:@selector(setReuseIdentifier:)]) {
                [object setReuseIdentifier:identifier];
            }
        }
        
    } else if ([classOrNib isKindOfClass:UINib.class]) {
        UINib *nib = (UINib*)classOrNib;
        NSArray *objects = [nib instantiateWithOwner:nil options:nil];
        object = [objects lastObject];
        if ([object respondsToSelector:@selector(setReuseIdentifier:)]) {
            [object setReuseIdentifier:identifier];
        }
    }
    return object;
}

#pragma mark - remove objects 


- (void)removeAllUnusedObjects {
    [self.dictionaryOfSetsOfUnusedObjects removeAllObjects];
}

@end
