//
//  UIViewController+HXClass.h
//
//  Created by ShiCang on 15/10/18.
//  Copyright © 2015年 Andy Shaw. All rights reserved.
//

#import "HXStoryBoardManager.h"

@interface UIViewController (HXClass)

@property (nonatomic, copy, readonly)           NSString *navigationControllerIdentifier;
@property (nonatomic, assign, readonly) HXStoryBoardName  storyBoardName;

+ (UINavigationController *)navigationControllerInstance;
+ (instancetype)instance;

@end
