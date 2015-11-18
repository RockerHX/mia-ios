//
//  HXTopBar.h
//  mia
//
//  Created by miaios on 15/11/18.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXXibView.h"

typedef NS_ENUM(NSUInteger, HXTopBarAction) {
    HXTopBarActionProfile,
    HXTopBarActionShare
};

@protocol HXTopBarDelegate <NSObject>

@required
- (void)topBarButtonPressed:(HXTopBarAction)action;

@end

@interface HXTopBar : HXXibView

@property (nonatomic, weak, nullable) IBOutlet       id  <HXTopBarDelegate>delegate;
@property (nonatomic, weak, nullable) IBOutlet UIButton *profileButton;
@property (nonatomic, weak, nullable) IBOutlet UIButton *shareButton;
@property (nonatomic, weak, nullable) IBOutlet  UILabel *songNameLabel;
@property (nonatomic, weak, nullable) IBOutlet  UILabel *singerNameLabel;

- (IBAction)profileButtonPressed;
- (IBAction)shareButtonPressed;

- (void)updateProfileButtonImage:(nullable UIImage *)image;
- (void)updateProfileButtonWithUnreadCount:(NSInteger)unreadCommentCount;

@end
