//
//  SpeakRecordViewController.m
//  ProjectFrameDemo
//
//  Created by Rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "SpeakRecordViewController.h"
#import <lame/lame.h>
#import <AVFoundation/AVFoundation.h>
#import "AFURLSessionManager.h"
#import "JudgeViewController.h"

@interface SpeakRecordViewController ()<AVAudioPlayerDelegate,AVAudioSessionDelegate,NSURLConnectionDelegate> {
    AVAudioSession *session;
    AVAudioRecorder *recorder;
    NSArray *responseArray ;
    
}

@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (nonatomic , strong) AVAudioPlayer *player;
@property (nonatomic , strong) NSURL *recordedFile;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetButton;
@property (weak, nonatomic) IBOutlet UIButton *judgeButton;

@end

@implementation SpeakRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _recordDate = [[NSMutableString alloc] init];
//    [_recordDate setString:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]];
    self.contentText.text = self.recordContent;
    self.forgetButton.enabled = NO;
    self.judgeButton.enabled = NO;
    self.recordButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enablePressButton)
                                                 name:@"KnotificationEnableButton"
                                               object:nil];
    [self.view makeToastActivity];
}

- (void)enablePressButton {
    [self.view hideToastActivity];
    self.recordButton.enabled = TRUE;
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
    if ([segue.identifier isEqualToString:@"gotoJudgeView"]) {
        JudgeViewController *judgeViewController = segue.destinationViewController;
        judgeViewController.points = [NSString stringWithContentsOfURL:[NSURL URLWithString:[responseArray lastObject]] encoding:NSUTF8StringEncoding error:nil];;
    }
}

#pragma Mark - IBAction 
- (IBAction)pressRecordButton:(id)sender {
    // 按下录音
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/downloadFile%@.caf",_recordDate]];
    NSLog(@"%@",path);
    self.recordedFile = [NSURL URLWithString:path];//[[NSURL alloc] initFileURLWithPath:path];
    
    session = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [session setActive:YES error:nil];
    }
    /*
     NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     nil];
     */
    //录音设置
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:22050.0f] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedFile settings:settings error:nil];
    [recorder prepareToRecord];
    [recorder record];
}

- (IBAction)onClickRecordButton:(id)sender {
    [self.recordButton setTitle:@"按下可以重新录音" forState:UIControlStateNormal];
    [recorder stop];
    [self audio_PCMtoMP3];
    if(recorder) {
        recorder = nil;
    }
}

#pragma mark - Record 
#pragma mark - Record sound
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/downloadFile%@.caf",_recordDate]];
    
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/downloadFile%@.mp3",_recordDate]];
    
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil]) {
        DLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 22050.0f);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        [playButton setEnabled:YES];
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:mp3FilePath]];
        
        NSString *postLength = [NSString stringWithFormat:@"%ld", [data length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:@"http://107.150.100.46:8000/"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:[NSString stringWithFormat:@"downloadFile%@",_recordDate] forHTTPHeaderField:@"name"];
        [request setValue:@"application/x-www-form-urlencoded " forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        
        NSURLConnection *uploadConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.view makeToastActivity];
        [uploadConnection start];
    }
}

- (void)handleInterruption:(NSNotification*)notification {
    
}
- (IBAction)onClickForgetButton:(id)sender {
    if ([self.player isPlaying]) {
        return;
    }
    [self.player play];
}
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DLog(@"%@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    responseArray = [NSArray arrayWithArray:[responseString componentsSeparatedByString:@"	"]];
    [self downloadRequest];
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:[responseArray lastObject]] encoding:NSUTF8StringEncoding error:nil];
    if (string.length > 0) {
        self.judgeButton.enabled = TRUE;
    }
    DLog(@"%@",string);
    [self.view hideToastActivity];
}

#pragma mark - Download request
- (void)downloadRequest {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[responseArray objectAtIndex:1]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL*(NSURL *targetPath, NSURLResponse *response) {
        NSURL *docudocumentsDirectoryPath = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[response suggestedFilename]]]];
        return docudocumentsDirectoryPath;
    } completionHandler:^(NSURLResponse *response, NSURL*filePath, NSError *error) {
        NSError *playerError;
        NSData *contentData = [[NSData alloc] initWithContentsOfURL:filePath];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:contentData error:&playerError];
        self.player = audioPlayer;
        self.forgetButton.enabled = TRUE;
        self.player.volume = 1.0f;
        if (self.player == nil) {
            DLog(@"Error creating player: %@", [playerError description]);
        }
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        self.player.delegate = self;
        
    }];
    [downloadTask resume];
}

@end
