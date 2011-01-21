//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundBarPlayer.h"

@interface SoundBarPlayer ()
@property (readwrite) int index;
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSURL *playUrl;
@property (readwrite) NSTimeInterval offset;
@property (readwrite) double size;
@end

@implementation SoundBarPlayer

@synthesize index, name;
@synthesize playUrl;
@synthesize offset, size;

- (id)initWithName:(NSString *)theName {
    if ( (self = [super init]) ) {
        self.name = theName;
		NSString *fileName = [NSString stringWithFormat:@"%@.caf", self.name];

        NSString *playPath = [[NSHomeDirectory () stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
        self.playUrl =  [NSURL fileURLWithPath:playPath];

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.offset = [prefs doubleForKey:self.name];

        NSFileManager *fm = [NSFileManager defaultManager];
        self.size = [[[fm attributesOfItemAtPath:self.playUrl.path error:NULL] objectForKey:NSFileSize] doubleValue];
		
		NSLog(@"player initialized  : %@", self.name);
    }
    return self;
}

- (void)setSoundFromURL:(NSURL *)aUrl withOffset:(NSTimeInterval)aOffset {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    if (![fm removeItemAtURL:self.playUrl error:&err]) {
        NSLog(@"ERROR removeItemAtURL :%@", [err localizedDescription]);
    }
    if (aUrl) {
        if (![fm copyItemAtURL:aUrl toURL:self.playUrl error:&err]) {
            NSLog(@"ERROR copyItemAtURL %@ :%@", aUrl, [err localizedDescription]);
        }
    }

    // setting offset
	self.offset = aOffset;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setDouble:self.offset forKey:self.name];
    [prefs synchronize];

    // setting size
    self.size = [[[fm attributesOfItemAtPath:self.playUrl.path error:NULL] objectForKey:NSFileSize] doubleValue];
	NSLog(@"player %@ > setSoundFromUrl: %@, size:%d, offset:%f", self.name, self.size, self.offset);
}

- (void)setSoundFromURL:(NSURL *)aUrl {
    self.offset = 0;
    [self setSoundFromURL:aUrl withOffset:0];
}

- (void)playSound {
    if (self.size > 0) {
        NSLog(@"playing sound of size %g and offset of %Gs", self.size, self.offset);
        NSError *err;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:&err];
        if (!player) {
            NSLog(@"error playing sound: %@", [err localizedDescription]);
        }
        [player setDelegate:self];
        [player setCurrentTime:offset];
        [player setVolume:1.0];
        [player play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player release];
    NSLog(@"player finish: %@", player);
}

- (void)dealloc {
    [self.name release];
    [self.playUrl release];
    [super dealloc];
}

@end


