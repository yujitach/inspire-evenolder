//
//  DumbOperations.m
//  spires
//
//  Created by Yuji on 09/02/07.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "DumbOperation.h"


@implementation DumbOperation
@synthesize finished;
@synthesize queue;
-(void)main
{
}
-(BOOL)wantToRunOnMainThread;
{
    return YES;
}
-(void)finish
{
    self.finished=YES;
}
@end

static DumbOperationQueue*_queue=nil;
static DumbOperationQueue*_Squeue=nil;

@implementation DumbOperationQueue
+(DumbOperationQueue*)sharedQueue;
{
    if(!_queue){
	_queue=[[DumbOperationQueue alloc] init];
    }
    return _queue;
}
+(DumbOperationQueue*)spiresQueue;
{
    if(!_Squeue){
	_Squeue=[[DumbOperationQueue alloc] init];
    }
    return _Squeue;
}
-(DumbOperationQueue*)init
{
    [super init];
    operations=[NSMutableArray array];
    return self;
}
-(NSArray*)operations
{
    return operations;
}
-(void)runIfAny
{
    if(!running && [operations count]>0){
	DumbOperation* op=[operations objectAtIndex:0];
	NSLog(@"runs:%@",op);
	[op addObserver:self
	     forKeyPath:@"finished" 
		options:NSKeyValueObservingOptionNew
		context:nil];
	running=YES;
	if([op wantToRunOnMainThread]){
	    [op main];
	}else{
	    [NSThread detachNewThreadSelector:@selector(main) toTarget:op withObject:nil];
	}
    }
}
-(void)done
{
    DumbOperation*op=[operations objectAtIndex:0];
    [op removeObserver:self
	    forKeyPath:@"finished"];
//    NSLog(@"%p finished %@",op,op);
//    [self willChangeValueForKey:@"operations"];
    [operations removeObject:op];
//    [self didChangeValueForKey:@"operations"];
    running=NO;
    [self runIfAny];
}
-(void)addOperation:(DumbOperation*)op;
{
    if(![[NSThread currentThread] isMainThread]){
	[self performSelectorOnMainThread:@selector(addOperation:) withObject:op waitUntilDone:NO];
	return;
    }
//    [self willChangeValueForKey:@"operations"];
    [operations addObject:op];
    [op setQueue:self];
//    [self didChangeValueForKey:@"operations"];
//    NSLog(@"queued operation %@",op);
    [self runIfAny];
}
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(DumbOperation*)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"finished"] && object.finished){
	[self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
    }
}
@end