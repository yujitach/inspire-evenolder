//
//  SideTableViewController.h
//  spires
//
//  Created by Yuji on 08/10/25.
//  Copyright 2008 Y. Tachikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@class spires_AppDelegate;
@class ArticleList;
@class AllArticleList;
@interface SideOutlineViewController : NSObject {
    IBOutlet NSTreeController* articleListController;
    IBOutlet NSOutlineView* articleListView;
//    IBOutlet spires_AppDelegate* appDelegate;
    AllArticleList*allArticleList;
    
}
-(void)rearrangePositionInViewForArticleLists;
-(ArticleList*)currentArticleList;
-(void)addArticleList:(ArticleList*)al;
//-(void)removeArticleList:(ArticleList*)al;
-(void)removeCurrentArticleList;
-(void)selectAllArticleList;
-(void)selectArticleList:(ArticleList*)al;
@end
