//
//  HXInfectUserListView.m
//  mia
//
//  Created by miaios on 15/10/22.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXInfectUserListView.h"
#import "HXInfectUserListCell.h"
#import "AppDelegate.h"
#import "MiaAPIHelper.h"
#import "MJRefresh.h"
#import "HXVersion.h"
#import "HXAlertBanner.h"

typedef void(^BLOCK)(id item, NSInteger index);

static NSInteger kInfectListItemCountInPage = 10;

@implementation HXInfectUserListView {
    BLOCK _tapBlock;
    NSString *_sID;
    __block NSString *_lastInfectID;
    NSMutableArray *_listItems;
}

#pragma mark - Class Methods
+ (instancetype)instance {
    return [[[NSBundle mainBundle] loadNibNamed:@"HXInfectUserListView" owner:self options:nil] firstObject];
}

+ (instancetype)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped {
    HXInfectUserListView *view = [HXInfectUserListView instance];
    [view showWithItems:items taped:taped];
    return view;
}

+ (instancetype)showWithSharerID:(NSString *)sID taped:(void(^)(id item, NSInteger index))taped {
    HXInfectUserListView *view = [HXInfectUserListView instance];
    [view showWithSharerID:sID taped:taped];
    return view;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _lastInfectID = @"0";
    _listItems = @[].mutableCopy;
    NSString *className = NSStringFromClass([HXInfectUserListCell class]);
    UINib *nib = [UINib nibWithNibName:className bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:className];
}

- (void)viewConfig {
    _containerView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    _tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Event Response
- (IBAction)closeButtonPressed {
    [self hidden:nil];
}

#pragma mark - Public Methods
- (void)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped {
    _listItems = [items copy];
    _tapBlock = taped;
    [self show];
}

- (void)showWithSharerID:(NSString *)sID taped:(void(^)(id item, NSInteger index))taped {
	_sID = sID;
	_tapBlock = taped;
	__weak __typeof__(self)weakSelf = self;
	_tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
		__strong __typeof__(self)strongSelf = weakSelf;
		// 分页需要传入上一次拉取到的最后一条的infectid作为参数
		_lastInfectID = @"0";
		[MiaAPIHelper getInfectListWithSID:sID
								   startID:_lastInfectID
									  item:kInfectListItemCountInPage
							 completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 NSArray *infectList = userInfo[@"v"][@"data"];
				 if (!infectList) {
					 return;
				 }

				 [_listItems removeAllObjects];
				 for (NSDictionary *dictItem in infectList) {
					 InfectItem *item = [[InfectItem alloc] initWithDictionary:dictItem];
					 strongSelf->_lastInfectID = item.infectid;
					 [strongSelf->_listItems addObject:item];
				 }

				 [strongSelf reloadList];
				 if (!strongSelf.tableView.mj_footer) {
					 [strongSelf addRefreshFooterWithSharerID:sID];
				 }
			 } else {
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]] tap:nil];
			 }

			 [strongSelf endRefreshing];
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 NSLog(@"showWithSharerID getInfectListWithSID Timeout");
			 [strongSelf reloadList];
		 }];
	}];
	[self showWithRefeshControl];
}

#pragma mark - Private Methods
- (void)show {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = delegate.window;
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];

    [self updateTitleLabel];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
}

- (void)showWithRefeshControl {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = delegate.window;
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];
    
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.tableView.mj_header beginRefreshing];
    }];
}

- (void)updateTitleLabel {
    _titleLabel.text = [NSString stringWithFormat:@"%@人妙推", @(_listItems.count ?: 0)];
}

- (void)reloadList {
    [self updateTitleLabel];
    [_tableView reloadData];
}

- (void)endRefreshing {
	[_tableView.mj_header endRefreshing];
	[_tableView.mj_footer endRefreshing];
}

- (void)addRefreshFooterWithSharerID:(NSString *)sID {
    __weak __typeof__(self)weakSelf = self;
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof__(self)strongSelf = weakSelf;
		// 分页需要传入上一次拉取到的最后一条的infectid作为参数
		[MiaAPIHelper getInfectListWithSID:sID
								   startID:_lastInfectID
									  item:kInfectListItemCountInPage
							 completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 NSArray *infectList = userInfo[@"v"][@"data"];
				 if (!infectList) {
					 return;
				 }

				 for (NSDictionary *dictItem in infectList) {
					 InfectItem *item = [[InfectItem alloc] initWithDictionary:dictItem];
					 strongSelf->_lastInfectID = item.infectid;
					 [strongSelf->_listItems addObject:item];
				 }
				 [strongSelf reloadList];
			 } else {
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]] tap:nil];
			 }

			 [strongSelf endRefreshing];
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 NSLog(@"addRefreshFooterWithSharerID Timeout");
			 [strongSelf endRefreshing];
		 }];
	}];
}

- (void)hidden:(void(^)(void))completed {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        strongSelf.containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            strongSelf.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (completed) {
                completed();
            }
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf removeFromSuperview];
        }];
    }];
}

- (void)hiddenWithIndex:(NSInteger)index {
    __weak __typeof__(self)weakSelf = self;
    [self hidden:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        if (strongSelf->_tapBlock) {
           strongSelf-> _tapBlock(_listItems[index], index);
        }
    }];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = NSStringFromClass([HXInfectUserListCell class]);
    HXInfectUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:cellName owner:nil options:nil];
        cell = [nibs lastObject];
    };
    [cell displayWithItem:_listItems[indexPath.row]];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak __typeof__(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf hiddenWithIndex:indexPath.row];
    });
}

#pragma mark - Setter And Getter
- (NSArray *)itmes {
    return [_listItems copy];
}

@end
