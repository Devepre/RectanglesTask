//
//  RectangleView.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/21/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "RectangleView.h"

@implementation RectangleView

- (void)setWidth:(CGFloat)width
          height:(CGFloat)height {
    CGAffineTransform inputTransform = self.transform;
    CGRect untransformedFrame = [self getUntransformedFrame];
    self.transform = CGAffineTransformIdentity;
    // FIXME: origin should be changed more intellectually
    CGRect newFrame = CGRectMake(untransformedFrame.origin.x, untransformedFrame.origin.y,
                                 width, height);
    self.frame = newFrame;
    self.transform = inputTransform;
}


- (CGRect)getUntransformedFrame {
    CGAffineTransform inputTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect result = self.frame;
    self.transform = inputTransform;
    
    return result;
}

@end
