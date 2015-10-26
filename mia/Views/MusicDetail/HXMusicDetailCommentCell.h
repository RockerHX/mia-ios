//
//  HXMusicDetailCommentCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;

@interface HXMusicDetailCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet     UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *contentLabel;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
