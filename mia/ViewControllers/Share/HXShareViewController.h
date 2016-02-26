//
//  HXShareViewController.h
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class HXTextView;

@protocol HXShareViewControllerDelegate <NSObject>

@optional
- (void)shareViewControllerDidShareMusic;

@end

@interface HXShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet           id  <HXShareViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet     UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet      UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet      UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet     UIButton *addMusicButton;
@property (weak, nonatomic) IBOutlet  UIImageView *frontCover;
@property (weak, nonatomic) IBOutlet       UIView *frontCoverView;
@property (weak, nonatomic) IBOutlet     UIButton *playButton;
@property (weak, nonatomic) IBOutlet     UIButton *resetButton;
@property (weak, nonatomic) IBOutlet      UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet   HXTextView *commentTextView;
@property (weak, nonatomic) IBOutlet       UIView *locationView;
@property (weak, nonatomic) IBOutlet      UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *frontCoverTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottmonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewHeightConstraint;

- (IBAction)backButtonPressed;
- (IBAction)sendButtonPressed;
- (IBAction)addMusicButtonPressed;
- (IBAction)playButtonPressed;
- (IBAction)resetButtonPressed;
- (IBAction)closeLocationPressed;
- (IBAction)tapGesture;

@end
