//
//  SearchResultViewController.m
//  HackthonProject
//
//  Created by rick on 1/25/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "SearchResultViewController.h"
#import "QueryByWordRequest.h"
#import "PoemQueryKeyWordModel.h"
#import "PoemListCell.h"
#import "PoemDetailViewController.h"

@interface SearchResultViewController ()<UITableViewDataSource,UITableViewDelegate> {
    PoemQueryKeyWordModel *_currentWord;
}
@property (strong, nonatomic) NSMutableArray *classicalArray;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self keywordRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"gotoPoemDetail"]) {
        PoemDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.poem = _currentWord;
    }
}


- (void)keywordRequest {
    [self.view makeToastActivity];
    QueryByWordRequest *queryWordRequest = [[QueryByWordRequest alloc] init];
    [queryWordRequest setValue:self.keyword forKey:@"keywords"];
    __weak __typeof(self)weakSelf = self;
    [queryWordRequest sendRequestSuccessBlock:^(IB_BaseResponseModel *baseModel) {
        DLog(@"%@",baseModel);
        weakSelf.classicalArray = [NSMutableArray arrayWithArray:baseModel.questions];
        [weakSelf.listTableView reloadData];
    } requestFailBlock:^(IB_Error *error) {
        
    } finalBlock:^(IB_BaseResponseModel *baseModel, IB_Error *error) {
        [weakSelf.view hideToastActivity];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //需要判断该tableView是界面展示的tableView还是搜索结果的tableView
    return self.classicalArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoemListCell *cell = [tableView dequeueReusableCellWithIdentifier:[PoemListCell description]];
    if (cell == nil) {
        cell = [[PoemListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PoemListCell description]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PoemQueryKeyWordModel *model = nil;
    model = [self.classicalArray objectAtIndex:indexPath.row];
    [cell fillCellWithObject:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 进入正文
    //    gotoPoemDetail
    PoemQueryKeyWordModel *model = nil;
    model = [self.classicalArray objectAtIndex:indexPath.row];
    _currentWord = model;
    [self performSegueWithIdentifier:@"gotoPoemDetail" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
@end
