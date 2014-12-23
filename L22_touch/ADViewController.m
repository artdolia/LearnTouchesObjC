//
//  ADViewController.m
//  L22_touch
//
//  Created by A D on 1/9/14.
//  Copyright (c) 2014 AD. All rights reserved.
//

#import "ADViewController.h"

typedef enum{
    ADViewTypeBlackCell             = 1 << 0,
    ADViewTypeWhiteCell             = 1 << 1,
    ADViewTypeWhiteChecker          = 1 << 2,
    ADViewTypeRedChecker            = 1 << 3,
    ADViewTypeBlackCellWithChecker  = 1 << 4
}ADViewType;

@interface ADViewController ()

@property (weak, nonatomic) UIView *touchedView;
@property (assign,nonatomic) CGPoint touchOffset;

@property (weak, nonatomic) UIView *board;

@end

@implementation ADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.multipleTouchEnabled = YES;
    UIImage *blackCell = [UIImage imageNamed:@"BlackCell.png"];
    UIImage *whiteCell = [UIImage imageNamed:@"WhiteCell.png"];
    UIImage *whiteChecker = [UIImage imageNamed:@"YellowChecker.png"];
    UIImage *redChecker = [UIImage imageNamed:@"RedChecker.png"];
    
    NSInteger viewWidth = CGRectGetWidth(self.view.bounds);
    NSInteger viewHeight = CGRectGetHeight(self.view.bounds);
    
    NSInteger boardSide = MIN(viewHeight, viewWidth);
    NSInteger cellSide = boardSide/8.0f;
    
    UIView *board = [[UIView alloc] initWithFrame:CGRectMake(viewHeight > viewWidth ? 0 : (viewWidth - viewHeight)/2,
                                                          viewHeight < viewWidth ? 0 : (viewHeight - viewWidth)/2,
                                                          boardSide, boardSide)];
    
    board.backgroundColor = [UIColor grayColor];
    
    board.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview:board];
    
    self.board = board;
    
    NSInteger boardOriginCoordX = CGRectGetMinX(board.bounds);
    NSInteger boardOriginCoordY = CGRectGetMinY(board.bounds);

    
    for(int i = 0; i < 8; i++){
        for(int j = 0; j < 8; j++){
            
            CGRect viewRect = CGRectMake(boardOriginCoordX+(j*cellSide), boardOriginCoordY+(i*cellSide), cellSide, cellSide);
            
            if ((i%2==0 && j%2==1) || (i%2==1 && j%2==0)) {
                

                
                UIView *blackCellView = [self makeCellViewWithFrame:viewRect andImage:blackCell andParentView:self.board andTag:ADViewTypeBlackCell];
                
                //NSLog(@"BlackViewOrigin = %@, tag = %d", NSStringFromCGPoint(blackCellView.frame.origin), blackCellView.tag);
                
                if(i < 3){
                    
                    [self makeCellViewWithFrame:CGRectMake(CGRectGetMinX(blackCellView.bounds)+5, CGRectGetMinY(blackCellView.bounds)+5, CGRectGetMaxX(blackCellView.bounds)-10, CGRectGetMaxY(blackCellView.bounds)-10) andImage:redChecker andParentView:blackCellView andTag:ADViewTypeRedChecker];
                    
                    blackCellView.tag += ADViewTypeBlackCellWithChecker;
                    //NSLog(@"BlackViewOrigin = %@, tag = %d", NSStringFromCGPoint(blackCellView.frame.origin), blackCellView.tag);
                    
                }else if(i > 4){
                    
                    [self makeCellViewWithFrame:CGRectMake(CGRectGetMinX(blackCellView.bounds)+5, CGRectGetMinY(blackCellView.bounds)+5, CGRectGetMaxX(blackCellView.bounds)-10, CGRectGetMaxY(blackCellView.bounds)-10) andImage:whiteChecker andParentView:blackCellView andTag:ADViewTypeWhiteChecker];
                    
                    blackCellView.tag += ADViewTypeBlackCellWithChecker;
                    //NSLog(@"BlackViewOrigin = %@, tag = %d", NSStringFromCGPoint(blackCellView.frame.origin), blackCellView.tag);
                }
                
            }else{ //white cell
                
                [self makeCellViewWithFrame:viewRect andImage:whiteCell andParentView:board andTag:ADViewTypeWhiteCell];
            }
        }
    }
}


#pragma mark - makeVew -
- (UIView*) makeCellViewWithFrame:(CGRect)frame andImage:(UIImage *)image andParentView:(UIView *)parent andTag:(NSInteger)tag {
    
    UIView *view = [[UIView alloc] init];
    [view setFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.alpha = 1.0f;
    view.tag = tag;
    [parent addSubview:view];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    [imageView setFrame:CGRectMake(CGRectGetMinX(view.bounds), CGRectGetMinY(view.bounds),CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds))];
    imageView.tag = tag;
    imageView.alpha = 1.0f;
    [view addSubview:imageView];
    
    [view bringSubviewToFront:imageView];
    
    //NSLog(@"iv = %@, ivt = %d, v = %@, vt = %d", NSStringFromCGPoint(imageView.frame.origin), imageView.tag, NSStringFromCGPoint(view.frame.origin), view.tag);
    
    
    return view;
}


#pragma mark - Touches -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self.view];
    
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:event];
    
    NSLog(@"tp = %@, viewCs = %@ tag = %ld", NSStringFromCGPoint(touchPoint), NSStringFromCGPoint(touchedView.frame.origin), (long)touchedView.tag);

    if(touchedView.tag == ADViewTypeWhiteChecker || touchedView.tag == ADViewTypeRedChecker){
        
        self.touchedView = touchedView;
        
        self.touchOffset = CGPointMake(CGRectGetMidX(self.touchedView.bounds) - touchPoint.x,
                                          CGRectGetMidY(self.touchedView.bounds) - touchPoint.y);
        
        self.touchedView.superview.tag = self.touchedView.superview.tag & ~ ADViewTypeBlackCellWithChecker;
        
        [self.board bringSubviewToFront:self.touchedView.superview];
        
        
        
        [self animateView:self.touchedView
             withDuration:0.3
      andTransformOptions:CGAffineTransformMakeScale(2.0f, 2.0f)
                 andAlpha:0.5f];
        
    }else{
                
        self.touchedView = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self.view];
    

    
    CGPoint correction = CGPointMake(touchPoint.x + self.touchOffset.x,
                                     touchPoint.y + self.touchOffset.y);
    
    self.touchedView.center = correction;
    
    //NSLog(@"moving = %@", NSStringFromCGPoint(self.touchedView.center) );
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self dropDownAnimation];

}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self dropDownAnimation];

    
}


#pragma mark - Animation -
-(void) dropDownAnimation{
    
    CGFloat minDist = (float)(NSIntegerMax);
    UIView *closestView = nil;
    
    
    for (UIView *view in self.board.subviews){

        if(view.tag == ADViewTypeBlackCell && self.touchedView != nil){
            
            CGPoint touchedToBoard = [self.board convertPoint:self.touchedView.center fromView:self.touchedView.superview];
            
            CGFloat distance = [self distanceBetweenPointOne:view.center andPointTwo:touchedToBoard];
            
            if (distance < minDist){
             
                minDist = distance;
                closestView = view;
            }
        }
    }
    
    closestView.tag = closestView.tag + ADViewTypeBlackCellWithChecker;
    NSLog(@"CVT = %ld", (long)closestView.tag);
    self.touchedView.superview.tag = self.touchedView.superview.tag &~ADViewTypeBlackCellWithChecker;
    
    CGPoint converted = [self.board convertPoint:closestView.center toView:self.touchedView.superview];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.touchedView.center = converted;
        self.touchedView.transform = CGAffineTransformIdentity;
        self.touchedView.alpha = 1.0f;
        
    }];
    
    //self.touchedView.center = converted;
    //[self.touchedView removeFromSuperview];
    //closestView addSubview:self.touchedView];
    //[closestView bringSubviewToFront:self.touchedView];
    self.touchedView = nil;
}


- (void) animateView:(UIView *)view withDuration:(CGFloat)duration andTransformOptions:(CGAffineTransform)transformOpts andAlpha:(CGFloat)alpha{
    
    [UIView animateWithDuration:duration animations:^{
        view.transform = transformOpts;
        view.alpha = alpha;
    }];
}

- (CGFloat) distanceBetweenPointOne:(CGPoint)firstPoiont andPointTwo:(CGPoint)secondPoint{
    
    CGFloat width = MAX(firstPoiont.x, secondPoint.x) - MIN(firstPoiont.x, secondPoint.x);
    CGFloat height = MAX(firstPoiont.y, secondPoint.y) - MIN(firstPoiont.y, secondPoint.y);
    
    return sqrtf(powf(width, 2) + powf(height, 2));
}


@end
