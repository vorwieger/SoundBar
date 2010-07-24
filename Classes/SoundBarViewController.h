//
//  SoundBarViewController.h
//  SoundBar
//
//  Created by Peter Vorwieger on 21.07.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "SoundBarRecorder.h"

@interface SoundBarViewController : UIViewController {
	
	SoundBarRecorder *recorder1;
	SoundBarRecorder *recorder2;
	SoundBarRecorder *recorder3;
	SoundBarRecorder *recorder4;
	
}

- (IBAction)play1:(id)sender;
- (IBAction)play2:(id)sender;
- (IBAction)play3:(id)sender;
- (IBAction)play4:(id)sender;

- (IBAction)startRecording1:(id)sender;
- (IBAction)startRecording2:(id)sender;
- (IBAction)startRecording3:(id)sender;
- (IBAction)startRecording4:(id)sender;

- (IBAction)stopRecording1:(id)sender;
- (IBAction)stopRecording2:(id)sender;
- (IBAction)stopRecording3:(id)sender;
- (IBAction)stopRecording4:(id)sender;


@end

