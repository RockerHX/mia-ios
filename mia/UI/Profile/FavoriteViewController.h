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

@end


@interface FavoriteViewController : UIViewController

@property (weak, nonatomic)id<FavoriteViewControllerDelegate> favoriteViewControllerDelegate;
@property (strong, nonatomic) UICollectionView *favoriteCollectionView;

- (id)initWitBackground:(UIImage *)backgroundImage;
- (void)setBackground:(UIImage *)backgroundImage;
- (void)endRequestFavoriteList:(BOOL)isSuccessed;

@end

