//
//  HXProfileCoverContainerViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@interface HXProfileCoverContainerViewController : UICollectionViewController

@property (nonatomic, strong)  NSArray *dataSource;

- (void)scrollPosition:(UICollectionViewScrollPosition)position;

@end
