//
//  HXDiscoveryCardView.h
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXDiscoveryCover;
@class HXDiscoveryCardView;

typedef NS_ENUM(NSUInteger, HXDiscoveryCardViewAction) {
    HXDiscoveryCardViewActionPlay
};

@protocol HXDiscoveryCardViewDelegate <NSObject>

@optional
- (void)cardView:(HXDiscoveryCardView *)view takeAction:(HXDiscoveryCardViewAction)action;

@end

@interface HXDiscoveryCardView : UIView

@property (weak, nonatomic) IBOutlet HXDiscoveryCover *coverView;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;

@property (nonatomic, weak) id <HXDiscoveryCardViewDelegate>delegate;

- (void)displayWithItem:(id)item;

@end
