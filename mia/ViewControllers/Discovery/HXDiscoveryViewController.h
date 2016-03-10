//
//  HXDiscoveryViewController.h
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"


@class HXDiscoveryHeader;


@interface HXDiscoveryViewController : UIViewController

@property (weak, nonatomic) IBOutlet HXDiscoveryHeader *header;

- (void)loadShareList;
- (void)refreshShareItem;

@end
