//
//  RecordSoundViewController.h
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "IB_BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordSoundViewController : IB_BaseViewController<AVAudioPlayerDelegate,AVAudioSessionDelegate>
{
    UIButton *playButton;
    AVAudioSession *session;
    
    NSURL *recordedFile;
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
}
@property (nonatomic , retain) AVAudioPlayer *player;
@property (nonatomic , retain) NSURL *recordedFile;
@end
