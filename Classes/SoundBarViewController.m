//
//  SoundBarViewController.m
//  SoundBar
//
//  Created by Peter Vorwieger on 21.07.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SoundBarViewController.h"
#import "ClipSound.h"

@interface SoundBarViewController ()
@property (readwrite, strong) UILabel *versionLabel;
@property (readwrite, strong) NSMutableDictionary *players;
@property (readwrite, strong) NSMutableDictionary *recorders;
@property (readwrite, strong) NSMutableDictionary *stars;
@property (readwrite, strong) UIActionSheet *importSelector;
@property (readwrite, strong) UIActionSheet *exportSelector;
@property (readwrite, strong) NSURL *importURL;
@property (readwrite, strong) SoundBarPlayer *selectedPlayer;
@property (readwrite, strong) UIDocumentInteractionController *documentInteractionController;
- (void)addGestureRecognizers:(UIView *)aView;
@end

@implementation SoundBarViewController

@synthesize star1, star2, star3, star4, stars;
@synthesize players;
@synthesize recorders;
@synthesize importSelector, exportSelector;
@synthesize importURL, selectedPlayer, documentInteractionController;

- (void)loadView {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480) {
            [[NSBundle mainBundle] loadNibNamed:@"SoundBarViewController" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"SoundBarViewController-568h" owner:self options:nil];
        }
    }
}

- (void)viewDidLoad {
    // prepare AudioSession
    // [[AVAudioSession sharedInstance] setDelegate: self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);

    // initialize recorders and players
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.recorders = [NSMutableDictionary dictionaryWithCapacity:4];
    self.players = [NSMutableDictionary dictionaryWithCapacity:4];
    for (int i = 1; i <= 4; i++) {
        NSString *name = [NSString stringWithFormat:@"SoundBar-%d", i];
        SoundBarRecorder *recorder = [[SoundBarRecorder alloc] initWithName:name];
        SoundBarPlayer *player = [[SoundBarPlayer alloc] initWithName:name];
        recorder.delegate = self;
        (self.recorders)[name] = recorder;
        (self.players)[name] = player;
        
        // preserve compatibility for version prior 1.1
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *oldName = [NSString stringWithFormat:@"record%d", i];
        NSString *oldPath = [[NSHomeDirectory () stringByAppendingPathComponent:@"Documents"]
                             stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", oldName]];
        if ([fm isReadableFileAtPath:oldPath]) {
            DLog(@"converting %@ to %@", name, oldName);
            NSTimeInterval offset = [prefs doubleForKey:oldName];
            [prefs removeObjectForKey:oldName];
            if (offset) {
                [player setDefaultPlayUrl];
                [ClipSound clip:[NSURL fileURLWithPath:oldPath] outfile:player.playUrl offset:MAX(0, offset - 0.05)];
            }
            [fm removeItemAtPath:oldPath error:NULL];
        }
    }
    
	// initialize GestureRecognizer
	[self addGestureRecognizers:playButton1];
	[self addGestureRecognizers:playButton2];
	[self addGestureRecognizers:playButton3];
	[self addGestureRecognizers:playButton4];

	// initialize Import/Export ActionSheets
	self.importSelector = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ImportTitle", nil)
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"ImportSound1Button", nil),NSLocalizedString(@"ImportSound2Button", nil),NSLocalizedString(@"ImportSound3Button", nil), NSLocalizedString(@"ImportSound4Button", nil), nil];
	
	self.exportSelector = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SendByMailButton", nil), NSLocalizedString(@"ExportButton", nil), nil];
	
	self.documentInteractionController = [[UIDocumentInteractionController alloc] init];
	self.documentInteractionController.delegate = self;
    
    self.stars = [NSMutableDictionary dictionaryWithCapacity:4];
    (self.stars)[@"SoundBar-1"] = self.star1;
    (self.stars)[@"SoundBar-2"] = self.star2;
    (self.stars)[@"SoundBar-3"] = self.star3;
    (self.stars)[@"SoundBar-4"] = self.star4;
    self.star1.alpha = 0.0;
    self.star2.alpha = 0.0;
    self.star3.alpha = 0.0;
	self.star4.alpha = 0.0;
    
    self.recTip.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    self.playTip.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    self.recTip.alpha = 0.0;
    self.playTip.alpha = 0.0;

	[super viewDidLoad];
}

- (void)flashStar:(NSString *)name withDelay:(NSTimeInterval)delay {
    UIImageView *star = (self.stars)[name];
    [UIView animateWithDuration:0.05 delay:delay options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        star.transform = transform;
        star.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            CGAffineTransform transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            star.transform = transform;
            star.alpha = 0.0;
        } completion:NULL];
    }];
}

- (void)flashView:(UIView *)aView withDelay:(NSTimeInterval)delay {
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        aView.transform = transform;
        aView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            aView.transform = transform;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 delay:5.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                CGAffineTransform transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                aView.transform = transform;
                aView.alpha = 0.0;
            } completion:NULL];
        }];
    }];
}

- (IBAction)helpButton:(id)sender {
    [self flashView:self.recTip withDelay:0.0];
    [self flashView:self.playTip withDelay:1.0];
}

- (void)addGestureRecognizers:(UIView *)aView {
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	longPressGestureRecognizer.minimumPressDuration = 1.0; 
	[aView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		id button = recognizer.view;
		NSString *name = [[button titleLabel] text];
		DLog(@"handleLongPressGesture detected: %@", name);
		self.selectedPlayer = (self.players)[name];
		if (self.selectedPlayer.size == 0) {
			[self infoDialog:@"NoSound"];
		} else {
			[self.exportSelector showInView:self.view];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == self.importSelector) {
		DLog(@"importSelector: %d", buttonIndex);
		NSString *name = [NSString stringWithFormat:@"SoundBar-%d", buttonIndex+1];
		SoundBarPlayer *player = (self.players)[name];
        if (player) {
            DLog(@"setting %@ to importURL: %@", player.name, importURL);
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtURL:player.playUrl error:NULL];
            player.playUrl = self.importURL;
            [self flashStar:name withDelay:0.5];
        }
	} else if (actionSheet == self.exportSelector) {
		DLog(@"exportSelector: %d", buttonIndex);
		switch (buttonIndex) {
			case 0:
				[self sendSoundAsMail];
				break;
			case 1:
				self.documentInteractionController.URL = self.selectedPlayer.playUrl;			
				if (![self.documentInteractionController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES]) {
					[self infoDialog:@"NoRegistratedApp"];
				}
				break;
			default:
				break;
		}
	}
}

- (IBAction)sendSoundAsMail {
	if ([MFMailComposeViewController canSendMail]) {
		SoundBarPlayer *player = self.selectedPlayer;
		NSData *data = [NSData dataWithContentsOfURL:player.playUrl];
		NSString *fileName = player.playUrl.lastPathComponent;
		MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
		mailController.mailComposeDelegate = self;
		[mailController setSubject:NSLocalizedString(@"MailSubject", nil)];
		[mailController addAttachmentData:data mimeType:@"" fileName:fileName];
		[self presentViewController:mailController animated:YES completion:^{}];
	} else {
		[self errorDialog:@"NoMail"];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
	if (result == MFMailComposeResultFailed) {
		[self showDialogWithTitle:NSLocalizedString(@"ErrorSendingMail", nil) 
					   andMessage:[error localizedFailureReason]];
	}
	[self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setSoundFromURL:(NSURL *)aURL {
	self.importURL = aURL;
	[self.importSelector showInView:self.view];
}

- (IBAction)play:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarPlayer *player = (self.players)[name];
    if (player.size == 0) {
       [self infoDialog:@"NoSound"];
    } else {
        [player playSound];
    }
}

- (IBAction)startRecording:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarRecorder *recorder = (self.recorders)[name];
    [recorder startRecording];
}

- (IBAction)stopRecording:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarRecorder *recorder = (self.recorders)[name];
    [recorder stopRecording];
}

#pragma mark -
#pragma mark SoundBarModelDelegate

- (void)didFinishRecording:(SoundBarRecorder *)recorder {
    if (recorder.size < 20000) {
        [self infoDialog:@"NoRecording"];
    } else if (recorder.peak <= 0.3) {
        [self infoDialog:@"TooLow"];
    } else {
        [self flashStar:recorder.name withDelay:0.0];
        SoundBarPlayer *player = (self.players)[recorder.name];
        [player setDefaultPlayUrl];
        [ClipSound clip:recorder.recordUrl outfile:player.playUrl offset:recorder.offset];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Error/Info-Dialog

- (void)showDialogWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", nil)
                                          otherButtonTitles:nil];
    [alert show];
    return;
}

- (void)errorDialog:(NSString *)messageKey {
	NSLog(@"Error: %@", messageKey);
    [self showDialogWithTitle:NSLocalizedString(@"ErrorLabel", nil) andMessage:NSLocalizedString(messageKey, nil)];
}

- (void)infoDialog:(NSString *)messageKey {
    [self showDialogWithTitle:NSLocalizedString(messageKey, nil) andMessage:nil];
}

@end


