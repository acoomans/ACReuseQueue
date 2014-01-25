//
//  ACButton.h
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACReuseQueue.h"

@interface ACButton : UIButton <ACReusableObject>
@property (nonatomic, copy) NSString *reuseIdentifier;
@end
