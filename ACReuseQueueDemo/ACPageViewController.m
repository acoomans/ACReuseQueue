//
//  ACPageViewController.m
//  ACReuseQueue
//
//  Created by Arnaud Coomans on 24/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "ACPageViewController.h"
#import "ACDataViewController.h"


@implementation ACPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    ACDataViewController *startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (ACDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    ACDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(ACDataViewController.class)];
    dataViewController.number = index;
    dataViewController.useReuseQueue = self.useReuseQueue;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(ACDataViewController *)viewController {
    return ((ACDataViewController*)viewController).number;
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(ACDataViewController *)viewController] - 1;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(ACDataViewController *)viewController] + 1;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}


@end
