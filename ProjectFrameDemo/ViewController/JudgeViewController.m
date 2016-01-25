//
//  JudgeViewController.m
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "JudgeViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface JudgeViewController ()
@property (nonatomic , strong) AVAudioPlayer *player;
@property (nonatomic , strong) NSString *musicName;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation JudgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.points integerValue] < 3) {
        self.title = @"哇哦，您太棒了!";
        self.musicName = @"good";
        [NSString stringWithFormat:@"您的分数是%ld成绩优秀!",10-[_points integerValue]];
        self.scoreLabel.text = [NSString stringWithFormat:@"您的分数是%ld,成绩优秀!",10-[_points integerValue]];;
    }else if([self.points integerValue] < 7) {
        self.title = @"继续加油哦!";
        self.musicName = @"normal";
        self.scoreLabel.text = [NSString stringWithFormat:@"您的分数是%ld,成绩合格!",10-[_points integerValue]];
    }else {
        self.title = @"哦哦,还要多多联系!";
        self.musicName = @"bad";
        self.scoreLabel.text = [NSString stringWithFormat:@"您的分数是%ld,成绩不合格!",10-[_points integerValue]];
    }
    
    [self playConnectMusic];
}

- (BOOL)setupPlayMusicSession {
    NSError *error;
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    
    [sessionInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
     DLog(@"couldn't set session's audio category %@", [error description]);
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
     DLog(@"couldn't set session active: %@", [error description]);
    
    return YES;
}

#pragma mark - public

- (void)playConnectMusic {
    [self setupPlayMusicSession];
    
    NSString *musicFile = [[NSBundle mainBundle] pathForResource:self.musicName ofType:@"mp3"];
    
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:musicFile] error:&error];
    _player.numberOfLoops = 1;     // Loop infinitely
    [_player play];
}

- (void)stopConnectMusic {
    if (_player) {
        [_player stop];
        _player = nil;
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
