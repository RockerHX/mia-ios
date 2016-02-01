//
//  HXMusicDetailPromptCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailPromptCell.h"
#import "HXMusicDetailViewModel.h"
#import "HXInfectUserView.h"
#import "InfectUserItem.h"

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
    _dateLabel.text = item.formatTime;
    _locationLabel.text = item.sAddress;
    _infectionCountLabel.text = @(item.infectTotal).stringValue;
    _commentCountLabel.text = @(item.cComm).stringValue;
    
    [self showInfectUsers:viewModel.playItem.infectUsers];
}

#pragma mark - Private Methods
- (void)showInfectUsers:(NSArray *)infectUsers {
    [_infectUserView removeAllItem];
    if (infectUsers) {
        NSMutableArray *itmes = [NSMutableArray arrayWithCapacity:infectUsers.count];
        if (itmes.count > 5) {
            for (NSInteger index = 0; index < 5; index ++) {
                InfectUserItem *item = infectUsers[index];
                [itmes addObject:[NSURL URLWithString:item.avatar]];
            }
        } else {
            for (InfectUserItem *item in infectUsers) {
                [itmes addObject:[NSURL URLWithString:item.avatar]];
            }
        }
        [_infectUserView showWithItems:itmes];
        __weak __typeof__(self)weakSelf = self;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf.infectUserView refresh];
        } completion:^(BOOL finished) {
            __strong __typeof__(self)strongSelf = weakSelf;
            // 妙推用户头像跳动动画
            [strongSelf.infectUserView refreshItemWithAnimation];
        }];
    }
}

@end
