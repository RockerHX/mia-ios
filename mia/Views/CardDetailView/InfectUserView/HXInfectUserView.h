//
//  HXInfectUserView.h
//  mia
//
//  Created by miaios on 15/10/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXInfectUserView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet        UIStackView *stacView;

@property (nonatomic, assign)           CGFloat  itemWidth;
@property (nonatomic, strong, readonly) NSArray *items;

- (void)refresh;
- (void)refreshItemWithAnimation;
- (void)showWithItems:(NSArray *)items;

- (void)addItem:(id)item;
- (void)addItems:(NSArray *)items;
- (void)addItem:(id)item atIndex:(NSInteger)index;
- (void)addItemAtFirstIndex:(id)item;
- (void)addItemAtLastIndex:(id)item;

- (void)removeAllItem;
- (void)removeItem:(id)item atIndex:(NSInteger)index;
- (void)removeItemAtFirstIndex:(id)item;
- (void)removeItemAtLastIndex:(id)item;

@end
