//
//  ArxivPDFDownloadOperation.m
//  spires
//
//  Created by Yuji on 09/02/07.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "ArxivPDFDownloadOperation.h"
#import "Article.h"
#import "PDFHelper.h"
#import "ProgressIndicatorController.h"
#import "ArxivHelper.h"

@implementation ArxivPDFDownloadOperation

-(ArxivPDFDownloadOperation*)initWithArticle:(Article*)a;
{
    [super init];
    article=a;
    return self;
}

-(void)downloadAlertDidEnd:(NSAlert*)alert code:(int)choice context:(id)ignore
{
    if(choice==NSAlertDefaultReturn){
	[ProgressIndicatorController startAnimation:self];
	[[ArxivHelper sharedHelper] startDownloadPDFforID:article.eprint
						 delegate:self 
					   didEndSelector:@selector(pdfDownloadDidEnd:)];
    }else{
	[self finish];
    }
}

-(void)pdfDownloadDidEnd:(NSDictionary*)dict
{
    BOOL success=[[dict valueForKey:@"success"] boolValue];
    [ProgressIndicatorController stopAnimation:self];
    
    if(success){
	NSData* data=[dict valueForKey:@"pdfData"];
	[data writeToFile:article.pdfPath atomically:NO];
	[self finish];
    }else if([dict objectForKey:@"shouldReloadAfter"]){
	reloadDelay=[dict objectForKey:@"shouldReloadAfter"];
	NSAlert*alert=[NSAlert alertWithMessageText:@"PDF Download"
				      defaultButton:@"OK" 
				    alternateButton:@"Cancel downloading"
					otherButton:nil
			  informativeTextWithFormat:@"arXiv is now generating %@. Retrying in %@ seconds.", article.eprint,reloadDelay];
	[alert beginSheetModalForWindow:[[[NSApplication sharedApplication] delegate]mainWindow]
			  modalDelegate:self 
			 didEndSelector:@selector(retryAlertDidEnd:code:context:)
			    contextInfo:nil];
    }else{//failure
	[self finish];
    }
}
-(void)retryAlertDidEnd:(NSAlert*)alert code:(int)choice context:(void*)ignore
{
    if(choice==NSAlertDefaultReturn){
	NSLog(@"OK, retry in %@ seconds",reloadDelay);
	[self performSelector:@selector(retry) withObject:nil afterDelay:[reloadDelay intValue]];
    }else{
	[self finish];
    }
}

-(void)retry
{
    //    NSLog(@"retry timer fired");
    [ProgressIndicatorController startAnimation:self];
    [[ArxivHelper sharedHelper] startDownloadPDFforID:article.eprint
					     delegate:self 
				       didEndSelector:@selector(pdfDownloadDidEnd:)];
}
-(void)start
{
    self.isExecuting=YES;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"askBeforeDownloadingPDF"]){
	NSAlert*alert=[NSAlert alertWithMessageText:@"PDF Download"
				      defaultButton:@"Download" 
				    alternateButton:@"Cancel"
					otherButton:nil
			  informativeTextWithFormat:@"%@v%@ is not yet downloaded ...", article.eprint,article.version];
	[alert beginSheetModalForWindow:[[[NSApplication sharedApplication] delegate] mainWindow]
			  modalDelegate:self 
			 didEndSelector:@selector(downloadAlertDidEnd:code:context:)
			    contextInfo:nil];
    }else{
	[self downloadAlertDidEnd:nil code:NSAlertDefaultReturn context:nil];
    }
    
}
-(void)cleanupToCancel
{
    [ProgressIndicatorController startAnimation:self];
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"arxiv download for %@",article.eprint];
}

@end
