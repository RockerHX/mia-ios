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
    CGFloat _footerHeight;
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
    _footerHeight = 10.0f;
    _header = [[HXProfileDetailHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, ((SCREEN_WIDTH/375.0f) * 264.0f))];
    self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.tableHeaderView = _header;
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

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_footerHeight <= _header.height) {
        if (_delegate && [_delegate respondsToSelector:@selector(detailContainerDidScroll:scrollOffset:)]) {
            [_delegate detailContainerDidScroll:self scrollOffset:scrollView.contentOffset];
        }
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self segmentView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"$$$$$$$$$$$$: %f", tableView.tableHeaderView.height);
    _footerHeight = (SCREEN_HEIGHT + self.tableView.tableHeaderView.height + 64.0f) - tableView.contentSize.height;
    NSLog(@"YYYYYYYYYYYY: %f", _footerHeight);
    _footer.height = ((_footerHeight > 0) ? _footerHeight : 10.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HXProfileSegmentViewDelegate Methods
- (void)segmentView:(HXProfileSegmentView *)segmentView selectedType:(HXProfileSegmentItemType)type {
    
}

@end
