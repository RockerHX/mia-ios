//
//  HXPlayerViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerViewController.h"
#import "HXPlayerInfoView.h"
#import "HXPlayerProgressView.h"
#import "HXPlayerActionBar.h"
#import "MusicMgr.h"
#import "SongListPlayer.h"
#import "UIImageView+WebCache.h"

@interface HXPlayerViewController () <HXPlayerInfoViewDelegate, HXPlayerActionBarDelegate>
@end

@implementation HXPlayerViewController {
    SongListPlayer *_soglistPlayer;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _soglistPlayer = [MusicMgr standard].currentPlayer;
}

- (void)viewConfig {
    [self updateUI];
}

#pragma mark - Setter And Getter Methods
- (NSString *)navigationControllerIdentifier {
    return @"HXPlayerNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlayer;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)updateUI {
    MusicItem *item = [_soglistPlayer currentItem];
    [_frontCover sd_setImageWithURL:[NSURL URLWithString:item.albumURL] placeholderImage:[UIImage imageNamed:@"C-DefaultCoverBG"]];
    
    _infoView.songNameLabel.text = item.name;
    _infoView.singerLabel.text = item.singerName;
}

#pragma mark - HXPlayerInfoViewDelegate Methods
- (void)playerInfoViewShouldShare:(HXPlayerInfoView *)infoView {
    
}

#pragma mark - HXPlayerActionBarDelegate Methods
- (void)actionBar:(HXPlayerActionBar *)bar action:(HXPlayerActionBarAction)action {
    switch (action) {
        case HXPlayerActionBarActionPrevious: {
            ;
            break;
        }
        case HXPlayerActionBarActionPlay: {
            ;
            break;
        }
        case HXPlayerActionBarActionPause: {
            ;
            break;
        }
        case HXPlayerActionBarActionNext: {
            ;
            break;
        }
    }
}

@end
