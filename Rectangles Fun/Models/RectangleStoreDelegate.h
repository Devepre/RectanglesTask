//
//  RectangleStoreDelegate.h
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RectangleStoreDelegate

@required
- (void)addedRectangle:(Rectangle *)rectangle atIndex:(NSUInteger)index;
- (void)changedRectangle:(Rectangle *)rectangle atIndex:(NSUInteger)index;
- (void)removedRectangle:(Rectangle *)rectangle atIndex:(NSUInteger)index;

@end
