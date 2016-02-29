//
//  HXNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXNavigationBarAction) {
    HXNavigationBarBack,
    HXNavigationBarMusic,
};

@class HXNavigationBar;

@protocol HXNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(HXNavigationBar *)bar takeAction:(HXNavigationBarAction)action;

@end


@interface HXNavigationBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXNavigationBarDelegate>delegate;

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong) NSString *title;

@end
