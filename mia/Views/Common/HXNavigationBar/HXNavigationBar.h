//
//  HXNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXNavigationBarDelegate <NSObject>

@optional
- (void)navigationBarDidBackAction;

@end


@interface HXNavigationBar : UIView

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong) NSString *title;

@property (weak, nonatomic) IBOutlet     id  <HXNavigationBarDelegate>delegate;

- (IBAction)backButtonPressed;

@end
