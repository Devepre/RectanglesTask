//
//  RectanglesStore.h
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

@import Foundation;
@import UIKit;
@class Rectangle;
#import "RectangleStoreDelegate.h"

@interface RectanglesStore : NSObject

@property(weak, nonatomic) NSObject<RectangleStoreDelegate> *delegate;

- (NSArray *)getAllRectangles;
- (void)addRectangle:(Rectangle *)rectangle;
- (void)removeRectangleAtPoint:(CGPoint)point;
- (Rectangle *)addRectangleForStartPoint:(CGPoint)startPoint
                         endPoint:(CGPoint)endPoint;
- (Rectangle *)getRectangleForPoint:(CGPoint)point;
- (void)rectangleForPoint:(CGPoint)point
            changeColorTo:(UIColor *)color;
- (NSUInteger)getIndexForRectangle:(Rectangle *)rectangle;

@end
