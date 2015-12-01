//
//  UIViewController+HXClass.m
//
//  Created by ShiCang on 15/10/18.
//  Copyright © 2015年 Andy Shaw. All rights reserved.
//

#import "UIViewController+HXClass.h"

@implementation UIViewController (HXClass)

@dynamic navigationControllerIdentifier;
@dynamic storyBoardName;

#pragma  mark - Class Methods
+ (UINavigationController *)navigationControllerInstance {
    UIViewController *viewController = [self new];
    return [HXStoryBoardManager navigaitonControllerWithIdentifier:viewController.navigationControllerIdentifier storyBoardName:viewController.storyBoardName];
}

+ (instancetype)instance {
    UIViewController *viewController = [self new];
    return [HXStoryBoardManager viewControllerWithClass:[self class] storyBoardName:viewController.storyBoardName];
}


@end
