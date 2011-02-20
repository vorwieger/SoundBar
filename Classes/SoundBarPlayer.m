//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//

#import "SoundBarPlayer.h"

@interface SoundBarPlayer ()
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSURL *playUrl;
@end

@implementation SoundBarPlayer

@synthesize name;
@synthesize playUrl;
@synthesize size;

- (id)initWithName:(NSString *)aName {
    if ( (self = [super init]) ) {
        self.name = aName;
		NSString *fileName = [NSString stringWithFormat:@"%@.caf", self.name];
        NSString *playPath = [[NSHomeDirectory () stringByAppendingPathComponent:@"Documents"]
                              stringByAppendingPathComponent:fileName];
        self.playUrl =  [NSURL fileURLWithPath:playPath];
		DLog(@"player initialized  : %@", self.name);
    }
    return self;
}

- (double)size {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [[[fm attributesOfItemAtPath:self.playUrl.path error:NULL] objectForKey:NSFileSize] doubleValue];
}

- (void)playSound {
    if (self.size > 0) {
        DLog(@"playing sound of size %g", self.size);
        NSError *err;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:&err];
        if (!player) {
            DLog(@"error playing sound: %@", [err localizedDescription]);
        }
        [player setDelegate:self];
        [player setVolume:1.0];
        [player play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player release];
    DLog(@"player finish: %@", player);
}

- (void)dealloc {
    [self.name release];
    [self.playUrl release];
    [super dealloc];
}

@end


