//
//  HXStoryBoardManager.h
//
//  Created by ShiCang on 15/7/13.
//  Copyright (c) 2015年 Andy Shaw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXStoryBoardName) {
    HXStoryBoardNameLogin,
    HXStoryBoardNameHome,
    HXStoryBoardNamePlayer
};

@interface HXStoryBoardManager : NSObject

+ (id)navigaitonControllerWithIdentifier:(NSString *)identifier storyBoardName:(HXStoryBoardName)name;
+ (id)viewControllerWithClass:(Class)class storyBoardName:(HXStoryBoardName)name;

@end
