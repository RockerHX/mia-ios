//
//  HXMusicDetailViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

typedef NS_ENUM(NSUInteger, HXMusicDetailAction) {
    HXMusicDetailActionDelete,
};

@class ShareItem;
@class HXTextView;
@class HXMusicDetailViewController;

@protocol HXMusicDetailViewControllerDelegate <NSObject>

@optional
- (void)detailViewController:(HXMusicDetailViewController *)detail takeAction:(HXMusicDetailAction)action;

@end

@interface HXMusicDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet                 id  <HXMusicDetailViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet         HXTextView *editCommentView;

@property (nonatomic, assign)      BOOL  fromProfile;
@property (nonatomic, strong) ShareItem *playItem;
@property (strong, nonatomic) NSString 	*sID;

- (IBAction)moreButtonPressed;
- (IBAction)commentButtonPressed;
- (IBAction)sendButtonPressed;

@end
