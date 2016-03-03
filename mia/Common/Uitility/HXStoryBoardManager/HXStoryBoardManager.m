//
//  HXStoryBoardManager.m
//
//  Created by RockerHX
//  Copyright (c) Andy Shaw. All rights reserved.
//

#import "HXStoryBoardManager.h"

@implementation HXStoryBoardManager

+ (__kindof UIViewController *)navigaitonControllerWithIdentifier:(NSString *)identifier storyBoardName:(HXStoryBoardName)name {
    id controller = [self viewControllerWithIdentifier:identifier storyBoardName:name];
    return [controller isKindOfClass:[UINavigationController class]] ? controller : nil;
}

+ (__kindof UIViewController *)viewControllerWithClass:(Class)class storyBoardName:(HXStoryBoardName)name {
    NSString *identifier = NSStringFromClass([class class]);
    id controller = [self viewControllerWithIdentifier:identifier storyBoardName:name];
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
        case HXStoryBoardNameDiscovery: {
            storyBoardName = @"Discovery";
            break;
        }
        case HXStoryBoardNameFavorite: {
            storyBoardName = @"Favorite";
            break;
        }
        case HXStoryBoardNameMe: {
            storyBoardName = @"Me";
            break;
        }
        case HXStoryBoardNameSetting: {
            storyBoardName = @"Setting";
            break;
        }
        case HXStoryBoardNameProfile: {
            storyBoardName = @"Profile";
            break;
        }
        case HXStoryBoardNamePlay: {
            storyBoardName = @"Play";
            break;
        }
        case HXStoryBoardNameShare: {
            storyBoardName = @"Share";
            break;
        }
        case HXStoryBoardNameMessageCenter: {
            storyBoardName = @"MessageCenter";
            break;
        }
        case HXStoryBoardNameMusicDetail: {
            storyBoardName = @"MusicDetail";
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
