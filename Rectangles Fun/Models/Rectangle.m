//
//  Rectangle.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "Rectangle.h"
#import "UIColor+SKVRandomColor.h"

@interface Rectangle()

@end

static const CGFloat minSize = 50.f;
static const CGFloat defaultRotation = 0.f;

@implementation Rectangle

- (instancetype)init {
    self = [self initWithTopPoint:CGPointZero
                            Width:minSize
                           Height:minSize
                         rotation:defaultRotation
                            color:UIColor.randomColor];
    return self;
}


- (instancetype)initWithTopPoint:(CGPoint)topPoint
                           Width:(CGFloat)width
                          Height:(CGFloat)heigt {
    self = [self initWithTopPoint:topPoint
                            Width:width
                           Height:heigt
                         rotation:defaultRotation
                            color:UIColor.randomColor];
    return self;
}


- (instancetype)initWithTopPoint:(CGPoint)topPoint
                           Width:(CGFloat)width
                          Height:(CGFloat)heigt
                        rotation:(CGFloat)rotation
                           color:(UIColor *)color {
    if (ABS(width) < minSize || ABS(heigt) < minSize) {
        NSLog(@"Width and height of rectangle can't be less than %f. Requested width:%f height:%f",
              minSize,
              width,
              heigt);
        return nil;
    }
    self = [super init];
    if (self) {
        _topPoint = topPoint;
        _width = width;
        _height = heigt;
        _rotation = rotation;
        _color = color;
    }
    return self;
}


- (CGRect)frame {
    if (_frame.size.width == 0) {
        CGRect frame = CGRectMake(self.topPoint.x,
                                  self.topPoint.y,
                                  self.width,
                                  self.height);
        _frame = frame;
    }
    return _frame;
}


- (BOOL)includePoint:(CGPoint)point {
    return CGRectContainsPoint(self.frame, point);
}


- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"Rectangle:\nTop point: %@\nwidth:%f\nheight:%f\nrotation: %f",
                      NSStringFromCGPoint(self.topPoint),
                      self.width,
                      self.height,
                      self.rotation];
    return desc;
}


#pragma mark - Getters and Setters

- (void)setWidth:(CGFloat)width {
    if (width < minSize) {
        return;
    }
    _width = width;
}


- (void)setHeight:(CGFloat)height {
    if (height < minSize) {
        return;
    }
    _height = height;
}

@end
