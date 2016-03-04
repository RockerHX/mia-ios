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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
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
