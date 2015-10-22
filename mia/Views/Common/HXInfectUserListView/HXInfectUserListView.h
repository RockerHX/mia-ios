//
//  HXInfectUserListView.h
//  mia
//
//  Created by miaios on 15/10/22.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXInfectUserListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet     UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, readonly) NSArray *itmes;

- (IBAction)closeButtonPressed;

+ (instancetype)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped;
- (void)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped;

@end
