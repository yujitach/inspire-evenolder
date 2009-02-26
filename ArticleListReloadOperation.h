//
//  ArxivNewReloadOperation.h
//  spires
//
//  Created by Yuji on 09/02/08.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DumbOperation.h"

@class ArticleList;
@interface ArticleListReloadOperation : DumbOperation {
    ArticleList*list;
}
-(ArticleListReloadOperation*)initWithArticleList:(ArticleList*)l;
@end
