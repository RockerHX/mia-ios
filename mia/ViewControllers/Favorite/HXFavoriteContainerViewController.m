//
//  HXFavoriteContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteContainerViewController.h"
#import "HXFavoriteHeader.h"

@interface HXFavoriteContainerViewController () <
HXFavoriteHeaderDelegate
>
@end

@implementation HXFavoriteContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table View Data Source Methods
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

#pragma mark - HXFavoriteHeaderDelegate Methods
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action {
    switch (action) {
        case HXFavoriteHeaderActionShuffle: {
            ;
            break;
        }
        case HXFavoriteHeaderActionEdit: {
            ;
            break;
        }
    }
}

@end
