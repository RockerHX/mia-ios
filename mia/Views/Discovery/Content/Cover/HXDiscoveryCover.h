//
//  HXDiscoveryCover.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicItem;

@interface HXDiscoveryCover : UIView

@property (weak, nonatomic) IBOutlet UIImageView *cover;

- (void)displayWithMusicItem:(MusicItem *)item;

@end
