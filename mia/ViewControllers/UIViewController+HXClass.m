//
//  UIViewController+HXClass.m
//  TipTop-Adviser
//
//  Created by ShiCang on 15/10/18.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "UIViewController+HXClass.h"

@implementation UIViewController (HXClass)

@dynamic navigationControllerIdentifier;
@dynamic storyBoardName;

#pragma  mark - Class Methods
+ (UINavigationController *)navigationControllerInstance {
    @try {
        UIViewController *viewController = [self new];
        return [HXStoryBoardManager navigaitonControllerWithIdentifier:viewController.navigationControllerIdentifier storyBoardName:viewController.storyBoardName];
    }
    @catch (NSException *exception) {
        NSLog(@"Load View Controller Instance From Storybard Error:%@", exception.reason);
    }
    @finally {
    }
}

+ (instancetype)instance {
    @try {
        UIViewController *viewController = [self new];
        return [HXStoryBoardManager viewControllerWithClass:[self class] storyBoardName:viewController.storyBoardName];
    }
    @catch (NSException *exception) {
        NSLog(@"Load View Controller Instance From Storybard Error:%@", exception.reason);
    }
    @finally {
    }
}


@end
