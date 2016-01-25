//
//  RecordSoundViewController.m
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "RecordSoundViewController.h"
#import <lame/lame.h>

@interface RecordSoundViewController ()

@end

@implementation RecordSoundViewController
@synthesize player;
@synthesize recordedFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *makeSoundButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 100, 100, 50)];
    makeSoundButton.backgroundColor = [UIColor blueColor];
    [makeSoundButton setTitle:@"按下录音" forState:UIControlStateNormal];
    [makeSoundButton setTitle:@"松开录制完成" forState:UIControlStateHighlighted];
    [makeSoundButton addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [makeSoundButton addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:makeSoundButton];
    
    UIButton *pButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 100, 100, 50)];
    playButton = pButton;
    [playButton setEnabled:NO];
    playButton.backgroundColor = [UIColor blueColor];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    UIButton *zButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 30, 100, 50)];
    zButton.backgroundColor = [UIColor blueColor];
    [zButton setTitle:@"转mp3" forState:UIControlStateNormal];
    [zButton addTarget:self action:@selector(audio_PCMtoMP3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zButton];
    
    
    
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    NSLog(@"%@",path);
    self.recordedFile = [[NSURL alloc] initFileURLWithPath:path];
    NSLog(@"%@",recordedFile);
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
#pragma mark - Record sound
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
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
        lame_set_in_samplerate(lame, 11025.0);
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
        [playButton setEnabled:YES];
        NSError *playerError;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:mp3FilePath] error:&playerError];
        self.player = audioPlayer;
        player.volume = 1.0f;
        if (player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        player.delegate = self;
    }
}

- (void)playPause
{
    //If the track is playing, pause and achange playButton text to "Play"
    if([player isPlaying])
    {
        [player pause];
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    //If the track is not player, play the track and change the play button to "Pause"
    else
    {
        [player play];
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

-(void)touchDown
{
    [playButton setEnabled:NO];
    NSLog(@"==%@==",recordedFile);
    
    session = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
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
    [settings setValue :[NSNumber numberWithFloat:22050.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:nil];
    [recorder prepareToRecord];
    [recorder record];
}

-(void)touchUp
{
    [recorder stop];
    
    if(recorder)
    {
        recorder = nil;
    }
    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)handleInterruption:(NSNotification*)notification
{
    
}
@end
