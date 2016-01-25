//
//  keywordSearchDisplayController.m
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "keywordSearchDisplayController.h"
#import "QueryByWordRequest.h"
#import "SearchAutoCompleteRequest.h"
#import "PoemKeyword.h"
#import "QueryByWordRequest.h"
#import "SearchResultViewController.h"

@interface keywordSearchDisplayController()< UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    NSMutableArray *_searchResultArray;
}

@end

@implementation keywordSearchDisplayController
- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController{
    self = [super initWithSearchBar:searchBar contentsController:viewController];
    if (self) {
        self.searchResultsDataSource = self;
        self.searchResultsDelegate = self;
        self.delegate = self;
//        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    if(self.active == visible) {
        return;
    }
    [super setActive:visible animated:animated];
    NSArray *subViews = self.searchContentsController.view.subviews;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        for (UIView *view in subViews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                NSArray *sub = view.subviews;
                ((UIView*)sub[2]).hidden = YES;
            }
        }
    } else {
        [[subViews lastObject] removeFromSuperview];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //需要判断该tableView是界面展示的tableView还是搜索结果的tableView
    return [_searchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *upLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, SINGLE_LINE_HEIGHT)];
        upLine.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:upLine];
    }
    PoemKeyword *key = [_searchResultArray objectAtIndex:indexPath.row];
    cell.textLabel.text = key.text;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 根据关键字 搜索 正文
    PoemKeyword *key = [_searchResultArray objectAtIndex:indexPath.row];
    SearchResultViewController *searchResultViewController =
    [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchResultViewController"];
    searchResultViewController.keyword = key.text;
    [self.searchContentsController.navigationController pushViewController:searchResultViewController animated:YES];
//    [tableView makeToastActivity];
    
//    QueryByWordRequest *queryWordRequest = [[QueryByWordRequest alloc] init];
//    [queryWordRequest setValue:key.text forKey:@"keywords"];
//    [queryWordRequest sendRequestSuccessBlock:^(IB_BaseResponseModel *baseModel) {
//        DLog(@"%@",baseModel);
//    } requestFailBlock:^(IB_Error *error) {
//        
//    } finalBlock:^(IB_BaseResponseModel *baseModel, IB_Error *error) {
//        [tableView hideToastActivity];
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - UISearchDisplayDelegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0) {
    
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0){
    // 如果有搜索历史的话展示搜索历史
    [self showHistoryData:controller];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self showHistoryData:controller];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //
    __weak __typeof(self)weakSelf = self;
    if (searchText.length) {
        SearchAutoCompleteRequest *request = [[SearchAutoCompleteRequest alloc] init];
        [request setValue:searchText forKey:@"keywords"];
        [request sendRequestSuccessBlock:^(IB_BaseResponseModel *baseModel) {
            DLog(@"%@",baseModel.options);
            _searchResultArray = [NSMutableArray arrayWithArray:baseModel.options];
            
            [weakSelf showHistoryData:self];
        } requestFailBlock:^(IB_Error *error) {
            DLog(@"%@",error);
        } finalBlock:^(IB_BaseResponseModel *baseModel, IB_Error *error) {
            DLog(@"%@",baseModel);
        }];
    }else {
        [_searchResultArray removeAllObjects];
        [weakSelf.searchResultsTableView reloadData];
    }
}

- (void)showHistoryData:(UISearchDisplayController *)controller {
//    if (_searchResultArray.count > 0) {
        CGFloat topLocation = 64;
        UITableView *resultTableV = controller.searchResultsTableView;
        resultTableV.frame = CGRectMake(0, topLocation, controller.searchContentsController.view.bounds.size.width, controller.searchContentsController.view.bounds.size.height - topLocation);//controller.searchContentsController.view.frame;
        resultTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        resultTableV.hidden = NO;
        self.searchBar.hidden = NO;
        [resultTableV reloadData];
//    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}

@end
