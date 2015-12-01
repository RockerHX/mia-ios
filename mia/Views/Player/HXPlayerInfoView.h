//
//  HXPlayerInfoView.h
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXPlayerInfoView;

@protocol HXPlayerInfoViewDelegate <NSObject>

@optional
- (void)playerInfoViewShouldShare:(HXPlayerInfoView *)infoView;

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

IB_DESIGNABLE

#endif

@interface HXPlayerInfoView : UIView

@property (weak, nonatomic) IBOutlet      id  <HXPlayerInfoViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

- (IBAction)shareButtonPressed;

@end
