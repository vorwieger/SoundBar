//
//  SoundBarViewController.h
//  SoundBar
//
//  Created by Peter Vorwieger on 21.07.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>

#import "SoundBarRecorder.h"
#import "SoundBarPlayer.h"

@interface SoundBarViewController : UIViewController <SoundBarRecorderDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
	IBOutlet UIButton *playButton1;
	IBOutlet UIButton *playButton2;
	IBOutlet UIButton *playButton3;
	IBOutlet UIButton *playButton4;
}

@property (readonly, strong) IBOutlet UILabel *versionLabel;
@property (readonly, strong) IBOutlet UIImageView *star1;
@property (readonly, strong) IBOutlet UIImageView *star2;
@property (readonly, strong) IBOutlet UIImageView *star3;
@property (readonly, strong) IBOutlet UIImageView *star4;

@property (weak, nonatomic) IBOutlet UIView *recTip;
@property (weak, nonatomic) IBOutlet UIView *playTip;
@property (weak, nonatomic) IBOutlet UILabel *recTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *playTipLabel;
- (IBAction)helpButton:(id)sender;

- (void)setSoundFromURL:(NSURL *)aURL;
- (IBAction)sendSoundAsMail;

- (IBAction)play:(id)sender;
- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

- (void)showDialogWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)errorDialog:(NSString *)messageKey;
- (void)infoDialog:(NSString *)messageKey;

@end


