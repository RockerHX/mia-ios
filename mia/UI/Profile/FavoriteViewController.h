//
//  FavoriteViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoriteModel;

@protocol FavoriteViewControllerDelegate

- (FavoriteModel *)favoriteViewControllerModel;
- (NSArray *)favoriteViewControllerGetFavoriteList;
- (int)favoriteViewControllerSelectAll:(BOOL)selected;
- (int)favoriteViewControllerSelectedCount;
- (BOOL)favoriteViewControllerDeleteMusics;
- (void)favoriteViewControllerPlayMusic:(NSInteger)row;
- (void)favoriteViewControllerPauseMusic;
@end


@interface FavoriteViewController : UIViewController

@property (weak, nonatomic)id<FavoriteViewControllerDelegate> favoriteViewControllerDelegate;
@property (strong, nonatomic) UICollectionView *favoriteCollectionView;
@property (assign, nonatomic) BOOL isPlaying;

- (id)initWitBackground:(UIImage *)backgroundImage;
- (void)setBackground:(UIImage *)backgroundImage;
- (void)endRequestFavoriteList:(BOOL)success;

@end

