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
@property (readwrite, retain) UILabel *versionLabel;
@property (readwrite, retain) NSMutableDictionary *players;
@property (readwrite, retain) NSMutableDictionary *recorders;
@property (readwrite, retain) UIActionSheet *importSelector;
@property (readwrite, retain) UIActionSheet *exportSelector;
@property (readwrite, retain) NSURL *importURL;
@property (readwrite, retain) SoundBarPlayer *selectedPlayer;
@property (readwrite, retain) UIDocumentInteractionController *documentInteractionController;
- (void)addGestureRecognizers:(UIView *)aView;
@end

@implementation SoundBarViewController

@synthesize versionLabel;
@synthesize players;
@synthesize recorders;
@synthesize importSelector, exportSelector;
@synthesize importURL, selectedPlayer, documentInteractionController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    // update the version label with version number from Info.plist
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist", bundlePath]];

    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version", nil), [infoDictionary objectForKey:@"CFBundleVersion"]];
	//self.versionLabel.text = @"loading...";

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
        NSString *name = [NSString stringWithFormat:@"record%d", i];
        SoundBarRecorder *recorder = [[[SoundBarRecorder alloc] initWithName:name] autorelease];
        SoundBarPlayer *player = [[[SoundBarPlayer alloc] initWithName:name] autorelease];
        recorder.delegate = self;
        [self.recorders setObject:recorder forKey:name];
        [self.players setObject:player forKey:name];
        
        // preserve compatibility for version prior 1.1
        NSTimeInterval offset = [prefs doubleForKey:name];
        if (offset) {
            DLog(@"converting %@ -> clip", name);
            [player setDefaultPlayUrl];
            NSString *oldPath = [[NSHomeDirectory () stringByAppendingPathComponent:@"Documents"]
                                  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", name]];
            [ClipSound clip:[NSURL fileURLWithPath:oldPath] outfile:player.playUrl offset:MAX(0, offset - 0.05)];
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:oldPath error:NULL];
        }
    }
    
	// initialize GestureRecognizer
	[self addGestureRecognizers:playButton1];
	[self addGestureRecognizers:playButton2];
	[self addGestureRecognizers:playButton3];
	[self addGestureRecognizers:playButton4];

	// initialize Import/Export ActionSheets
	self.importSelector = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ImportTitle", nil)
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"ImportSound1Button", nil),NSLocalizedString(@"ImportSound2Button", nil),NSLocalizedString(@"ImportSound3Button", nil), NSLocalizedString(@"ImportSound4Button", nil), nil] autorelease];
	
	self.exportSelector = [[[UIActionSheet alloc] initWithTitle:nil
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SendByMailButton", nil), NSLocalizedString(@"ExportButton", nil), nil] autorelease];
	
	self.documentInteractionController = [[[UIDocumentInteractionController alloc] init] autorelease];
	self.documentInteractionController.delegate = self;
	
	[super viewDidLoad];
}

- (void)addGestureRecognizers:(UIView *)aView {
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	longPressGestureRecognizer.minimumPressDuration = 1.0; 
	[aView addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer release];
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		id button = recognizer.view;
		NSString *name = [[button titleLabel] text];
		DLog(@"handleLongPressGesture detected: %@", name);
		self.selectedPlayer = [self.players objectForKey:name];
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
		NSString *name = [NSString stringWithFormat:@"record%d", buttonIndex+1];
		SoundBarPlayer *player = [self.players objectForKey:name];
        if (player) {
            DLog(@"setting %@ to importURL: %@", player.name, importURL);
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtURL:player.playUrl error:NULL];
            player.playUrl = self.importURL;
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
		[self presentModalViewController:mailController animated:YES];
		[mailController release];
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
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setSoundFromURL:(NSURL *)aURL {
	self.importURL = aURL;
	[self.importSelector showInView:self.view];
}

- (IBAction)play:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarPlayer *player = [self.players objectForKey:name];
    if (player.size == 0) {
        [self infoDialog:@"NoSound"];
    } else {
        [player playSound];
    }
}

- (IBAction)startRecording:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarRecorder *recorder = [self.recorders objectForKey:name];
    [recorder startRecording];
}

- (IBAction)stopRecording:(id)sender {
    NSString *name = [[sender titleLabel] text];
    SoundBarRecorder *recorder = [self.recorders objectForKey:name];
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
        SoundBarPlayer *player = [self.players objectForKey:recorder.name];
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

- (void)viewDidUnload {
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.versionLabel = nil;
}

- (void)dealloc {
    [versionLabel release];
    [recorders release];
    [players release];
	[importSelector release];
	[exportSelector release];
	[documentInteractionController release];
    [super dealloc];
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
    [alert release];
    return;
}

- (void)errorDialog:(NSString *)messageKey {
	NSLog(@"Error: %@", messageKey);
    [self showDialogWithTitle:NSLocalizedString(@"ErrorLabel", nil) andMessage:NSLocalizedString(messageKey, nil)];
}

- (void)infoDialog:(NSString *)messageKey {
    [self showDialogWithTitle:NSLocalizedString(@"InfoLabel", nil) andMessage:NSLocalizedString(messageKey, nil)];
}

@end


