//
//  ACReuseQueue.h
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ACReusableObject.h"


extern NSString * const ACReuseQueueEmptyException;

/** An instance of ACReusableQueue is a means for keeping and reusing objects.
 *
 * A reuse queue object maintains a queue (or list) of the currently reusable objects, each with its own reuse identifier. It makes unused objects available in the dequeueReusableObjectWithIdentifier: method. If no object is available, and a class or a Nib has previously been registered with registerNib:forObjectReuseIdentifier: or registerClass:forObjectReuseIdentifier:, a new object will be created and returned instead. When an object is not used anymore, enqueueReusableObject: should be called to return the reusable object to the queue and mark it as unused.
 *
 * A reuse queue is a way to quickly reuse objects when object allocation and initialization is time-consuming. This reuse queue is inspired after UITableView's for reusing cells, headers and footers.
 *
 */


@interface ACReuseQueue : NSObject


/** @name Getting the default queue */

/** Return the default reuse queue
 * @discussion The current process’s default reuse queue.
 */
+ (instancetype)defaultQueue;


/** @name Properties */

/** Maximum number of unused object in the queue
 */
@property (nonatomic, assign) NSUInteger maxUnusedCount;


/** @name Enqueueing and dequeuing objects */

/** Returns a reusable object located by its identifier.
 * @param reusableObject A ACReusableObject not in use anymore and to be queued for further reuse.
 * @discussion For performance reasons, it may be necessary to reuse existing objects. Call this method to put a reusable object back in the queue for further reuse. Avoid manipulating the object after calling this method as it might be dequeued and reused somewhere else.
 */
- (void)enqueueReusableObject:(id<ACReusableObject>)reusableObject;

/** Returns a reusable object located by its identifier.
 * @param identifier A string identifying the object to be reused. This parameter must not be nil.
 * @return A reusable object with the associated identifier or nil if no such object exists in the ACReusableQueue.
 * @discussion For performance reasons, it may be necessary to reuse existing objects. A ACReuseQueue maintains a list of reusable objects marked for reuse. This method dequeues an existing object if one is available or creates a new one using the class or nib file you previously registered. If no object is available for reuse and you did not register a class or nib file, this method returns nil. If you registered a class for the specified identifier and a new object must be created, this method initializes the object by calling its initWithReuseIdentifier: method. For nib-based objects, this method loads the object from the provided nib file. If an existing object was available for reuse, this method calls the object's prepareForReuse method instead.
 */
- (id<ACReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier __attribute((nonnull(1)));

/** @name Registering classes or nibs */

/** Registers a nib object containing a reusable object with a specified identifier.
 * @param nib A nib object that specifies the nib file to use to create the object. This parameter cannot be nil.
 * @param identifier The reuse identifier for the object. This parameter must not be nil and must not be an empty string.
 * @discussion Prior to dequeueing any object, call this method or the registerClass:forObjectReuseIdentifier: method to tell the queue how to create new objects. If an object of the specified type is not currently in a reuse queue, it uses the provided information to create a new object automatically. If you previously registered a class or nib file with the same reuse identifier, the nib you specify in the nib parameter replaces the old entry. You may specify nil for nib if you want to unregister the nib from the specified reuse identifier.
 */
- (void)registerNib:(UINib *)nib forObjectReuseIdentifier:(NSString *)identifier __attribute((nonnull(1,2)));

/** Registers by its name a nib object containing a reusable object with a specified identifier.
 * @param nibName The name of the nib file to use to create the object. The nib file name should not contain any leading path information. This parameter cannot be nil.
 * @param nibBundle The bundle in which to search for the nib file.
 * @param identifier The reuse identifier for the object. This parameter must not be nil and must not be an empty string.
 * @discussion This method is a convenience method. See registerNib:forObjectReuseIdentifier: for details.
 */
- (void)registerNibWithName:(NSString *)nibName bundle:(NSBundle *)nibBundle forObjectReuseIdentifier:(NSString *)identifier __attribute((nonnull(1,3)));

/** Registers a class for use in creating new objects.
 * @param objectClass The class of an object that you want to use.
 * @param identifier The reuse identifier for the object. This parameter must not be nil and must not be an empty string.
 * @discussion Prior to dequeueing any object, call this method or the registerNib:forObjectReuseIdentifier: method to tell the queue how to create new objects. If an object of the specified type is not currently in a reuse queue, it uses the provided information to create a new object automatically. If you previously registered a class or nib file with the same reuse identifier, the class you specify in the objectClass parameter replaces the old entry. You may specify nil for objectClass if you want to unregister the class from the specified reuse identifier.
 */
- (void)registerClass:(Class)objectClass forObjectReuseIdentifier:(NSString *)identifier __attribute((nonnull(2)));


@property (nonatomic, assign, readonly) NSUInteger unusedCount;
@property (nonatomic, assign, readonly) NSUInteger usedCount;
@property (nonatomic, assign, readonly) NSUInteger count;

- (void)removeAllUnusedObjects;

@end
