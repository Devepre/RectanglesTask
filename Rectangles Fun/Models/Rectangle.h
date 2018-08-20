//
//  Rectangle.h
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface Rectangle : NSObject

@property (assign, nonatomic) CGPoint topPoint;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat rotation;
@property (strong, nonatomic) UIColor *color;

@property (assign, nonatomic) CGRect frame;

- (instancetype)initWithTopPoint:(CGPoint)topPoint
                           Width:(CGFloat)width
                          Height:(CGFloat)heigt
                        rotation:(CGFloat)rotation
                           color:(UIColor *)color NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTopPoint:(CGPoint)topPoint
                           Width:(CGFloat)width
                          Height:(CGFloat)heigt;
- (instancetype)init;

- (BOOL)includePoint:(CGPoint)point;

@end
