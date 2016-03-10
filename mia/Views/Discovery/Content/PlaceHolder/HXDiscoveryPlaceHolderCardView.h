//
//  HXDiscoveryPlaceHolderCardView.h
//  mia
//
//  Created by miaios on 16/3/9.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HXDiscoveryPlaceHolderCardViewAction) {
    HXDiscoveryPlaceHolderCardViewActionRefresh,
};


@class HXDiscoveryPlaceHolderCardView;


@protocol HXDiscoveryPlaceHolderCardViewDelegate <NSObject>

@required
- (void)placeHolderCardView:(HXDiscoveryPlaceHolderCardView *)cardView takeAction:(HXDiscoveryPlaceHolderCardViewAction)action;

@end


@interface HXDiscoveryPlaceHolderCardView : UIView

@property (weak, nonatomic) IBOutlet id  <HXDiscoveryPlaceHolderCardViewDelegate>delegate;

- (IBAction)refreshButtonPressed;

@end
