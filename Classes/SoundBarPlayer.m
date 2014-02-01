//
//  SoundBarRecorder.m
//  SoundBar
//
//  Created by Peter Vorwieger on 15.06.10.
//

#import "SoundBarPlayer.h"

@interface SoundBarPlayer ()
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSMutableArray *audioPlayers;
@end

@implementation SoundBarPlayer

@synthesize name;
@synthesize playUrl;
@synthesize size;
@synthesize audioPlayers = _audioPlayers;

- (id)initWithName:(NSString *)aName {
    if ( (self = [super init]) ) {
        self.name = aName;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        playUrl = [prefs URLForKey:self.name];        
		DLog(@"player %@ initialized with URL %@", self.name, self.playUrl);
    }
    return self;
}

-(NSMutableArray *)audioPlayers{
    if (!_audioPlayers){
        _audioPlayers = [[NSMutableArray alloc] init];
    }
    return _audioPlayers;
}

- (void)setDefaultPlayUrl {
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", self.name];
    NSString *playPath = [[NSHomeDirectory () stringByAppendingPathComponent:@"Documents"]
                          stringByAppendingPathComponent:fileName];
    self.playUrl =  [NSURL fileURLWithPath:playPath];
}

- (void)setPlayUrl:(NSURL *)newUrl {
    if (playUrl != newUrl) {
        DLog(@"setting new URL: %@", newUrl);
        playUrl = newUrl;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setURL:playUrl forKey:self.name];
        [prefs synchronize];
    }
}

- (double)size {
    if (!self.playUrl) return 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    return [[fm attributesOfItemAtPath:self.playUrl.path error:NULL][NSFileSize] doubleValue];
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
        [self.audioPlayers addObject:player];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.audioPlayers removeObject:player];
    DLog(@"player finish.");
}

@end


