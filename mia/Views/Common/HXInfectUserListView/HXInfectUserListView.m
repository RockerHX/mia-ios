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

typedef void(^BLOCK)(id item, NSInteger index);

@implementation HXInfectUserListView {
    BLOCK _tapBlock;
}

#pragma mark - Class Methods
+ (instancetype)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped {
    HXInfectUserListView *view = [[[NSBundle mainBundle] loadNibNamed:@"HXInfectUserListView" owner:self options:nil] firstObject];
    [view showWithItems:items taped:taped];
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
    
}

- (void)viewConfig {
    _containerView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
}

#pragma mark - Event Response
- (IBAction)closeButtonPressed {
    [self hidden];
}

#pragma mark - Public Methods
- (void)showWithItems:(NSArray *)items taped:(void(^)(id item, NSInteger index))taped {
    _itmes = [items copy];
    _tapBlock = taped;
    [self show];
}

#pragma mark - Private Methods
- (void)show {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = delegate.window;
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];
    
    _titleLabel.text = [NSString stringWithFormat:@"%@人秒推", @(_itmes.count ?: 0)];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
}

- (void)hidden {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.containerView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        strongSelf.containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            strongSelf.alpha = 0.0f;
        } completion:^(BOOL finished) {
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf removeFromSuperview];
        }];
    }];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itmes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXInfectUserListCell *cell = nil;
    [cell displayWithItem:_itmes[indexPath.row]];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_tapBlock) {
        _tapBlock(_itmes[indexPath.row], indexPath.row);
    }
    [self hidden];
}

@end
