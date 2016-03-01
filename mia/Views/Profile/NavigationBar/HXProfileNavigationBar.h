//
//  HXProfileNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXProfileNavigationBarAction) {
    HXProfileNavigationBarBack,
    HXProfileNavigationBarMusic,
};

@class HXProfileNavigationBar;

@protocol HXProfileNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(HXProfileNavigationBar *)bar takeAction:(HXProfileNavigationBarAction)action;

@end


@interface HXProfileNavigationBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXProfileNavigationBarDelegate>delegate;

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong) NSString *title;

@end
