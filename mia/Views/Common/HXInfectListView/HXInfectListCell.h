//
//  HXInfectListCell.h
//  mia
//
//  Created by miaios on 15/10/22.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfectItem.h"

@interface HXInfectListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet     UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *dynamicLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelSpaceConstraint;

- (void)displayWithItem:(InfectItem *)item;

@end
