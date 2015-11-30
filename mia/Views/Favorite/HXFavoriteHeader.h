//
//  HXFavoriteHeader.h
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXFavoriteHeaderAction) {
    HXFavoriteHeaderActionPlay,
    HXFavoriteHeaderActionPause,
    HXFavoriteHeaderActionEdit
};

@class HXFavoriteHeader;

@protocol HXFavoriteHeaderDelegate <NSObject>

@required
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action;

@end

IB_DESIGNABLE

@interface HXFavoriteHeader : UIView

@property (weak, nonatomic) IBOutlet       id  <HXFavoriteHeaderDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (IBAction)playButtonPressed;
- (IBAction)editButtonPressed;

@end
