//
//  SoundBarAppDelegate.h
//  SoundBar
//
//  Created by Peter Vorwieger on 21.07.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoundBarViewController;

@interface SoundBarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SoundBarViewController *viewController;
}


@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet SoundBarViewController *viewController;

@end


