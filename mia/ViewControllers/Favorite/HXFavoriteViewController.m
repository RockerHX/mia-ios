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

@interface HXFavoriteViewController () <
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

#pragma mark - HXFavoriteContainerViewControllerDelegate Methods
- (void)containerShouldShare:(HXFavoriteContainerViewController *)container item:(FavoriteItem *)item {
    HXShareViewController *shareViewController = [HXShareViewController instance];
    shareViewController.musicItem = item.music;
    [self.navigationController pushViewController:shareViewController animated:YES];
}

@end
