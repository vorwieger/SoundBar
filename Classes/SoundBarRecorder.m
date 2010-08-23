//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundBarRecorder.h"


@implementation SoundBarRecorder

@synthesize recorder, name, recordPath, playPath;

- (id)initWithName:(NSString*)_name {
	if ( self = [super init] ) {
        
        self.name = _name;
		
		NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];
		[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
		[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
		[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
		[recordSetting setValue :[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
        
        self.recordPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", name]];
        NSURL *recordUrl =  [NSURL fileURLWithPath:self.recordPath];
        
        self.playPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", name]];
		
		NSError *err = nil;
		self.recorder = [[ AVAudioRecorder alloc] initWithURL:recordUrl settings:recordSetting error:&err];
		if (!recorder) {	
			NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			[self errorDialog:[err localizedDescription]];
		}
		
		[recorder setDelegate:self];
		[recorder setMeteringEnabled:YES];
        [recorder prepareToRecord];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        offset = [prefs doubleForKey:name];
		
		NSLog(@"recorder initialized: %@", recordPath);
        
	}
	return self;
}

- (void)start {
    start = YES;
    offset = 0;
	count = 0;
    [recorder record];
    [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    NSLog(@"recording started.");
}

- (void)stop {
    start = NO;
    if (offset == 0) {
		if (count < 50) {
			[self infoDialog:NSLocalizedString(@"NoRecording", nil)];
		} else {
			[self infoDialog:NSLocalizedString(@"TooLow", nil)];
		}
    }
    [recorder stop];
    NSLog(@"recording stopped. %d", count);
}

- (void)levelTimerCallback:(NSTimer *)timer {
    if (start) {
		count++;
		[recorder updateMeters];
        //NSLog(@"recording level: %f", [recorder peakPowerForChannel:0]);
        if (offset == 0 && [recorder peakPowerForChannel:0] > -20 ) {
            offset = [recorder currentTime];
            NSLog(@"recording with offset of %Gs", offset);
        }
    } else {
        [timer invalidate];
        NSLog(@"finish.");
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag {
	NSLog (@"audioRecorderDidFinishRecording:successfully: %@", recordPath);
    
    NSError *err = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:playPath error:NULL];
    [fm copyItemAtPath:self.recordPath toPath:self.playPath error:&err];
    if (err) {	
        [self errorDialog:[err localizedDescription]];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setDouble:offset forKey:name];
    [prefs synchronize];
    
   	//[recorder prepareToRecord];

}

- (void)play {
    if (offset == 0) {
        [self infoDialog:NSLocalizedString(@"NoSound", nil)];
    } else {
		NSError *err;
		AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.playPath] error:&err];
		if (!player) {
			NSLog(@"no player: %@", [err localizedDescription]);
			[self errorDialog:[err localizedDescription]];
		} else {
			[player setDelegate:self];
			[player setCurrentTime:MAX(0, offset - 0.05)];
			[player setVolume: 1.0];
			if ([player duration] > 0) {
				[player play];
				NSLog(@"player playing: %@, offset: %F, duration: %F", player, offset, player.duration); 
			} else {
				[player release];
			}
		}
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([player retainCount] != 1) {
        [player release];
    }
    NSLog(@"player finish: %@", player);
}

- (void)errorDialog:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ErrorLabel", nil)
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release]; 
	return;
}

- (void)infoDialog:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"InfoLabel", nil)
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
