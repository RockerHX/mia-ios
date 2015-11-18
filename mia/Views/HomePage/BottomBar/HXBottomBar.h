//
//  HXBottomBar.h
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXXibView.h"

typedef NS_ENUM(NSUInteger, HXBottomBarAction) {
    HXBottomBarActionFeedBack,
    HXBottomBarActionComment,
    HXBottomBarActionFavorite,
    HXBottomBarActionMore
};

@protocol HXBottomBarDelegate <NSObject>

@required
- (void)bottomBarButtonPressed:(HXBottomBarAction)action;

@end

@interface HXBottomBar : HXXibView

@property (nonatomic, weak, nullable) IBOutlet id  <HXBottomBarDelegate>delegate;

- (IBAction)feedBackButtonPressed;
- (IBAction)commentButtonPressed;
- (IBAction)favoriteButtonPressed;
- (IBAction)moreButtonPressed;

@end
