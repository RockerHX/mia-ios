//
//  HXInfectCell.h
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfectUserItem.h"

@interface HXInfectCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;

+ (UINib *)nib;
+ (NSString *)className;

- (void)displayInfected:(BOOL)infected;
- (void)displayWithInfecter:(InfectUserItem *)infecter;

@end
