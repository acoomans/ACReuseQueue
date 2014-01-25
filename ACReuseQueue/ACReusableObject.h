//
//  ACReusableObject.h
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>


/** The ACReusableObject protocol describes the methods and properties to be implemented for an object to be reused by a ACReuseQueue.
 * 
 * A reusable object must have a reuse identifier to be reused.
 */

@protocol ACReusableObject <NSObject>
@optional

/** Initializes and returns an object with a reuse identifier.
 * @param identifier A string used to identify the object if it is to be reused. Pass nil if the object is not to be reused.
 */
- (instancetype)initWithReuseIdentifier:(NSString*)identifier;

/** A string used to identify an object that is reusable.
 * @discussion The reuse identifier is associated with an object with the intent to reuse it (for performance reasons). It can be assigned to the object in initWithReuseIdentifier:, if the method is implemented, or with the accessor. A reusable object is usually not supposed to change its identifier once one has been set. A ACReuseQueue object maintains a queue (or list) of the currently reusable objects, each with its own reuse identifier, and makes them available in the dequeueReusableObjectWithIdentifier: method.
 */
@property (nonatomic, copy) NSString *reuseIdentifier;

/** Prepares a reusable object for reuse by a ACReuseQueue.
 * @discussion If an object is reusable -- that is, it has a reuse identifier -- this method is invoked just before the object is returned from the ACReuseQueue method dequeueReusableObjectWithIdentifier:. For performance reasons, you should only reset attributes of the object that needs to be. If the object does not have an associated reuse identifier, this method is not called. If you override this method, you must be sure to invoke the superclass implementation.
 */
- (void)prepareForReuse;

@end
