//
//  HXPlayViewController.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayViewController.h"
#import "HXPlayTopBar.h"
#import "HXPlayMusicSummaryView.h"
#import "HXPlayBottomBar.h"
#import "MusicMgr.h"
#import "UIImageView+WebCache.h"
#import "HXPlayListViewController.h"

@interface HXPlayViewController () <
HXPlayTopBarDelegate,
HXPlayMusicSummaryViewDelegate,
HXPlayBottomBarDelegate,
HXPlayListViewControllerDelegate
>
@end

@implementation HXPlayViewController {
    BOOL _willDismiss;
}

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXPlayNavigationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlay;
}

#pragma mark - View Controller Lift Cycle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_willDismiss animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self displayPlayView];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (void)displayPlayView {
    [_coverBG sd_setImageWithURL:[NSURL URLWithString:[MusicMgr standard].currentItem.music.purl] placeholderImage:nil];
    
    [self updateTopBar];
    [self updateSummaryView];
    [self updateBottomBar];
}

- (void)updateTopBar {
    ShareItem *item = [MusicMgr standard].currentItem;
    _topBar.sharerNameLabel.text = item.shareUser.nick;
}

- (void)updateSummaryView {
    [_summaryView displayWithMusic:[MusicMgr standard].currentItem.music];
}

- (void)updateBottomBar {
    [self startMusicTimeRead];
    
    MusicMgr *musicMgr = [MusicMgr standard];
    NSInteger playIndex = musicMgr.currentIndex;
    BOOL isFirst = (playIndex == 0);
    BOOL isLast = (playIndex == musicMgr.musicCount);
    _bottomBar.enablePrevious = !isFirst;
    _bottomBar.enableNext = !isLast;
//    _bottomBar.musicTime = musicMgr
}

- (void)startMusicTimeRead {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        _bottomBar.slider.value = [MusicMgr standard].currentPlayedPostion;
        [self updatePlayTime];
    });
    dispatch_resume(timer);
}

- (void)updatePlayTime {
    _bottomBar.playTime = [MusicMgr standard].currentPlayedPostion;
}

- (NSArray *)musicList {
    NSMutableArray *musicList = @[].mutableCopy;
    NSArray *playList = [MusicMgr standard].playList;
    for (ShareItem *item in playList) {
        MusicItem *music = item.music;
        if (music && [music isKindOfClass:[MusicItem class]]) {
            [musicList addObject:music];
        }
    }
    return [musicList copy];
}

- (void)play {
//    [[MusicMgr standard] play];
}

- (void)pause {
    [[MusicMgr standard] pause];
}

- (void)previous {
    [[MusicMgr standard] playPrevios];
}

- (void)next {
    [[MusicMgr standard] playNext];
}

#pragma mark - HXPlayTopBarDelegate Methods
- (void)topBar:(HXPlayTopBar *)bar takeAction:(HXPlayTopBarAction)action {
    switch (action) {
        case HXPlayTopBarActionBack: {
            _willDismiss = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case HXPlayTopBarActionShowList: {
            HXPlayListViewController *playListViewController = [HXPlayListViewController instance];
            playListViewController.delegate = self;
            playListViewController.musicList = [self musicList];
            playListViewController.playIndex = [MusicMgr standard].currentIndex;
            [self.navigationController pushViewController:playListViewController animated:YES];
            break;
        }
    }
}

#pragma mark - HXPlayMusicSummaryViewDelegate Methods
- (void)summaryViewTaped:(HXPlayMusicSummaryView *)summaryView {
    ;
}

#pragma mark - HXPlayBottomBarDelegate Methods
- (void)bottomBar:(HXPlayBottomBar *)bar takeAction:(HXPlayBottomBarAction)action {
    switch (action) {
        case HXPlayBottomBarActionFavorite: {
            ;
            break;
        }
        case HXPlayBottomBarActionPrevious: {
            [self previous];
            break;
        }
        case HXPlayBottomBarActionPause: {
            [self pause];
            break;
        }
        case HXPlayBottomBarActionNext: {
            [self next];
            break;
        }
        case HXPlayBottomBarActionInfect: {
            ;
            break;
        }
    }
}

#pragma mark - HXPlayListViewControllerDelegate Methods
- (void)playListViewController:(HXPlayListViewController *)viewController playIndex:(NSInteger)index {
    [[MusicMgr standard] playWithIndex:index];
    [self displayPlayView];
}

@end
