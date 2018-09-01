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
    CGRect untransformedBounds = self.bounds;
    self.transform = CGAffineTransformIdentity;
    CGRect newBounds = CGRectMake(untransformedBounds.origin.x, untransformedBounds.origin.y,
                                  width, height);
    self.bounds = newBounds;
    self.transform = inputTransform;
}

@end
