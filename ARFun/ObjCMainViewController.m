//
//  ObjCMainViewController.m
//  Places
//
//  Created by Adrian McGee on 19/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

#import "ObjCMainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import "ARFun-Swift.h"

@interface ObjCMainViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) BOOL vcPresented;
@property (weak, nonatomic)  MKMapView *mapView;

@end

@implementation ObjCMainViewController

- (void)viewDidLoad {
  [super viewDidLoad];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _locationManager = [[CLLocationManager alloc] init];

    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager startUpdatingLocation];


    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;

    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                [self performSelectorOnMainThread:@selector(motionUpdated:)
                                                                       withObject:motion
                                                                    waitUntilDone:NO];
                                            }];
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *lastLocation = [locations lastObject];

  CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];

  //NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
}



-(void)motionUpdated:(CMDeviceMotion *)motion{

      CMAcceleration gravity = self.motionManager.deviceMotion.gravity;

      if(gravity.y <= -0.7){



          if(!self.vcPresented){
              self.vcPresented = YES;
              [self cameraButtonTapped:self];
          }
      }else{

         [self dismissViewControllerAnimated:YES completion:nil];
          self.vcPresented = NO;
          [self.locationManager startUpdatingLocation];

      }


}
- (IBAction)cameraButtonTapped:(id)sender {

    if(self.locationManager){
        //    ARViewController *arViewController = [ARViewController newInstance];
        ARViewController *arViewController = [[ARViewController alloc] init];

        //arViewController = ARViewController()
        arViewController.dataSource = self;
        arViewController.maxDistance = 0;
        arViewController.maxVisibleAnnotations = 30;
        arViewController.maxVerticalLevel = 5;
        arViewController.headingSmoothingFactor = 0.05;

        //Calculate a nearby coordinate for demo marker
        double meters = 50;
        double coef = meters * 0.0000089;
        double new_lat = self.locationManager.location.coordinate.latitude + coef;
        double new_long = self.locationManager.location.coordinate.longitude + coef / cos(self.locationManager.location.coordinate.latitude * 0.018);

        CLLocation *location = [[CLLocation alloc] initWithLatitude:new_lat longitude:new_long];


        CLLocationCoordinate2D locationCoordinate2D;
        locationCoordinate2D.latitude = location.coordinate.latitude;
        locationCoordinate2D.longitude = location.coordinate.longitude;

        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithLocation:locationCoordinate2D title:@"test"];

        Place *place = [[Place alloc] initWithLocation:location reference:nil name:@"Hi" address:nil];

        NSArray *array = [NSArray arrayWithObject:place];
        [arViewController setAnnotations:array];
        arViewController.debugEnabled = NO;
        //arViewController.closeButton.enabled = YES;

        //    arViewController.uiOptions.debugEnabled = false;
        //    arViewController.uiOptions.closeButtonEnabled = true;

        [self presentViewController:arViewController animated:YES completion:nil];
    }
    else{
        NSLog(@"No location");
    }
    }



- (ARAnnotationView *)ar:(ARViewController *)arViewController viewForAnnotation:(ARAnnotation *)viewForAnnotation {
    AnnotationView *annotationView = [[AnnotationView alloc] init];
  annotationView.annotation = viewForAnnotation;
  //annotationView.delegate = self;

    double distanceFromMarker = annotationView.annotation.distanceFromUser;

    if(distanceFromMarker <= 100){

        annotationView.frame = CGRectMake(0, 0, self.view.frame.size.width - 50, self.view.frame.size.height - 50);


        return annotationView;
    } else{
        NSLog(@"Marker too far away");
      return nil;
    }

}

@end
