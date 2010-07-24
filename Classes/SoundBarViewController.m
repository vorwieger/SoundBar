//
//  SoundBarViewController.m
//  SoundBar
//
//  Created by Peter Vorwieger on 21.07.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SoundBarViewController.h"

@implementation SoundBarViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"SoundBarViewController viewDidLoad");
    [super viewDidLoad];
	
	recorder1 = [[SoundBarRecorder alloc] initWithName:@"record1"];
	recorder2 = [[SoundBarRecorder alloc] initWithName:@"record2"];
	recorder3 = [[SoundBarRecorder alloc] initWithName:@"record3"];
	recorder4 = [[SoundBarRecorder alloc] initWithName:@"record4"];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)play1:(id)sender {
	[recorder1 play];
}

- (IBAction)play2:(id)sender {
	[recorder2 play];
}

- (IBAction)play3:(id)sender {
	[recorder3 play];
}

- (IBAction)play4:(id)sender {
	[recorder4 play];
}

- (IBAction)startRecording1:(id)sender {
	[recorder1 start];
}

- (IBAction)startRecording2:(id)sender {
	[recorder2 start];
}

- (IBAction)startRecording3:(id)sender {
	[recorder3 start];
}

- (IBAction)startRecording4:(id)sender {
	[recorder4 start];
}

- (IBAction)stopRecording1:(id)sender {
	[recorder1 stop];
}

- (IBAction)stopRecording2:(id)sender {
	[recorder2 stop];
}

- (IBAction)stopRecording3:(id)sender {
	[recorder3 stop];
}

- (IBAction)stopRecording4:(id)sender {
	[recorder4 stop];
}

- (void)dealloc {
    [recorder1 release];
	[recorder2 release];
	[recorder3 release];
	[recorder4 release];
	[super dealloc];	
}

@end
