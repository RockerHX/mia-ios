//
//  HXMusicDetailViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class ShareItem;
@class HXTextView;

@protocol HXMusicDetailViewControllerDelegate <NSObject>

@optional
- (void)detailViewControllerDidDeleteShare;
- (void)detailViewControllerDismissWithoutDelete;

@end

@interface HXMusicDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet                 id  <HXMusicDetailViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet        UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet         HXTextView *editCommentView;

@property (nonatomic, assign)      BOOL  fromProfile;
@property (nonatomic, strong) ShareItem *playItem;
@property (strong, nonatomic) NSString 	*sID;

- (IBAction)moreButtonPressed;
- (IBAction)commentButtonPressed;
- (IBAction)sendButtonPressed;

@end
