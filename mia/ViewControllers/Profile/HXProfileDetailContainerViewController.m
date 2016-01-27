//
//  HXProfileDetailContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailContainerViewController.h"
#import "HXProfileSegmentView.h"

@interface HXProfileDetailContainerViewController () <
HXProfileSegmentViewDelegate
>
@end

@implementation HXProfileDetailContainerViewController {
    HXProfileSegmentView *_segmentView;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileDetailContainerIdentifier";
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (HXProfileSegmentView *)segmentView {
    if (!_segmentView) {
        _segmentView = [HXProfileSegmentView instanceWithDelegate:self];
    }
    return _segmentView;
}

#pragma mark - Table View Data Source Methods
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 10;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    HXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMessageCell class]) forIndexPath:indexPath];
//    return cell;
//}
//

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self segmentView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HXProfileSegmentViewDelegate Methods
- (void)segmentView:(HXProfileSegmentView *)segmentView selectedType:(HXProfileSegmentItemType)type {
    
}

@end
