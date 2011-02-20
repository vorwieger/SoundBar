//
//  ClipSound.h
//  ClipSound
//
//  Created by Peter Vorwieger on 19.02.11.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>

@interface ClipSound : NSObject {
}

+ (OSStatus) clip:(NSURL*)infile outfile:(NSURL*)outfile offset:(double)offset;

@end
