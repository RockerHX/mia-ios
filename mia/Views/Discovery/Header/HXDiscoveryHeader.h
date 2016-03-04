//
//  HXDiscoveryHeader.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HXDiscoveryHeaderAction) {
    HXDiscoveryHeaderActionShare,
    HXDiscoveryHeaderActionMusic
};


@class HXMusicStateView;
@class HXDiscoveryHeader;


@protocol HXDiscoveryHeaderDelegate <NSObject>

@required
- (void)discoveryHeader:(HXDiscoveryHeader *)header takeAction:(HXDiscoveryHeaderAction)action;

@end


@interface HXDiscoveryHeader : UIView

@property (nonatomic, weak) IBOutlet id <HXDiscoveryHeaderDelegate>delegate;

@property (weak, nonatomic) IBOutlet HXMusicStateView *stateView;

- (IBAction)shareButtonPressed;

@end
