//
//  HXMeNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXMeNavigationBarAction) {
    HXMeNavigationBarMusic,
};

@class HXMeNavigationBar;

@protocol HXMeNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(HXMeNavigationBar *)bar takeAction:(HXMeNavigationBarAction)action;

@end


@interface HXMeNavigationBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXMeNavigationBarDelegate>delegate;

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong) NSString *title;

@end
