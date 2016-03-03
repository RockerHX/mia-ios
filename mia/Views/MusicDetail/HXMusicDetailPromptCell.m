//
//  HXMusicDetailPromptCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailPromptCell.h"
#import "HXMusicDetailViewModel.h"
#import "HXInfectView.h"

@interface HXMusicDetailPromptCell () <
HXInfectViewDelegate
>
@end

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
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infectViewTaped)]];
}

#pragma mark - Event Response
- (void)infectViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(promptCell:takeAction:)]) {
        [_delegate promptCell:self takeAction:HXMusicDetailPromptCellActionShowInfecter];
    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    _dateLabel.text = item.formatTime;
    _locationLabel.text = item.sAddress;
    _infectionCountLabel.text = @(item.infectTotal).stringValue;
    _commentCountLabel.text = @(item.cComm).stringValue;
    
    _infectView.infected = viewModel.playItem.isInfected;
    _infectView.infecters = viewModel.playItem.infectUsers;
}

#pragma mark - HXInfectViewDelegate Methods
- (void)infectView:(HXInfectView *)infectView takeAction:(HXInfectViewAction)action {
    switch (action) {
        case HXInfectViewActionInfect: {
            if (_delegate && [_delegate respondsToSelector:@selector(promptCell:takeAction:)]) {
                [_delegate promptCell:self takeAction:HXMusicDetailPromptCellActionInfect];
            }
            break;
        }
        case HXInfectViewActionLayout: {
            _spaceConstraint.constant = infectView.controlToSpace;
            break;
        }
    }
}

- (void)infectViewInfecterTaped:(HXInfectView *)infectView atIndex:(NSInteger)index {
    [self infectViewTaped];
}

@end
