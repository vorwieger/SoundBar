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

+ (void) clip:(NSURL*)infile outfile:(NSURL*)outfile offset:(double)offset;
+ (void) clip:(NSURL*)inOutFile offset:(double)offset;

@end
