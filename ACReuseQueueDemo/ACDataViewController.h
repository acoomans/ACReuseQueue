//
//  ACDataViewController.h
//  ACReuseQueueDemo
//
//  Created by Arnaud Coomans on 16/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACDataViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (assign, nonatomic) NSInteger number;
@property (assign, nonatomic) BOOL useReuseQueue;
@end
