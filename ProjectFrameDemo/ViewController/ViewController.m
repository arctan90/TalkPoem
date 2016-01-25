//
//  ViewController.m
//  ProjectFrameDemo
//
//  Created by Rick on 15/12/14.
//  Copyright © 2015年 XX_Company. All rights reserved.
//

#import "ViewController.h"
#import "NSString+IB_Encrypt.h"
#import "keywordSearchDisplayController.h"
#import "QueryByWordRequest.h"
#import "PoemListCell.h"
#import "PoemQueryKeyWordModel.h"
#import "PoemListRequest.h"
#import "PoemDetailViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,NSURLConnectionDelegate> {
    PoemQueryKeyWordModel *_currentWord;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) keywordSearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableArray *classicalArray;
@property (strong, nonatomic) NSMutableArray *englishArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString* encodeString = [@"123" encrypt];
//    NSLog(@"%@",encodeString);
//    
//    NSString* decodeString = [encodeString decrypt];
//    NSLog(@"%@",decodeString);
    [self searchController];
    [self.view makeToastActivity];
    [self getListRequestWithSwgment:self.segmentControl.selectedSegmentIndex];
}

- (IBAction)switchSegment:(id)sender {
    [self getListRequestWithSwgment:self.segmentControl.selectedSegmentIndex];
}

-(void)getListRequestWithSwgment:(NSInteger)index {
    
    PoemListRequest *request = [[PoemListRequest alloc] init];
    if (index) {
        [request setValue:@"英语" forKey:@"filter"];
    }
    __weak __typeof(self)weakSelf = self;
    [request sendRequestSuccessBlock:^(IB_BaseResponseModel *baseModel) {
        if (index) {
            weakSelf.englishArray = [NSMutableArray arrayWithArray:baseModel.questions];
        }else {
            weakSelf.classicalArray = [NSMutableArray arrayWithArray:baseModel.questions];
        }
        [weakSelf.listTableView reloadData];
    } requestFailBlock:^(IB_Error *error) {
        
    } finalBlock:^(IB_BaseResponseModel *baseModel, IB_Error *error) {
        [weakSelf.view hideToastActivity];
    }];
}
- (keywordSearchDisplayController *)searchController{
    if (!_searchController) {
        _searchController = [[keywordSearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                         contentsController:self];
    }
    return _searchController;
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


/********************************
 <IB_BaseResponseModel: id = (null) {
 code = 200;
 data =     (
 {
 name = "2015年福建省中小学教师信息技术应用能力提升工程网络研修演示平台";
 userCount = 31;
 },
 {
 name = "和威哥一起学手绘";
 userCount = 1349;
 },
 {
 name = "时间管理";
 userCount = 14870;
 },
 {
 name = "懒人PPT宝典";
 userCount = 2504;
 },
 {
 name = "职场语言艺术";
 userCount = 6747;
 },
 {
 name = "宋词";
 userCount = 6587;
 }
 );
 isCache = 0;
 message = "";
 pageIndex = 0;
 totalCount = 6;
 }>
 */

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //需要判断该tableView是界面展示的tableView还是搜索结果的tableView
    if (self.segmentControl.selectedSegmentIndex) {
        return self.englishArray.count;
    }else {
        return self.classicalArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoemListCell *cell = [tableView dequeueReusableCellWithIdentifier:[PoemListCell description]];
    if (cell == nil) {
        cell = [[PoemListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[PoemListCell description]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PoemQueryKeyWordModel *model = nil;
    if (self.segmentControl.selectedSegmentIndex) {
        model = [self.englishArray objectAtIndex:indexPath.row];
    }else {
        model = [self.classicalArray objectAtIndex:indexPath.row];
    }
    [cell fillCellWithObject:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 进入正文
//    gotoPoemDetail
    PoemQueryKeyWordModel *model = nil;
    if (self.segmentControl.selectedSegmentIndex) {
        model = [self.englishArray objectAtIndex:indexPath.row];
    }else {
        model = [self.classicalArray objectAtIndex:indexPath.row];
    }
    _currentWord = model;
    [self performSegueWithIdentifier:@"gotoPoemDetail" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    PoemQueryKeyWordModel *model = nil;
//    if (self.segmentControl.selectedSegmentIndex) {
//        model = [self.englishArray objectAtIndex:indexPath.row];
//    }else {
//        model = [self.classicalArray objectAtIndex:indexPath.row];
//    }
    return 80;
}

#pragma Mark - NSURLConnection 
- (void)sendTextConnect {
    NSData *data = [@"北山|北山输绿涨横陂 直堑回塘滟滟时。|细数落花因坐久.缓寻芳草得归迟。|" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", [data length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"http://107.150.100.46:6666/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"downloadFile%@.txt",@"downloadFile1453516422742.007080"] forHTTPHeaderField:@"name"];
    [request setValue:[NSString stringWithFormat:@"北山|北山输绿涨横陂 直堑回塘滟滟时。|细数落花因坐久.缓寻芳草得归迟。|"] forHTTPHeaderField:@"txt"];
    [request setValue:[NSString stringWithFormat:@"cn"] forHTTPHeaderField:@"type"];
    [request setValue:@"application/x-www-form-urlencoded " forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    NSURLConnection *uploadConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    [uploadConnection start];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"%@",responseString);
}
@end
