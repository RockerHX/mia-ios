//
//  HXPlayMusicSummaryView.h
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicItem;
@class HXPlayMusicSummaryView;

@protocol HXPlayMusicSummaryViewDelegate <NSObject>

@required
- (void)summaryViewTaped:(HXPlayMusicSummaryView *)summaryView;

@end

@interface HXPlayMusicSummaryView : UIView

@property (weak, nonatomic) IBOutlet      id  <HXPlayMusicSummaryViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerNameLabel;

- (IBAction)tapedGesture;

- (void)displayWithMusic:(MusicItem *)music;

@end
