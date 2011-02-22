//
//  ClipSound.m
//  ClipSound
//
//  Created by Peter Vorwieger on 19.02.11.
//

#import "ClipSound.h"

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

#import <AudioToolbox/ExtendedAudioFile.h>
#import <AudioToolbox/AudioConverter.h>

// read/write data in 32K chunks
#define BUFFER_SIZE ((4096 * 4) * 8)
#define SAMPLE_RATE 44100.0

@implementation ClipSound	

+ (void) setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr numChannels:(NSUInteger)numChannels {
	bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
	audioFormatPtr->mFormatID = kAudioFormatLinearPCM;
	audioFormatPtr->mSampleRate = SAMPLE_RATE;
	audioFormatPtr->mChannelsPerFrame = numChannels;
	audioFormatPtr->mBytesPerPacket = 2 * numChannels;
	audioFormatPtr->mFramesPerPacket = 1;
	audioFormatPtr->mBytesPerFrame = 2 * numChannels;
	audioFormatPtr->mBitsPerChannel = 16;
	audioFormatPtr->mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}

+ (SInt64) totalFrames:(ExtAudioFileRef)extAudioFile {
	SInt64 frameCount;
	UInt32 dataSize	= sizeof(frameCount);
	OSStatus result = ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_FileLengthFrames, &dataSize, &frameCount);
	NSAssert(noErr == result, @"ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) failed");
	return frameCount;
}

+ (void) clip:(NSURL*)infile outfile:(NSURL*)outfile offset:(double)offset {
    ExtAudioFileRef	inputAudioFileRef = NULL;
    ExtAudioFileRef	outputAudioFileRef = NULL;
    UInt8 *buffer = malloc(BUFFER_SIZE);
    OSStatus err = noErr;
    @try {
        err = ExtAudioFileOpenURL((CFURLRef)infile, &inputAudioFileRef);
        if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        AudioStreamBasicDescription	inputFileFormat;
        [self setDefaultAudioFormatFlags:&inputFileFormat numChannels:1];
        err = ExtAudioFileSetProperty(inputAudioFileRef, kExtAudioFileProperty_ClientDataFormat,
                                      sizeof(inputFileFormat), &inputFileFormat);
        if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];

        AudioStreamBasicDescription	outputFileFormat;
        [self setDefaultAudioFormatFlags:&outputFileFormat numChannels:1];
        AudioFileTypeID typeId = kAudioFileCAFType;
        UInt32 flags = kAudioFileFlags_EraseFile;
        if ([outfile.pathExtension isEqualToString:@"wav"]) {
            typeId = kAudioFileWAVEType;
            flags += kAudioFileFlags_DontPageAlignAudioData;
        }
        err = ExtAudioFileCreateWithURL((CFURLRef)outfile, typeId, &outputFileFormat, NULL, flags, &outputAudioFileRef);
        if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];

        // Buffer to read from source file and write to dest file
        AudioBufferList audioBufferList;
        audioBufferList.mNumberBuffers = 1;
        audioBufferList.mBuffers[0].mNumberChannels = 1;
        audioBufferList.mBuffers[0].mData = buffer;
        audioBufferList.mBuffers[0].mDataByteSize = BUFFER_SIZE;

        int nframes = [self totalFrames:inputAudioFileRef];
        int bytesPerFrame = sizeof(int16_t) * 1;
        int framesInBuffer = BUFFER_SIZE / bytesPerFrame;

        err = ExtAudioFileSeek(inputAudioFileRef, SAMPLE_RATE * offset);
        if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        
        DLog(@"Clipping audio file of length %0.2fs with offset by %0.2fs", nframes/SAMPLE_RATE, offset);
        
        while (TRUE) {
            UInt32 frameCount = framesInBuffer;
            err = ExtAudioFileRead(inputAudioFileRef, &frameCount, &audioBufferList);
            DLog(@"frames read: %lu", frameCount);
            if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
            if (frameCount == 0) break;
            err = ExtAudioFileWrite(outputAudioFileRef, frameCount, &audioBufferList);
            if (err) @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        }
    }
    @catch (NSError *e) {
        DLog(@"%@", e);
    } 
    @finally {
        if (buffer) free(buffer);
        if (inputAudioFileRef) ExtAudioFileDispose(inputAudioFileRef);
        if (outputAudioFileRef) ExtAudioFileDispose(outputAudioFileRef);
    }
}

@end
