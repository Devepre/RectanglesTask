//
//  RectanglesStore.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "RectanglesStore.h"
#import "Rectangle.h"

@interface RectanglesStore()

@property(strong, nonatomic) NSMutableArray<Rectangle *> *dataSource;

@end

@implementation RectanglesStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}


- (Rectangle *)getRectangleForPoint:(CGPoint)point {
    Rectangle *result = nil;
    
    // Since objects added like FIFO mode
    // need to iterate from the end of souce
    NSUInteger lastIndex = [self.dataSource count] - 1;
    for (int i = lastIndex; i >= 0; i--) {
        Rectangle *rectangle = [self.dataSource objectAtIndex:i];
        if ([rectangle includePoint:point]) {
            result = rectangle;
            break;
        }
    }

    return result;
}


- (NSUInteger)getIndexForRectangle:(Rectangle *)rectangle {
    if (!rectangle) {
        return 0; // should be an error
    }
    NSUInteger index = [self.dataSource indexOfObject:rectangle];
    return index;
}


- (NSArray *)getAllRectangles {
    // Returning immutable array of objects
    return [self.dataSource copy];
}


#pragma mark - Delegate-drive methods

- (Rectangle *)addRectangleForStartPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint {
    CGFloat width = endPoint.x - startPoint.x;
    CGFloat height = endPoint.y - startPoint.y;
    Rectangle *newRectangle = [[Rectangle alloc] initWithTopPoint:startPoint
                                                            Width:width
                                                           Height:height];
    if (!newRectangle) {
        NSLog(@"Can't create rectangle");
        return nil;
    }
    
    [self addRectangle:newRectangle];
    NSLog(@"Created rectangle is: %@", newRectangle);
    
    NSUInteger newRectangleDataSourceIndex = [self.dataSource indexOfObject:newRectangle];
    [self.delegate addedRectangle:(Rectangle *)newRectangle
                          atIndex:newRectangleDataSourceIndex
                         /*animated:YES*/];
    
    return newRectangle;
}


- (void)rectangleForPoint:(CGPoint)point changeColorTo:(UIColor *)color {
    Rectangle *currentRectangle = [self getRectangleForPoint:point];
    NSUInteger index = [self.dataSource indexOfObject:currentRectangle];
    currentRectangle.color = color;
    [self.delegate changedRectangle:currentRectangle
                            atIndex:index];
}


- (void)removeRectangleAtPoint:(CGPoint)point {
    Rectangle *currentRectangle = [self getRectangleForPoint:point];
    if (currentRectangle) {
        NSInteger indexForRemovedRectangle = [self removeRectangle:currentRectangle];
        [self.delegate removedRectangle:currentRectangle
                                atIndex:indexForRemovedRectangle];
    }
}


#pragma mark - Private methods

- (void)addRectangle:(Rectangle *)rectangle {
    [self.dataSource addObject:rectangle];
}


- (NSUInteger)removeRectangle:(Rectangle *)rectangle {
    NSUInteger index = [self.dataSource indexOfObject:rectangle];
//    [self.dataSource removeObject:rectangle];
    // Instead of deleting the object and loosing track of index
    // for other objects - replace the object with dummy
    // it's bad code smell
    Rectangle *dummyRectangle = [[Rectangle alloc] init];
    [self.dataSource setObject:dummyRectangle
            atIndexedSubscript:index];
    return index;
}

@end
