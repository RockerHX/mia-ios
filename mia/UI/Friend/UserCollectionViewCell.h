//
//  UserCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserItem;
	
@interface UserCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UserItem *dataItem;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end