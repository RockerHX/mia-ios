//
//  HXBottomBar.h
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXXibView.h"

typedef NS_ENUM(NSUInteger, HXBottomBarButtonType) {
    HXBottomBarButtonTypeFeedBack,
    HXBottomBarButtonTypeComment,
    HXBottomBarButtonTypeFavorite,
    HXBottomBarButtonTypeMore
};

@protocol HXBottomBarDelegate <NSObject>

@required
- (void)bottomBarButtonPressed:(HXBottomBarButtonType)buttonType;

@end

@interface HXBottomBar : HXXibView

@property (weak, nullable, nonatomic) IBOutlet id<HXBottomBarDelegate>delegate;

- (IBAction)feedBackButtonPressed;
- (IBAction)commentButtonPressed;
- (IBAction)favoriteButtonPressed;
- (IBAction)moreButtonPressed;

@end
