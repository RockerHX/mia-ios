//
//  HXHomePageViewController.h
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXBubbleView;
@class HXInfectUserView;
@class HXHomePageWaveView;
@class HXRadioViewController;

@interface HXHomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet           UIButton *profileButton;
@property (weak, nonatomic) IBOutlet           UIButton *shareButton;
@property (weak, nonatomic) IBOutlet       HXBubbleView *bubbleView;
@property (weak, nonatomic) IBOutlet HXHomePageWaveView *waveView;
@property (weak, nonatomic) IBOutlet        UIImageView *fishView;
@property (weak, nonatomic) IBOutlet   HXInfectUserView *infectUserView;
@property (weak, nonatomic) IBOutlet            UILabel *pushPromptLabel;
@property (weak, nonatomic) IBOutlet            UILabel *infectCountPromptLabel;
@property (weak, nonatomic) IBOutlet            UILabel *infectCountRightPromptLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fishBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewBottomConstraint;

@property (weak, nonatomic) IBOutlet   UIPanGestureRecognizer *panGesture;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property (nonatomic, weak) HXRadioViewController *radioViewController;

- (IBAction)profileButtonPressed;
- (IBAction)shareButtonPressed;
- (IBAction)feedBackButtonPressed;

- (IBAction)gestureEvent:(UIGestureRecognizer *)gesture;

@end
