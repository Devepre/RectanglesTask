//
//  UIPinchGestureRecognizer+SKVDirection.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/21/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "UIPinchGestureRecognizer+SKVDirection.h"

@implementation UIPinchGestureRecognizer (SKVDirection)

- (UIPinchGestureRecognizerOrientation)getDirection {
    UIPinchGestureRecognizerOrientation orientation = OrientaionDoiagonal;
    if (self.numberOfTouches == 2) {
        CGPoint pointA = [self locationOfTouch:0 inView:self.view];
        CGPoint pointB = [self locationOfTouch:1 inView:self.view];
        
        CGFloat deltaX = ABS(pointA.x - pointB.x);
        CGFloat deltaY = ABS(pointA.y - pointB.y);
        
        CGFloat ratio = deltaX / deltaY;
        
        if (ratio < 0.5) {
            orientation = OrientaionVertical;
        } else if (ratio > 2) {
            orientation = OrientaionHorizontal;
        }
    }
    return orientation;
}

@end
