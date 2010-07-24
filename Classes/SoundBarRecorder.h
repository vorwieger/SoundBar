//
//  SoundBarRecorder.h
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SoundBarRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {

	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	NSTimeInterval offset;
	//AVAudioPlayer *player;
	NSURL *url;
	
}

- (id)initWithName:(NSString*)name;
- (void)start;
- (void)stop;
- (void)play;

- (void)levelTimerCallback:(NSTimer *)timer;
- (void)errorDialog:(NSString*)message;


@end
