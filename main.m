//
//  main.m
//  spires
//
//  Created by Yuji on 08/10/13.
//  Copyright Y. Tachikawa 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpiresPredicateTransformer.h"

int main(int argc, char *argv[])
{
    [NSValueTransformer setValueTransformer:
     [[SpiresPredicateTransformer alloc] init]
				    forName:@"SpiresPredicateTransformer"];    
    
    return NSApplicationMain(argc,  (const char **) argv);
}
