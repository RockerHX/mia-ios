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
    [_infectInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infectViewTaped)]];
    [_favoriteInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoriteViewTaped)]];
}

#pragma mark - Event Response
- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(promptCell:takeAction:)]) {
        [_delegate promptCell:self takeAction:HXMusicDetailPromptCellActionFavorite];
    }
}

- (void)infectViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(promptCell:takeAction:)]) {
        [_delegate promptCell:self takeAction:HXMusicDetailPromptCellActionShowInfecter];
    }
}

- (void)favoriteViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(promptCell:takeAction:)]) {
        [_delegate promptCell:self takeAction:HXMusicDetailPromptCellActionShowFavorite];
    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    _dateLabel.text = item.formatTime;
    _seeCountLabel.text = @(item.cView).stringValue;
    _locationLabel.text = item.sAddress;
    _infectionCountLabel.text = @(item.infectTotal).stringValue;
    _favoriteCountLabel.text = @(item.starCnt).stringValue;
    _commentCountLabel.text = @(item.cComm).stringValue;
    
    _infectView.infected = viewModel.playItem.isInfected;
    _infectView.infecters = viewModel.playItem.infectUsers;
    _infectView.promptLabel.hidden = YES;
    
    [self updateFavoriteState:item.favorite];
}

#pragma mark - Private Methods
- (void)updateFavoriteState:(BOOL)favorite {
    [_favoriteButton setImage:[UIImage imageNamed:(favorite ? @"D-FavoritedIcon" : @"D-FavoriteIcon")] forState:UIControlStateNormal];
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
