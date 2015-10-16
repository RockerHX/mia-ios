//
//  HXWaveView.m
//  mia
//
//  Created by miaios on 15/10/14.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import "HXWaveView.h"

@implementation HXWaveView {
    BOOL _increase;
    CGFloat _vibrationAmplitudeMin;
    CGFloat _vibrationAmplitudeMax;
    
    CADisplayLink *_link;
}

#pragma mark - Init Methods
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initConfig];
        [self viewConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
        [self viewConfig];
    }
    return self;
}

#pragma mark - Draw Methods
static CGFloat Zero = 0.0f;
static CGFloat LineWidth = 1.0f;
- (void)drawRect:(CGRect)rect {
    
    CGFloat width = rect.size.width;
    // Light Color Wave
    CGContextRef lightColorContext = UIGraphicsGetCurrentContext();
    CGMutablePathRef lightColorPath = CGPathCreateMutable();
    
    CGContextSetLineWidth(lightColorContext, LineWidth);
    CGContextSetFillColorWithColor(lightColorContext, [[UIColor colorWithCGColor:[self.tintColor CGColor]] colorWithAlphaComponent:0.5f].CGColor);
    
    CGFloat lightLineY = _offsetY;
    CGPathMoveToPoint(lightColorPath, nil, Zero, lightLineY);
    for (CGFloat x = -(width/2); x <= width*1.5 ; x++) {
        lightLineY = (_attenuation ? _vibrationAmplitudeMin : _vibrationAmplitude) * sin(x/180.0f*M_PI + 6.0f*_vibrationAmplitudeMax/M_PI) * 3.0f + _offsetY;
        CGPathAddLineToPoint(lightColorPath, nil, x, lightLineY);
    }
    
    CGPathAddLineToPoint(lightColorPath, nil, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(lightColorPath, nil, Zero, rect.size.height);
    CGPathAddLineToPoint(lightColorPath, nil, Zero, _offsetY);
    
    CGContextAddPath(lightColorContext, lightColorPath);
    CGContextFillPath(lightColorContext);
    CGContextDrawPath(lightColorContext, kCGPathStroke);
    CGPathRelease(lightColorPath);
    
    // Primary Color Wave
    CGContextRef primaryColorContext = UIGraphicsGetCurrentContext();
    CGMutablePathRef primaryColorPath = CGPathCreateMutable();
    
    CGContextSetLineWidth(primaryColorContext, LineWidth);
    CGContextSetFillColorWithColor(primaryColorContext, [self.tintColor CGColor]);
    
    CGFloat primaryLineY = _offsetY;
    CGPathMoveToPoint(primaryColorPath, nil, Zero, primaryLineY);
    for (CGFloat x = Zero; x <= width ; x++) {
        primaryLineY = (_attenuation ? _vibrationAmplitudeMin : _vibrationAmplitude) * sin(x/180.0f*M_PI + _speed*_vibrationAmplitudeMax/M_PI) * 5.0f + _offsetY;
        CGPathAddLineToPoint(primaryColorPath, nil, x, primaryLineY);
    }
    
    CGPathAddLineToPoint(primaryColorPath, nil, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(primaryColorPath, nil, Zero, rect.size.height);
    CGPathAddLineToPoint(primaryColorPath, nil, Zero, _offsetY);
    
    CGContextAddPath(primaryColorContext, primaryColorPath);
    CGContextFillPath(primaryColorContext);
    CGContextDrawPath(primaryColorContext, kCGPathStroke);
    CGPathRelease(primaryColorPath);
}

#pragma mark - Config Methods
- (void)initConfig {
    _vibrationAmplitude = M_PI;
    _link = [self setUpLink];
    
    _speed = 4.0f;
    self.percent = 0.5f;
}

- (void)viewConfig {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (CADisplayLink *)setUpLink {
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateWave)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    link.paused = YES;
    return link;
}

#pragma mark - Event Response
- (void)animateWave {
    if (_attenuation) {
        if (_increase) {
            _vibrationAmplitudeMin += 0.01f;
        } else {
            _vibrationAmplitudeMin -= 0.01f;
        }
        
        if (_vibrationAmplitudeMin <= 1.0f) {
            _increase = YES;
        } else if (_vibrationAmplitudeMin >= _vibrationAmplitude) {
            _increase = NO;
        }
    }
    
    _vibrationAmplitudeMax += 0.1f;
    
    [self setNeedsDisplay];
}

#pragma mark - Public Methods
- (void)startAnimating {
    _link.paused = NO;
}

- (void)stopAnimating {
    _link.paused = YES;
}

- (void)reset {
    _vibrationAmplitudeMin = 0.0f;
    _vibrationAmplitudeMax = 0.0f;
    [self setNeedsDisplay];
}

#pragma mark - Setter And Getter
- (void)setPercent:(CGFloat)percent {
    _percent = percent;
    CGFloat screenHeight = self.frame.size.height;
    _offsetY = screenHeight * percent;
}

@end
