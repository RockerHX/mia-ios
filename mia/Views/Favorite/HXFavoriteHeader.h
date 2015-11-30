//
//  HXFavoriteHeader.h
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface HXFavoriteHeader : UIView

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (IBAction)playButtonPressed;
- (IBAction)editButtonPressed;

@end
