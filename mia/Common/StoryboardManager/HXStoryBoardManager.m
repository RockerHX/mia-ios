//
//  HXStoryBoardManager.m
//
//  Created by ShiCang on 15/7/13.
//  Copyright (c) 2015年 Andy Shaw. All rights reserved.
//

#import "HXStoryBoardManager.h"

@implementation HXStoryBoardManager

+ (UINavigationController *)navigaitonControllerWithIdentifier:(NSString *)identifier storyBoardName:(HXStoryBoardName)name {
    UINavigationController *controller = (UINavigationController *)[self viewControllerWithIdentifier:identifier storyBoardName:name];
    return [controller isKindOfClass:[UINavigationController class]] ? controller : nil;
}

+ (UIViewController *)viewControllerWithClass:(Class)class storyBoardName:(HXStoryBoardName)name {
    NSString *identifier = NSStringFromClass([class class]);
    UIViewController *controller = [self viewControllerWithIdentifier:identifier storyBoardName:name];
    return [controller isKindOfClass:[UIViewController class]] ? controller : nil;
}

#pragma mark - Private Methods
+ (NSString *)storyBoardName:(HXStoryBoardName)name {
    NSString *storyBoardName = nil;
    switch (name) {
        case HXStoryBoardNameLogin: {
            storyBoardName = @"Login";
            break;
        }
        case HXStoryBoardNameHome: {
            storyBoardName = @"Home";
            break;
        }
        case HXStoryBoardNamePlayer: {
            storyBoardName = @"Player";
            break;
        }
    }
    return storyBoardName;
}

+ (UIViewController *)viewControllerWithIdentifier:(NSString *)identifier storyBoardName:(HXStoryBoardName)name {
    UIViewController *viewController = nil;
    @try {
        NSString *storyBoardName = [self storyBoardName:name];
        viewController = [[UIStoryboard storyboardWithName:storyBoardName bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
        NSLog(@"Load View Controller From StoryBoard Error:%@", exception.reason);
    }
    @finally {
        return viewController;
    }
}

@end
