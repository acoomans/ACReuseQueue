//
//  ACTableViewController.m
//  ACReuseQueue
//
//  Created by Arnaud Coomans on 24/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "ACTableViewController.h"
#import "ACPageViewController.h"

@implementation ACTableViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    switch (indexPath.row) {
        case 0:
            ((ACPageViewController*)segue.destinationViewController).useReuseQueue = NO;
            break;

        case 1:
            ((ACPageViewController*)segue.destinationViewController).useReuseQueue = YES;
            break;
            
        default:
            break;
    }
}

@end
