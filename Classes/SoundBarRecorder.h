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

@class SoundBarRecorder;

@protocol SoundBarRecorderDelegate
- (void)didFinishRecording:(SoundBarRecorder *)soundBarRecorder;
@end

@interface SoundBarRecorder : NSObject <AVAudioRecorderDelegate> {
}

@property (weak) id <SoundBarRecorderDelegate> delegate;
@property (readonly, strong) NSString *name;
@property (readonly, strong) NSURL *recordUrl;
@property (readonly) double size;
@property (readonly) NSTimeInterval offset;
@property (readonly) float peak;

- (id)initWithName:(NSString *)theName;
- (void)startRecording;
- (void)stopRecording;

@end

