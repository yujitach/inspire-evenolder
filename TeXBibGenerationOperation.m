//
//  TeXBibGenerationOperation.m
//  spires
//
//  Created by Yuji on 09/02/07.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "TeXBibGenerationOperation.h"
#import "Article.h"
#import "SimpleArticleList.h"
#import "SideTableViewController.h"
#import "RegexKitLite.h"
#import "SpiresHelper.h"
#import "SpiresQueryOperation.h"
#import "ProgressIndicatorController.h"
#import "BatchBibQueryOperation.h"
#import "NSString+magic.h"

@implementation TeXBibGenerationOperation
-(TeXBibGenerationOperation*)initWithTeXFile:(NSString*)t andMOC:(NSManagedObjectContext*)m byLookingUpWeb:(BOOL)b;
{
    [super init];
    texFile=t;
    moc=m;
    twice=b;
    return self;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"tex bib generation:%@",texFile];
}
-(void)generateLookUps:(NSArray*)array
{

    for(NSString*idToLookUp in array){
	NSString*query=nil;
	if([idToLookUp hasPrefix:@"arXiv:"]){
	    idToLookUp=[idToLookUp substringFromIndex:[@"arXiv:" length]];
	    query=[NSString stringWithFormat:@"eprint %@",idToLookUp];
	}else if([idToLookUp rangeOfString:@"."].location!=NSNotFound){
	    query=[NSString stringWithFormat:@"eprint %@",idToLookUp];	
	}else if([idToLookUp rangeOfString:@"/"].location!=NSNotFound){
	    query=[NSString stringWithFormat:@"eprint %@",idToLookUp];	
	}else if([idToLookUp rangeOfString:@":"].location!=NSNotFound){
	    query=[NSString stringWithFormat:@"texkey %@",idToLookUp];
	}else{
	    query=@"eprint 0808.0808"; // shouldn't happen
	}
	[[DumbOperationQueue spiresQueue] addOperation:[[SpiresQueryOperation alloc] initWithQuery:query 
											    andMOC:moc]];
    }
    
    if(twice){
	[[DumbOperationQueue spiresQueue] performSelector:@selector(addOperation:)
					       withObject:[[TeXBibGenerationOperation alloc] initWithTeXFile:texFile 
												      andMOC:moc
											      byLookingUpWeb:NO]
					       afterDelay:20];
    }
    
}


-(void)main
{

    
    NSString*script=[[NSBundle mainBundle] pathForResource:@"parseTeXandEmitPlist" ofType:@"perl"];
    NSString*line=[NSString stringWithFormat:@"/usr/bin/perl '%@' <'%@' >/tmp/spiresoutput.plist",
		   [script stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"],
		   [texFile stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
    system([line UTF8String]);
    NSDictionary* dict=[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:@"/tmp/spiresoutput.plist"]
							mutabilityOption:NSPropertyListImmutable
								  format:NULL
							errorDescription:NULL];
    NSArray* citations=[dict objectForKey:@"citationsInOrder"];
    NSDictionary* definitions=[dict objectForKey:@"definitions"];
    NSDictionary* mappings=[dict objectForKey:@"mappings"];
    NSString* listName=[dict objectForKey:@"listName"];
    SimpleArticleList*list=nil;
    if(listName&&![listName isEqualToString:@""]){
	list=[SimpleArticleList simpleArticleListWithName:listName inMOC:moc];
	if(list){
	    [[[NSApplication sharedApplication]delegate] rearrangePositionInViewForArticleLists];
	}
    }
    NSString* output=[dict objectForKey:@"outputFile"];
    if(!output || [output isEqualToString:@""]){
	output=@"bibliography.tex";
    }
    if(![output hasSuffix:@".tex"]){
	output=[output stringByAppendingString:@".tex"];
    }
    NSString* outputPath=[[texFile stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@",output];
    NSLog(@"outputPath:%@",outputPath);
    NSMutableString* result=[NSMutableString stringWithString:@"%This file is autogenerated. Do not edit.\n\n"];
    NSMutableArray* notFound=[NSMutableArray array];
    for(NSString*key in citations){
	[result appendFormat:@"\\bibitem{%@}\n",key];
	NSString*def=[definitions objectForKey:key];
	if(def){
	    [result appendFormat:@"%@\n",def];
	    continue;
	}
	NSString*idToLookUp=key;
	NSString*head=key;
	NSString*map=[mappings objectForKey:key];
	if(map){
	    idToLookUp=map;
	    head=[head stringByAppendingFormat:@" = %@",idToLookUp];
	}
	NSString*notFoundString=[NSString stringWithFormat:@" %@ not yet found in database -- will be updated in a minuite\n",head];
	Article*a=[Article intelligentlyFindArticleWithId:idToLookUp inMOC:moc];
	if(!a){
	    [notFound addObject:idToLookUp];
	    [result appendString:notFoundString];
	}else{
	    if(list){
		[list addArticlesObject:a];
	    }
	    NSString* bib=nil;
	    if(bib=[a extraForKey:@"latex"]){
		bib=[bib stringByReplacingOccurrencesOfRegex:@"%\\\\cite.+?\n" withString:@""];
		bib=[bib stringByReplacingOccurrencesOfRegex:@"\\\\bibitem.+?\n" withString:@""];
		[result appendString:bib];
	    }else{
		[notFound addObject:idToLookUp];
		[result appendString:notFoundString];
	    }
	}
    }
    if([notFound count]>0){
	[self generateLookUps:notFound];
    }
    
    
    
    [[result magicTeXed] writeToFile:outputPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [self finish];
}

@end
