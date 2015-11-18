//
//  HXMusicDetailTopBar.h
//  mia
//
//  Created by miaios on 15/11/18.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXXibView.h"

@class ShareItem;

typedef NS_ENUM(NSUInteger, HXMusicDetailTopBarAction) {
    HXMusicDetailTopBarActionProfile,
    HXMusicDetailTopBarActionShare
};

@protocol HXMusicDetailTopBarDelegate <NSObject>

@required
- (void)topBarButtonPressed:(HXMusicDetailTopBarAction)action;

@end

@interface HXMusicDetailTopBar : HXXibView

@property (nonatomic, weak, nullable) IBOutlet       id  <HXMusicDetailTopBarDelegate>delegate;
@property (nonatomic, weak, nullable) IBOutlet  UILabel *songNameLabel;
@property (nonatomic, weak, nullable) IBOutlet  UILabel *singerNameLabel;

- (IBAction)backButtonPressed;

- (void)updateMusicInfoWithItem:(nullable ShareItem *)item;

@end
