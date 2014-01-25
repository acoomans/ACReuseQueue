//
//  ACReusableTestObject.m
//  ACReuseQueue
//
//  Created by Arnaud Coomans on 22/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "ACReusableTestObject.h"

@implementation ACReusableTestObject

- (instancetype)initWithReuseIdentifier:(NSString*)identifier {
    self = [super init];
    if (self) {
        _reuseIdentifier = identifier;
    }
    return self;
}

- (void)prepareForReuse {
    if (self.prepareForReuseBlock) {
        self.prepareForReuseBlock();
    }
}

@end
