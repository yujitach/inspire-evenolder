//
//  AppChooser.m
//  spires
//
//  Created by Yuji on 09/01/31.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "AppChooser.h"


@implementation AppChooser
-(NSMenuItem*)menuItemForApp:(NSString*)bundleId
{
//    NSLog(@"bundleId:%@",bundleId);
    NSWorkspace* ws=[NSWorkspace sharedWorkspace];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString*path=[ws absolutePathForAppBundleWithIdentifier:bundleId];
//    NSLog(@"atPath:%@",path);
    if(!path)
	return nil;
    NSMenuItem* mi=[[NSMenuItem alloc] init];
    NSImage* icon=[ws iconForFile:path];
//    float f=[NSFont systemFontSize];
    float f=16;
    [icon setSize:NSMakeSize(f,f)  ];
    NSString*s=[fm displayNameAtPath:path];
//    NSLog(@"displayName:%@",s);
    if(!s)
	return nil;
    if([s hasSuffix:@".app"]){
	s=[s stringByDeletingPathExtension];
    }
    
    [mi setTitle:s];
    [mi setImage:icon];
    return [mi autorelease];
}
-(NSUInteger)indexForBundleId:(NSString*)bundleId
{
    for(int i=0;i<[apps count];i++){
	if([[apps objectAtIndex:i] compare:bundleId options:NSCaseInsensitiveSearch]==NSOrderedSame){
	    return i;
	}
    }
    return NSNotFound;
}
-(void)awakeFromNib{
    apps=[[NSMutableArray alloc] init];
    NSMenu* menuForApps=[[NSMenu alloc] init];

    {
	NSArray* a=NSMakeCollectable(LSCopyAllRoleHandlersForContentType(kUTTypePDF,kLSRolesAll));
	
	for(NSString* bundleId in a){
	    NSMenuItem* mi=[self menuItemForApp:bundleId];
	    if(!mi)continue;
	    [apps addObject:bundleId];
	    [menuForApps addItem:mi];
	}
    }
    
    {
	NSArray* a=NSMakeCollectable(LSCopyAllHandlersForURLScheme((CFStringRef)@"http"));
	
	for(NSString* bundleId in a){
	    NSMenuItem* mi=[self menuItemForApp:bundleId];
	    if(!mi)continue;
	    [apps addObject:bundleId];
	    [menuForApps addItem:mi];
	}
    }
    
    defaultsKey=[[appToUsePopUp itemAtIndex:0] title];
    NSURL*url;
    LSGetApplicationForInfo(0,0,(CFStringRef)@"pdf",kLSRolesAll,NULL,(CFURLRef*)&url);
    NSString*defaultBundleId=[[NSBundle bundleWithPath:[url path]] bundleIdentifier];
    NSString*chosenId=[[NSUserDefaults standardUserDefaults] stringForKey:defaultsKey];
//    NSLog(@"defaultBundleId:%@",defaultBundleId);
//    NSLog(@"chosenId:%@",chosenId);
    if(!chosenId || [chosenId isEqualToString:@""]){
	chosenId=defaultBundleId;
    }
//    NSLog(@"chosenIdTryAgain:%@",chosenId);
    NSUInteger i=[self indexForBundleId:chosenId];
//    NSLog(@"foundAt:%d",i);
    if(i==NSNotFound){
	// lest default database contains pdf viewer which was later deleted from the machine
//	NSLog(@"notFound");
	chosenId=defaultBundleId;
	i=[self indexForBundleId:chosenId];
//	NSLog(@"finally? %d",i);
//	NSLog(@"apps:%@",apps);
    }
    [appToUsePopUp setMenu:menuForApps];
    [appToUsePopUp selectItemAtIndex:i];
    [self appSelected:self];
}
-(IBAction)appSelected:(id)sender
{
    int i=[appToUsePopUp indexOfSelectedItem];
    NSString* bundleId=[apps objectAtIndex:i];
    [[NSUserDefaults standardUserDefaults] setObject:bundleId forKey:defaultsKey];
    
}
@end
