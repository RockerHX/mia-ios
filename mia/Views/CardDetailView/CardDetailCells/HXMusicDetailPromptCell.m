//
//  HXMusicDetailPromptCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailPromptCell.h"
#import "HXMusicDetailViewModel.h"

@implementation HXMusicDetailPromptCell

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    _viewCountLabel.text = @(item.cView).stringValue;
    _locationLabel.text = item.sAddress;
    _commentCountLabel.text = @(item.cComm).stringValue;
}

@end
