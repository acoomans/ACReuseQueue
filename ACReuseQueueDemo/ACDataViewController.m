//
//  ACDataViewController.m
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "ACDataViewController.h"

#import "ACReuseQueue.h"
#import "ACButton.h"


@implementation ACDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.useReuseQueue) {
        
        [[ACReuseQueue defaultQueue] registerClass:ACButton.class forObjectReuseIdentifier:@"button"];
        
        /*[[ACReuseQueue defaultQueue] registerNibWithName:NSStringFromClass(ACButton.class)
                                                  bundle:nil
                                forObjectReuseIdentifier:@"button"];
         */
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [NSString stringWithFormat:@"%i", self.number];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    for (NSUInteger r = 200 + arc4random_uniform(10); r > 0; r-- ) {
        
        UIButton *button = nil;
        
        if (self.useReuseQueue) {
            button = (UIButton*)[[ACReuseQueue defaultQueue] dequeueReusableObjectWithIdentifier:@"button"];
        } else {
            button = [UIButton buttonWithType:UIButtonTypeSystem];
        }
        
        [button setTitle:@"hello" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        button.frame = CGRectMake(50 + arc4random_uniform(self.view.bounds.size.width-140),
                                  50 + arc4random_uniform(self.view.bounds.size.height-144),
                                  40,
                                  44);
        [self.view addSubview:button];
    }
    
    CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - startTime;
    NSLog(@"Elapsed Time: %0.3f seconds", elapsed);
    
    
    NSLog(@"(viewWillAppear:) defaultQueue count %u", [[ACReuseQueue defaultQueue] count]);
}

- (void)viewDidDisappear:(BOOL)animated {
    
    if (self.useReuseQueue) {
        for (ACButton *button in self.view.subviews) {
            [button removeFromSuperview];
            [[ACReuseQueue defaultQueue] enqueueReusableObject:button];
        }
    }
    
    NSLog(@"(viewDidDisappear:) defaultQueue count %u", [[ACReuseQueue defaultQueue] count]);
    
    [super viewDidDisappear:animated];
}

@end
