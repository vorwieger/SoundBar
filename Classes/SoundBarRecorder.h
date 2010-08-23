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

    BOOL start;
	double count;
	AVAudioRecorder *recorder;
	NSTimeInterval offset;
	NSString *recordPath;
    NSString *playPath;
    NSString *name;
}

@property (nonatomic, retain)	AVAudioRecorder *recorder;
@property (nonatomic, retain)	NSString *name;
@property (nonatomic, retain)	NSString *recordPath;
@property (nonatomic, retain)	NSString *playPath;

- (id)initWithName:(NSString *)name;
- (void)start;
- (void)stop;
- (void)play;

- (void)levelTimerCallback:(NSTimer *)timer;

- (void)errorDialog:(NSString *)message;
- (void)infoDialog:(NSString *)message;

@end
