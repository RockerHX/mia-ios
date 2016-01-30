//
//  HXProfileSongActionCell.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXProfileSongAction) {
    HXProfileSongActionPlay,
    HXProfileSongActionPause,
    HXProfileSongActionEdit
};

@class HXProfileSongActionCell;

@protocol HXProfileSongActionCellDelegate <NSObject>

@optional
- (void)songActionCell:(HXProfileSongActionCell *)cell takeAction:(HXProfileSongAction)action;

@end

@interface HXProfileSongActionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet id  <HXProfileSongActionCellDelegate>delegate;

- (IBAction)playButtonPressed:(UIButton *)button;
- (IBAction)editButtonPressed;

@end
