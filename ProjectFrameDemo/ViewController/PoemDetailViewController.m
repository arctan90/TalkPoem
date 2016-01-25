//
//  PoemDetailViewController.m
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "PoemDetailViewController.h"
#import "QueryPoemRequest.h"
#import "SpeakRecordViewController.h"

@interface PoemDetailViewController ()<NSURLConnectionDelegate>
{
    NSMutableString *_recordDate;
}
@property (nonatomic, weak) IBOutlet UITextView *contentTextView;
@end

@implementation PoemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contentTextView.text = @"";
    if (self.poem.content.length == 0) {
        [self getPoemDetailRequest];
    }else {
        self.contentTextView.text = self.poem.content;
    }
    
    self.contentTextView.editable = FALSE;
    _recordDate = [[NSMutableString alloc] init];
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
    if ([segue.identifier isEqualToString:@"gotoReadPoem"]) {
        SpeakRecordViewController *speakViewController = segue.destinationViewController;
        speakViewController.recordDate = _recordDate;
        speakViewController.recordContent = [[NSMutableString alloc] initWithString:self.poem.content];
    }
}

- (IBAction)onClickReadButton:(id)sender {
    // 发送文本请求
    [_recordDate setString:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]];
    [self sendTextConnect];
    [self performSegueWithIdentifier:@"gotoReadPoem" sender:nil];
}

#pragma mark - Request 
- (void)getPoemDetailRequest {
    QueryPoemRequest *request = [[QueryPoemRequest alloc] init];
    [request setValue:[NSString stringWithFormat:@"%ld",self.poem.poemID] forKey:@"ids"];
    [request sendRequestSuccessBlock:^(IB_BaseResponseModel *baseModel) {
        DLog(@"%@",baseModel);
        PoemQueryKeyWordModel *poem = [baseModel.questions firstObject];
        self.poem.content = poem.content;
        self.contentTextView.text = poem.content;
        
    } requestFailBlock:^(IB_Error *error) {
        
    } finalBlock:^(IB_BaseResponseModel *baseModel, IB_Error *error) {
        
    }];
}
#pragma Mark - NSURLConnection
- (void)sendTextConnect {
    NSString *needTransformString = @"";
    NSString *textType = @"";
    if ([self.poem.points isEqualToString:@"英语"]) {
        if (self.poem.content.length > 100) {
            needTransformString = [self.poem.content substringToIndex:100];
        }
        textType = @"en";
    }else {
        needTransformString = self.poem.content;
        textType = @"cn";
    }
    NSData *data = [needTransformString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", [data length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"http://107.150.100.46:6666/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"downloadFile%@",_recordDate] forHTTPHeaderField:@"name"];
    [request setValue:needTransformString forHTTPHeaderField:@"txt"];
    [request setValue:textType forHTTPHeaderField:@"type"];
    [request setValue:@"application/x-www-form-urlencoded " forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    NSURLConnection *uploadConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    [uploadConnection start];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([responseString isEqualToString:@"done"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KnotificationEnableButton" object:nil];
    }
    
    DLog(@"%@",responseString);
}
@end
