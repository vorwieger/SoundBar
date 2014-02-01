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

@interface SoundBarPlayer : NSObject <AVAudioPlayerDelegate> {
}

@property (readonly, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSURL *playUrl;
@property (readonly, nonatomic) double size;

- (id)initWithName:(NSString *)theName;
- (void)setDefaultPlayUrl;
- (void)playSound;

@end

