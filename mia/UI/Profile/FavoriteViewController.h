//
//  FavoriteViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteModel.h"

@protocol FavoriteViewControllerDelegate

- (FavoriteModel *)favoriteViewControllerModel;
- (void)favoriteViewControllerRequestFavoriteList;
- (void)favoriteViewControllerPlayMusic:(NSInteger)row;
- (void)favoriteViewControllerPauseMusic;
@end


@interface FavoriteViewController : UIViewController

@property (weak, nonatomic)id<FavoriteViewControllerDelegate> favoriteViewControllerDelegate;
@property (strong, nonatomic) UICollectionView *favoriteCollectionView;
@property (assign, nonatomic) BOOL isPlaying;

- (id)initWitBackground:(UIImage *)backgroundImage;
- (void)setBackground:(UIImage *)backgroundImage;
- (void)endRequestFavoriteList:(BOOL)isSuccessed;

@end

