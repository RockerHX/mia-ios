//
//  HXMusicStateView.h
//  mia
//
//  Created by miaios on 16/3/4.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HXMusicStyle) {
    HXMusicStyleBlack,
    HXMusicStyleWhite,
};

typedef NS_ENUM(NSUInteger, HXMusicState) {
    HXMusicStatePlay,
    HXMusicStateStop,
};


@class HXMusicStateView;


@protocol HXMusicStateViewDelegate <NSObject>

@required
- (void)musicStateViewTaped:(HXMusicStateView *)stateView;

@end


@interface HXMusicStateView : UIView

@property (weak, nonatomic) IBOutlet          id  <HXMusicStateViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *stateIcon;

@property (nonatomic, assign) HXMusicStyle  style;
@property (nonatomic, assign) HXMusicState  state;

- (IBAction)tapGesture;

@end
