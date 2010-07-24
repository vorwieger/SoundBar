//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundBarRecorder.h"


@implementation SoundBarRecorder

- (id)initWithName:(NSString*)name {
	if ( self = [super init] ) {
		
		AVAudioSession *audioSession = [AVAudioSession sharedInstance];
		if (!audioSession.inputIsAvailable) {
			[self errorDialog:@"Audio input hardware not available"];
		}
		
		NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];
		//[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
		[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
		[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
		[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//		[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//		[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
		[recordSetting setValue :[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
		
		NSString *root = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *path = [NSString stringWithFormat:@"%@/%@.caf", root, name];
		url = [NSURL fileURLWithPath:path];
		
		NSError *err = nil;
		recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
		if (!recorder) {	
			NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			[self errorDialog:[err localizedDescription]];
		}
		
		[recorder setDelegate:self];
		[recorder setMeteringEnabled:YES];
		[recorder prepareToRecord];
		
		NSLog(@"recorder initialized: %@", url);
		
	}
	return self;
}

- (void)start {
	offset = 0;
	levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	//NSLog(@"recorder start... recording?: %i", [recorder isRecording]);
	//NSDate *methodStart = [NSDate date];
	[recorder record];
	//NSLog(@"Time elapsed: %Gms", -[methodStart timeIntervalSinceNow]*1000);
}

- (void)stop {
	[levelTimer invalidate];
	NSLog(@"recorder stop...");
	//NSDate *methodStart = [NSDate date];
	[recorder stop];
	//NSLog(@"Time elapsed: %Gms", -[methodStart timeIntervalSinceNow]*1000);
	//NSLog(@"recorder stopped.");
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
	NSLog(@"Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
	if (offset == 0 && [recorder peakPowerForChannel:0] > -20 ) {
		offset = [recorder currentTime];
		NSLog(@"recording with offset of %Gs", offset);
	}
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag {
	NSLog (@"audioRecorderDidFinishRecording:successfully: %i %@",flag, url);
	// your actions here
}

- (void)play {
	NSLog(@"play: %@", url);	
	NSError *err;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    [player setDelegate:self];
	[player setCurrentTime:offset];
	if (!player) {
		NSLog(@"no player: %@", [err localizedDescription]);
		[self errorDialog:[err localizedDescription]];
	}
	[player play];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying --> player: %@", player);
    [player release];
}

- (void)errorDialog:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release]; 
	return;
}

- (void)dealloc {
	[recorder release];
	[super dealloc];
}

@end
