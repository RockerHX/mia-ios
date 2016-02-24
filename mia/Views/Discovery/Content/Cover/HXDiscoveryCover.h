//
//  HXDiscoveryCover.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;

@interface HXDiscoveryCover : UIView

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *cardUserAvatar;
@property (weak, nonatomic) IBOutlet     UILabel *cardUserLabel;

- (void)displayWithItem:(ShareItem *)item;

@end
