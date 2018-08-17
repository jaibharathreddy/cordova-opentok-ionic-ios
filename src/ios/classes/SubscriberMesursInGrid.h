//
//  SubscriberMesursInGrid.h
//  Fitbase
//
//  Created by Jayabharath on 25/07/18.
//


#import <Foundation/Foundation.h>

@interface SubscriberMesursInGrid:NSObject{
    int  indexNumber;
    double xAxis;
    double yAxis;
    double width;
    double height;
    NSString *connectionId;
}

@property(nonatomic,readwrite) int indexNumber;
@property(nonatomic,readwrite) double xAxis;
@property(nonatomic,readwrite) double yAxis;
@property(nonatomic,readwrite) double width;
@property(nonatomic,readwrite) double height;
@property(nonatomic,readwrite) NSString *conncetionId;

@end

