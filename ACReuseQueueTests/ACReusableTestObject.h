//
//  ACReusableTestObject.h
//  ACReuseQueue
//
//  Created by Arnaud Coomans on 22/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACReusableObject.h"

@interface ACReusableTestObject : NSObject <ACReusableObject>
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic,copy) void(^prepareForReuseBlock)();
@end
