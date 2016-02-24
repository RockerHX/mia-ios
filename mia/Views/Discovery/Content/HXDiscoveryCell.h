//
//  HXDiscoveryCell.h
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXDiscoveryCover;

@interface HXDiscoveryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet HXDiscoveryCover *coverView;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;
//@property (weak, nonatomic) IBOutlet *;

- (void)displayWithItem:(id)item;

@end
