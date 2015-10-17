//
//  HXRadioView.h
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXRadioViewDelegate <NSObject>

@optional
- (void)userWouldLikeStarMusic;
- (void)userWouldLikeSeeSharerHomePage;

@end

@interface HXRadioView : UIView

@property (weak, nonatomic) IBOutlet          id  <HXRadioViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *frontCoverView;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *songerNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *shrareContentLabel;
@property (weak, nonatomic) IBOutlet     UILabel *locationLabel;

- (IBAction)starButtonPressed:(UIButton *)button;
- (IBAction)sharerNameButtonPressed:(UIButton *)button;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate;
- (void)displayWithItem:(id)item;

@end
