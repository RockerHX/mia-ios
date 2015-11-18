//
//  HXMusicDetailInfectCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXInfectUserView;
@class TTTAttributedLabel;
@class HXMusicDetailViewModel;
@class HXMusicDetailInfectCell;

@protocol HXMusicDetailInfectCellDelegate <NSObject>

@optional
- (void)cellUserWouldLikeShowInfectList:(nullable HXMusicDetailInfectCell *)cell;

@end

@interface HXMusicDetailInfectCell : UITableViewCell

@property (nonatomic, weak, nullable) IBOutlet                 id  <HXMusicDetailInfectCellDelegate>delegate;

@property (nonatomic, weak, nullable) IBOutlet   HXInfectUserView *infectUserView;
@property (nonatomic, weak, nullable) IBOutlet TTTAttributedLabel *infectPromptLabel;

- (void)displayWithViewModel:(nullable HXMusicDetailViewModel *)viewModel;

@end
