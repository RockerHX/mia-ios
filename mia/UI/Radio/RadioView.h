//
//  RadioView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol RadioViewDelegate
- (void)radioViewDidTouchBottom;
- (void)radioViewShouldLogin;
- (CLLocationCoordinate2D)radioViewCurrentCoordinate;

@end

@class ShareItem;

@interface RadioView : UIView

@property (strong, nonatomic, readonly) ShareItem *currentShareItem;
@property (weak, nonatomic)id<RadioViewDelegate> radioViewDelegate;
@property (assign, nonatomic) BOOL isLoading;

- (void)checkIsNeedToGetNewItems;
- (void)spreadFeed;
- (void)skipFeed;

@end
