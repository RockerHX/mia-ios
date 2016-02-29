//
//  HXInfectView.h
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXInfectCell.h"

typedef NS_ENUM(NSUInteger, HXInfectViewAction) {
    HXInfectViewActionInfect
};

@class HXInfectView;

@protocol HXInfectViewDelegate <NSObject>

@optional
- (void)infectView:(HXInfectView *)infectView takeAction:(HXInfectViewAction)action;
- (void)infectViewInfecterTaped:(HXInfectView *)infectView atIndex:(NSInteger)index;

@end

@interface HXInfectView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet               id  <HXInfectViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL infected;
@property (nonatomic, strong) NSArray<InfectUserItem *> *infecters;

@end
