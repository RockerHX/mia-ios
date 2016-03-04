//
//  HXFavoriteViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteViewController.h"
#import "HXFavoriteContainerViewController.h"
#import "HXShareViewController.h"
#import "HXPlayViewController.h"
#import "MusicMgr.h"
#import "HXMusicStateView.h"


@interface HXFavoriteViewController () <
HXMusicStateViewDelegate,
HXFavoriteContainerViewControllerDelegate
>
@end


@implementation HXFavoriteViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXFavoriteNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameFavorite;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HXFavoriteContainerViewController *containerViewController = segue.destinationViewController;
    containerViewController.delegate = self;
}

#pragma mark - View Controller Lift Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateMusicEntryState];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];
    
    switch (event) {
        case MiaPlayerEventDidPlay: {
            _stateView.state = HXMusicStatePlay;
            break;
        }
        case MiaPlayerEventDidPause:
        case MiaPlayerEventDidCompletion: {
            _stateView.state = HXMusicStateStop;
            break;
        }
    }
}

#pragma mark - Public Methods
- (void)updateMusicEntryState {
    _stateView.state = ([MusicMgr standard].isPlaying ? HXMusicStatePlay : HXMusicStateStop);
}

#pragma mark - HXMusicStateViewDelegate Methods
- (void)musicStateViewTaped:(HXMusicStateView *)stateView {
    if ([MusicMgr standard].currentItem) {
        UINavigationController *playNavigationController = [HXPlayViewController navigationControllerInstance];
        [self presentViewController:playNavigationController animated:YES completion:nil];
    }
}

#pragma mark - HXFavoriteContainerViewControllerDelegate Methods
- (void)containerShouldShare:(HXFavoriteContainerViewController *)container item:(FavoriteItem *)item {
    HXShareViewController *shareViewController = [HXShareViewController instance];
    shareViewController.musicItem = item.music;
    [self.navigationController pushViewController:shareViewController animated:YES];
}

@end
