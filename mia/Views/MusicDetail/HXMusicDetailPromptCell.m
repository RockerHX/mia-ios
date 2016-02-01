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

#pragma mark - Load Methods
- (void)awakeFromNib {
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    [_infectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infectViewTaped)]];
}

#pragma mark - Event Response
- (IBAction)infectButtonPressed {
    
}

- (IBAction)infectViewTaped {
    
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    _locationLabel.text = item.sAddress;
    _commentCountLabel.text = @(item.cComm).stringValue;
}

@end
