//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundBarRecorder.h"

@interface SoundBarRecorder ()
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSURL *recordUrl;
@property (readwrite, retain) AVAudioRecorder *recorder;
@property (readwrite) BOOL recording;
@property (readwrite) double size;
@property (readwrite) NSTimeInterval offset;
@property (readwrite) float peak;
@end

@implementation SoundBarRecorder

@synthesize delegate;
@synthesize name;
@synthesize recordUrl;
@synthesize recorder;
@synthesize recording;
@synthesize size, offset, peak;

float const MIN_PEAK = 0.3;

- (id)initWithName:(NSString *)theName {
    if ( (self = [super init]) ) {
        self.name = theName;
		NSString *fileName = [NSString stringWithFormat:@"%@.caf", self.name];

        NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];

        NSString *recordPath = [NSTemporaryDirectory () stringByAppendingPathComponent:fileName];
        self.recordUrl =  [NSURL fileURLWithPath:recordPath];

        NSError *err;
        self.recorder = [[ AVAudioRecorder alloc] initWithURL:self.recordUrl settings:recordSetting error:&err];
        if (self.recorder) {
            [self.recorder setDelegate:self];
            [self.recorder setMeteringEnabled:YES];
            [self.recorder prepareToRecord];
            DLog(@"recorder initialized: %@", self.name);
        } else {
            DLog(@"Error initializing recorder %@: %@", self.name, [err localizedDescription]);
        }
    }
    return self;
}

- (void)startRecording {
    self.recording = YES;
    self.size = 0;
    self.offset = 0;
    self.peak = 0;
    [self.recorder recordForDuration:(60)];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    DLog(@"listening...");
}

- (void)stopRecording {
    self.recording = NO;
    [self.recorder stop];
    DLog(@"stopped.");
}

- (void)levelTimerCallback:(NSTimer *)aTimer {
    if (self.recording) {
        [self.recorder updateMeters];
		float decibel = [recorder averagePowerForChannel:0];
		float level = pow(10, 0.02 * decibel);
		//DLog(@"recording level: %f", level);
        [delegate setRecordingLevel:level*2 ofSoundBarRecorder:self];
        if (level > self.peak) {
            self.peak = level;
        }
        if (self.offset == 0 && level > MIN_PEAK) {
            self.offset = MAX(0, [self.recorder currentTime] - 0.05);
            DLog(@"recording with offset of %Gs", self.offset);
        }
    } else {
        [delegate setRecordingLevel:0.0 ofSoundBarRecorder:self];
        [aTimer invalidate];
        DLog(@"finish.");
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag {
    NSFileManager *fm = [NSFileManager defaultManager];
    self.size = [[[fm attributesOfItemAtPath:self.recordUrl.path error:NULL] objectForKey:NSFileSize] doubleValue];
	DLog(@"audioRecorderDidFinishRecording size:%g, offset %Gs", self.size, self.offset);
    [self.delegate didFinishRecording:self];
}

- (void)dealloc {
    [self.recordUrl release];
    [self.recorder release];
    [super dealloc];
}

@end


