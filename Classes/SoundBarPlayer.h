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

@property (readonly, retain) NSString *name;
@property (readonly, retain) NSURL *playUrl;
@property (readonly) double size;

- (id)initWithName:(NSString *)theName;
- (void)playSound;

@end

