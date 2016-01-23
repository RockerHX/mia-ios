//
//  UIViewController+HXClass.m
//
//  Created by RockerHX
//  Copyright (c) Andy Shaw. All rights reserved.
//

#import "UIViewController+HXClass.h"
#import "UIAlertView+BlocksKit.h"
#import "UIConstants.h"

@implementation UIViewController (HXClass)

@dynamic navigationControllerIdentifier;
@dynamic storyBoardName;
@dynamic canPan;

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

#pragma mark - Public Methods
- (void)showAlertWithMessage:(NSString *)message {
    [self showAlertWithMessage:message handler:nil];
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertView *, NSInteger))block {
    [self showAlertWithMessage:message otherTitle:nil handler:block];
}

- (void)showAlertWithMessage:(NSString *)message otherTitle:(NSString *)title handler:(void (^)(UIAlertView *, NSInteger))block {
    [UIAlertView bk_showAlertViewWithTitle:@"温馨提示"
                                   message:message
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:(title ? @[title] : nil)
                                   handler:block];
}

- (void)showMessage:(NSString *)message {
    if (message.length) {
        [self showToastWithMessage:message];
    }
}

- (void)showToastWithMessage:(NSString *)message {
    [self showToastWithMessage:message completedHandler:nil];
}

- (void)showToastWithMessage:(NSString *)message completedHandler:(void (^)(void))block {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.0f;
    hud.yOffset = SCREEN_HEIGHT/3;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0f];
}

- (void)showHUD {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
}

- (void)hiddenHUD {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

@end
