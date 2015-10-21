//
//  HXGuideView.h
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXGuideView : UIView

@property (weak, nonatomic) IBOutlet UIButton *locationButton;

- (IBAction)locationButtonPressed;

+ (instancetype)showGuide:(void(^)(void))finished;
- (void)showGuide:(void(^)(void))finished;

- (void)hidden;

@end
