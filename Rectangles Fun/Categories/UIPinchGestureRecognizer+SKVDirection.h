//
//  UIPinchGestureRecognizer+SKVDirection.h
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/21/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPinchGestureRecognizerOrientation) {
    OrientaionVertical,
    OrientaionHorizontal,
    OrientaionDoiagonal,
};

@interface UIPinchGestureRecognizer (SKVDirection)

- (UIPinchGestureRecognizerOrientation)getDirection;

@end
