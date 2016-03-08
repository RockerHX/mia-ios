//
//  HXProfileShareCell.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareItem.h"

typedef NS_ENUM(NSUInteger, HXProfileShareCellAction) {
    HXProfileShareCellActionPlay,
    HXProfileShareCellActionFavorite,
};

@class HXProfileShareCell;

@protocol HXProfileShareCellDelegate <NSObject>

@optional
- (void)shareCell:(HXProfileShareCell *)cell takeAction:(HXProfileShareCellAction)action;

@end

@interface HXProfileShareCell : UITableViewCell

@property (weak, nonatomic) IBOutlet         id  <HXProfileShareCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet     UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet     UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet     UILabel *songLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet    UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet     UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *dateLabel;

@property (nonatomic, assign) BOOL favorite;

- (IBAction)playButtonPressed;
- (IBAction)favoriteButtonPressed;

- (void)displayWithItem:(ShareItem *)item;

@end
