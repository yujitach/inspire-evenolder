//
//  AuxPanelController.m
//  spires
//
//  Created by Yuji on 6/29/09.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "AuxPanelController.h"


@implementation AuxPanelController
-(AuxPanelController*)initWithWindowNibName:(NSString*)nibName
{
    nibIsVisibleKey=[nibName stringByAppendingString:@"IsVisible"];
    self=[super initWithWindowNibName:nibName];
    [[self window] setLevel:NSNormalWindowLevel];
    [[self window] setIsVisible:[[NSUserDefaults standardUserDefaults] boolForKey:nibIsVisibleKey]];
    return self;
}
-(void)showhide:(id)sender
{
    if([[self window] isVisible]){
	[[self window] setIsVisible:NO];
    }else{
	[[self window] makeKeyAndOrderFront:sender];
    }
}
-(void)windowDidBecomeKey:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:nibIsVisibleKey];
}
-(void)windowWillClose:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:nibIsVisibleKey];
}

@end
