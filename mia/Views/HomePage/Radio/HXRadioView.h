//
//  HXRadioView.h
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXRadioView;

@protocol HXRadioViewDelegate <NSObject>

@optional
- (void)radioViewDidLoad:(HXRadioView *)radioView item:(ShareItem *)item;
- (void)starTapedNeedLogin;
- (void)sharerNameTaped;

@end


@class TTTAttributedLabel;

@interface HXRadioView : UIView

@property (weak, nonatomic) IBOutlet          id  <HXRadioViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet        UIImageView *frontCoverView;
@property (weak, nonatomic) IBOutlet            UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet           UIButton *starButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shrareContentLabel;
@property (weak, nonatomic) IBOutlet            UILabel *locationLabel;

- (IBAction)starButtonPressed:(UIButton *)button;

+ (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate;
- (void)displayWithItem:(ShareItem *)item;

@end
