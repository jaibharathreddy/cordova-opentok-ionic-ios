//
//  LiveViewController.m
//  Fitbase Trainer
//
//  Created by Bharath on 28/12/17.
//

#import "LiveViewController.h"
#import "NSDictionary+Safety.h"
#import "SubscriberMesursInGrid.h"
#import <UIKit/UIKit.h>
#define APP_IN_FULL_SCREEN @"appInFullScreenMode"

static NSString *const kApiKey = @"46033242";
// Replace with your generated session ID
static NSString *const kSessionId = @"2_MX40NjAzMzI0Mn5-MTUxNTE1OTI1MTgxNX41TVVVWjBaVXRIRHNqZGJUaWoxY0ZjNDB-fg";
// Replace with your generated token
static NSString *const kToken = @"T1==cGFydG5lcl9pZD00NjAzMzI0MiZzaWc9N2VmNmYzNTViMTEyNzFjN2E0YTc0ZGI2YzIyOTE4OWZhMjRmYjc1NjpzZXNzaW9uX2lkPTJfTVg0ME5qQXpNekkwTW41LU1UVXhOVEUxT1RJMU1UZ3hOWDQxVFZWVldqQmFWWFJJUkhOcVpHSlVhV294WTBaak5EQi1mZyZjcmVhdGVfdGltZT0xNTE1MjQwODIyJm5vbmNlPTAuMTQzNzU0NTY3OTYyODc1MzMmcm9sZT1tb2RlcmF0b3ImZXhwaXJlX3RpbWU9MTUxNzgzMjgyMSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ==";

@interface LiveViewController ()<OTSessionDelegate, OTSubscriberKitDelegate,
OTPublisherDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    OTSession *_session;
    OTPublisher *_publisher;
    OTSubscriber *_currentSubscriber;
    //BOOL isFullScreen;
}

@property (weak, nonatomic) IBOutlet UIButton *audioBTNOne;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNTwo;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNThree;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNFour;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNFive;


@property (weak, nonatomic) IBOutlet UIButton *menuBTNField;
//@property (weak, nonatomic) IBOutlet UILabel *participantsHeader;
@property (weak, nonatomic) IBOutlet UIButton *muteAllBtnItem;
@property (weak, nonatomic) IBOutlet UIButton *ParticioantsBtnItem;


@property (weak, nonatomic) IBOutlet UIView *publisherView;

@property (strong, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *swapCameraButton;

@property (strong, nonatomic) IBOutlet UIButton *audioSubUnsubButton;
@property (strong, nonatomic) IBOutlet UIButton *videoSubUnsubButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (weak, nonatomic) IBOutlet UIImageView *publisherDeaultImage;



@property (strong, nonatomic) NSTimer *overlayTimer;
@property (nonatomic, strong) UIAlertController *alert;

@property (weak, nonatomic) IBOutlet UILabel *sessionReconnectingMsgLabel;


@property UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *changeViewButton;
@property (weak, nonatomic) IBOutlet UIView *topToolBar;
@property (weak, nonatomic) IBOutlet UIButton *muteUnmuteAllButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollContainerAudioBtn;

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *participantsListSheet;
@property (weak, nonatomic) IBOutlet UIView *muteAllActionSheet;



- (void)showReconnectingAlert;
- (void)dismissReconnectingAlert;
@property (weak, nonatomic) IBOutlet UILabel *timer;
@property (weak, nonatomic) IBOutlet UILabel *messegeForUser;
@property NSMutableDictionary *allSubscribers;//
@property NSMutableDictionary *allSubscribersMesures;//
@property NSMutableDictionary *allSubcribersPresentInRecyclerView;
@property NSMutableDictionary *allStreams;
@property NSMutableDictionary *allSubscribersButtons;
@end

@implementation LiveViewController
NSMutableArray *keys;
double countDownTimerMilliSeconds;
NSString *comingView;
int groupSize;
//NSArray *buttons;
//NSArray *audioButtons;
bool sessionDisconnect=NO;
float initialYaxisScroll;
float afterIconsOnYaxis;
Boolean changeveiw;
bool tapped=YES;
float initalXaxisOfSwapCame;
UIPanGestureRecognizer * pan1 ;
- (void)viewDidLoad {
    [super viewDidLoad];
   // [NSTimer timerWithTimeInterval:1.0 target:self @selector:(getMyFrame) userInfo:nil repeats:NO]
    
   // NSLog(@"---------%f",[[self view] bounds].size.width);
  //  NSLog(@"------------verit1%f");
    initalXaxisOfSwapCame=self.swapCameraButton.frame.origin.x;
    self.swapCameraButton.frame=CGRectMake(self.mainContainerView.frame.size.width-(self.swapCameraButton.frame.size.width+20),self.swapCameraButton.frame.origin.y,50,50);
        // [self beginBackgroundUpdateTask];
        changeveiw=true;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    
        [self requestPermissions];
        [self initialhiddenProperties];
        [self initializeArrays];
        [self setBackgroudForButtonsAndViews];
        [self setSessionCountDownTime];
        [self setupSession];
    
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(enteringBackgroundMode:)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(leavingBackgroundMode:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
     //isFullScreen = NO;
     pan1= [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveObject:)];
     pan1.minimumNumberOfTouches = 1;
     _publisherView.tag=3;
     [_publisherView addGestureRecognizer:pan1];
    
     [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
     [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
     // listen to taps around the screen, and hide/show overlay views
     UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(viewTappedInLive:)];
     tgr.delegate = self;
     self.view.userInteractionEnabled = YES;
     [self.view addGestureRecognizer:tgr];
     [self overlayTimerSetUp];
}//view controller

/*-----setSessionCountDownTime---*/
-(void)setSessionCountDownTime{
    NSLocale* currentLocale = [NSLocale currentLocale];
    [[NSDate date] descriptionWithLocale:currentLocale];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *dateStr  = [self.hybridParams safeObjectForKey:@"startDate"];
    NSString *splitStr = [dateStr componentsSeparatedByString:@"."][0];
    double minuts = [[self.hybridParams safeObjectForKey:@"duration"] doubleValue];
    NSDate *addedDate= [[dateFormatter dateFromString:splitStr] dateByAddingTimeInterval:minuts*60]; //adding duretion to startdate
    NSTimeInterval countDownTimer=[addedDate timeIntervalSince1970];
    countDownTimerMilliSeconds=countDownTimer*1000; // here we are adding milliseconds to countdowntime
    [self countDownTime];
}//setSessionCountDownTime

/*-----initializeArrays-----*/
-(void)initializeArrays{
    _allSubscribers=[[NSMutableDictionary alloc] init];
    _allStreams=[[NSMutableDictionary alloc] init];
    _allSubscribersButtons=[[NSMutableDictionary alloc] init];//storing all buttons
    _allSubscribersMesures=[[NSMutableDictionary alloc] init];
     keys=[[NSMutableArray alloc] init];
    _allSubcribersPresentInRecyclerView=[[NSMutableDictionary alloc] init];
}//initializeArrays

/*------initialhiddenProperties----*/
-(void)initialhiddenProperties{
    [self.publisherView setHidden:YES];
    [self setHiddenAudioButtons:YES];
    [self.publisherDeaultImage setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.changeViewButton setHidden:YES];
    [self.menuBTNField setHidden:YES];
    [self.muteAllActionSheet setHidden:YES];
    [self.participantsListSheet setHidden:YES];
}//initialhiddenProperties

/*-----request to user for Camera and Audio permission-----*/
 -(void)requestPermissions{
   AVAuthorizationStatus _cameraAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
   switch (_cameraAuthorizationStatus){
     case AVAuthorizationStatusNotDetermined:{
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
         if(granted){
            NSLog(@"Granted access to %@", AVMediaTypeVideo);
         }else{
            dispatch_async( dispatch_get_main_queue(), ^{
            [self accessDynamicpermissons:@"camera"];
            });
            NSLog(@"Not granted access to %@", AVMediaTypeVideo);
          // *** Camera access rejected by user, perform respective action ***
        }//if-else
       }];
     }
 break;
 case AVAuthorizationStatusRestricted:
 case AVAuthorizationStatusDenied:
 {
 // Prompt for not authorized message & provide option to navigate to settings of app.
 dispatch_async( dispatch_get_main_queue(), ^{
 [self accessDynamicpermissons:@"camera"];
 });
 }
 break;
 default:
 break;
 }
 
 AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
 
 switch (permissionStatus) {
 case AVAudioSessionRecordPermissionUndetermined:{
 [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
 // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
 if (granted) {
 
 }
 else {
 // Microphone disabled code
 dispatch_async( dispatch_get_main_queue(), ^{
 [self accessDynamicpermissons:@"Microphone"];
 });
 }
 }];
 break;
 }
 case AVAudioSessionRecordPermissionDenied:{
 dispatch_async( dispatch_get_main_queue(), ^{
 [self accessDynamicpermissons:@"Microphone"];
 });
 break;
 }
 case AVAudioSessionRecordPermissionGranted: {
 
 break;
 }
 }
 }//requestPermissions

/*-----If user denied access in that situation we will show this messege-----*/
 -(void) accessDynamicpermissons:(NSString *)type{
 
 NSString *message;
 if([type isEqual:@"Microphone"]){
 message = NSLocalizedString( @"Fitbase doesn't have permission to use the Microphone, please change privacy settings", @"Alert message when the user has denied access to the microphone" );
 }else{
 message = NSLocalizedString( @"Fitbase doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
 }
 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fitbase" message:message preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", @"Alert OK button" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
 [self destroyAll];
 }];
 [alertController addAction:cancelAction];
 // Provide quick access to Settings.
 UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
 }];
 [alertController addAction:settingsAction];
 [self presentViewController:alertController animated:YES completion:nil];
 }//accessDynamicpermissons

NSTimer *timer;
/*----countDownTime----*/
-(void)countDownTime{
    timer= [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
}//countDownTime

/*-----updateCountdown-----*/
 -(void)updateCountdown{
 NSDate *today = [NSDate date];
 NSTimeInterval seconds1=[today timeIntervalSince1970];
 double millies1=seconds1*1000;
 int distance=countDownTimerMilliSeconds-millies1;
 if(distance>0){
 int hour=(distance % 86400000)/(3600000);
 int minut=(distance % 3600000)/60000;
 int sec = (distance % 60000)/1000;
 self.timer.text= [NSString stringWithFormat:@"%02dH:%02dM:%02dS", hour, minut, sec];
 }else{
 [self destroyAll];
 [timer invalidate];
 timer = nil;
 }
 }//updateCountdown
/*------destroyAll-------*/
 -(void) destroyAll{
     allowToSetScrollAxis=true;
 [_session disconnect:nil];
 [_allStreams removeAllObjects];
 [keys removeAllObjects];
 [_allSubscribersMesures removeAllObjects];
 [_allSubcribersPresentInRecyclerView removeAllObjects];
 [_allSubscribers removeAllObjects];
 [self dismissViewControllerAnimated:YES completion:nil];
 [self endBackgroundUpdateTask];
 [UIApplication sharedApplication].idleTimerDisabled = NO;
 [self cleanupPublisher];
 return;
 }//destroyAll

/*----cleanupPublisher----*/
 - (void)cleanupPublisher {
 [_publisher.view removeFromSuperview];
 _publisher = nil;
 // this is a good place to notify the end-user that publishing has stopped.
 }//cleanupPublisher

- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

/*---setupSession----*/
 - (void)setupSession{
 NSLog(@" =---------entered----");
 [_activityIndicator startAnimating];//spinner start
 //setup one time session
 if (_session) {
 _session = nil;
 }
 
 _session = [[OTSession alloc] initWithApiKey:self.openTokApi_Key
 sessionId:self.openTokSessionID
 delegate:self];
 [_session connectWithToken:self.openTokToken error:nil];
 [self setupPublisher];
 
 }//setupSession

/*---setupPublisher---*/
 - (void)setupPublisher{
 OTPublisherSettings *settings = [[OTPublisherSettings alloc] init];
 settings.name =  [self.hybridParams safeObjectForKey:@"userName"];//[UIDevice currentDevice].name;
 _publisher = [[OTPublisher alloc] initWithDelegate:self settings:settings];
     [self addPublisherview:_publisher];
     [_messegeForUser setHidden:NO];
 }//setupPublisher


int publisherCounter=0;
/*----addViewForPublisher-----*/
 -(void)addPublisherview:(OTPublisher *)publisher{
     
     if(_allSubscribers.count>0){
      [self.publisherView setHidden:NO];
      //[self.publisherDeaultImage setHidden:NO];
      [_publisher.view setFrame:CGRectMake(0, 0, self.publisherView.frame.size.width, self.publisherView.frame.size.height)];
      [self.publisherView addSubview:_publisher.view];
      self.publisherView.layer.borderWidth=1;
        self.publisherView.layer.borderColor=[[UIColor orangeColor] CGColor];
     }else{
         [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(setPublisherView1) userInfo:nil repeats:NO];
     }
    
 }//addViewForPublisher

-(void)setPublisherView1{
    [self.publisherView setHidden:YES];
    [self removeSubViewsInMaincontainerViews];
    if (_publisher.publishVideo){
    [_publisher.view setFrame:CGRectMake(0, 0,_mainContainerView.frame.size.width,_mainContainerView.frame.size.height)];
        [_mainContainerView addSubview:_publisher.view];
    }else{
        UIImageView*  pDImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,_mainContainerView.frame.size.width, _mainContainerView.frame.size.height)];
        [pDImage setImage:[UIImage imageNamed:@"avatar"]];
        [_mainContainerView addSubview:pDImage];
    }
}

/*----- Handling Background and foreground ----*/
 - (void)enteringBackgroundMode:(NSNotification*)notification{
 if (self.overlayTimer) {[self.overlayTimer invalidate];}
     _publisher.publishVideo = NO;
     _publisher.publishAudio=NO;
 }


/*----------------publisher didFailWithError------------*/
 - (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error
 {
 [self cleanupPublisher];
 }//publisher didFailWithError

#pragma mark - Other Interactions
- (IBAction)toggleAudioSubscribe:(id)sender
{
    if (_publisher.publishAudio == YES) {
        _publisher.publishAudio = NO;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"ic_pause_audio"] forState:UIControlStateNormal];
        
    } else {
        _publisher.publishAudio = YES;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
    }
    
}

-(void)stopNotification{
    [self.messegeForUser setHidden:YES];
    [notificationTiemr invalidate];
}
 # pragma mark - OTSubscriber delegate callbacks
 /*-----------------subscriberDidConnectToStream---------------*/
 - (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber
 {
 OTSubscriber *sub = (OTSubscriber *)subscriber;
 [_allSubscribers setObject:sub forKey:sub.stream.connection.connectionId];
     [keys addObject:sub.stream.connection.connectionId];
     if(_allSubscribers.count==1){
self.swapCameraButton.frame=CGRectMake(self.mainContainerView.frame.size.width-(2*self.swapCameraButton.frame.size.width-10),self.swapCameraButton.frame.origin.y, 51, 50);
     [self.menuBTNField setHidden:NO];
     [self.messegeForUser setHidden:YES];
     [self addPublisherview:_publisher];
 }
 [_allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
 if(keys.count>1){[self.changeViewButton setHidden:NO];}
 /*if([_muteUnmuteAllButton.titleLabel.text isEqualToString:@"Unmute all"]){
 [self enableAndDisableAllSu
  bscriberAudios:false];
 }else{
 [self enableAndDisableAllSubscriberAudios:true];
 }*/
     NSString *subscriberJoinedMSG=[sub.stream.name stringByAppendingString:@" joined"];
     [self notificationMessege:subscriberJoinedMSG];
     if(!_participantsListSheet.hidden){
        // [self removeLabelsFromParticipantsSheet];
         [self setSubscribersButtonsInParticipantsSheet];
     }
     if(![_muteAllBtnItem.titleLabel.text isEqualToString:@"     Mute All"]){
         sub.subscribeToAudio=NO;
     }
     
     if(_allSubscribers.count<=4){[self shuffle];}else{[self changeView:@"5"];}
 }//subscriberDidConnectToStream

// Open Tok Delegates
# pragma mark - OTSession delegate callbacks
/*-------------mySession streamCreated-------------*/
 - (void) session:(OTSession *)mySession streamCreated:(OTStream *)stream {
     
 NSLog(@"Connection Meta Data --------- in mySession streamCreated : %@",stream.connection.data);
 [self createSubscriber:stream];
 }//streamCreated
/*-----createSubscriber----*/
- (void)createSubscriber:(OTStream *)stream{
    // create subscriber
    _currentSubscriber = [[OTSubscriber alloc]
                          initWithStream:stream delegate:self];
    OTError *error = nil;
    [_session subscribe:_currentSubscriber error:&error];
    if (error)
    {
        //            [self showAlert:[error localizedDescription]];
    }
}//createSubscriber
 
 /*------sessionDidDisconnect-----*/
 - (void)sessionDidDisconnect:(OTSession *)session {
 sessionDisconnect=YES;
 [self destroyAll];
 }//sessionDidDisconnect
 
 
 /*-----sessionDidConnect-----*/
 - (void)sessionDidConnect:(OTSession *)session {  // now publish
 OTError *error = nil;
 [_session publish:_publisher error:&error];
 if (error)
 {
 //        [self showAlert:[error localizedDescription]];
 }
 [_activityIndicator stopAnimating]; //spinner close
 [_activityIndicator setHidden:YES];
 }//sessionDidConnect
 
 - (void)session:(OTSession *)session didFailWithError:(OTError *)error {
 }
 
 /*-----streamDestroyed----*/
 - (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{
   NSLog(@"streamDestroyed %@", stream.connection.connectionId);
     OTSubscriber *subscriber = [_allSubscribers objectForKey:stream.connection.connectionId];
     [keys removeObject:stream.connection.connectionId];
     [subscriber.view removeFromSuperview];
     [_allSubscribers removeObjectForKey:stream.connection.connectionId];
     [_allSubcribersPresentInRecyclerView removeObjectForKey:stream.connection.connectionId];
     [_allSubscribersMesures removeObjectForKey:stream.connection.connectionId];
     NSString *subscriberJoinedMSG=[subscriber.stream.name stringByAppendingString:@" exit"];
     [self notificationMessege:subscriberJoinedMSG];
     if(_allSubscribers.count<=1){
        if(changeveiw){
        _scrollView.frame=CGRectMake(0,initialYaxisScroll,_scrollView.frame.size.width, _scrollView.frame.size.height);[self.changeViewButton setHidden:YES];
        }//if
        changeveiw=false;
        [self changeView:@"setToGridView"];
        if(_allSubscribers.count==0){
        self.swapCameraButton.frame=CGRectMake(self.mainContainerView.frame.size.width-(self.swapCameraButton.frame.size.width+20),self.swapCameraButton.frame.origin.y,50,50);
            [self addPublisherview:_publisher];
            [self.menuBTNField setHidden:YES];
            [_muteAllActionSheet setHidden:YES];
            [self.participantsListSheet setHidden:YES];
            [notificationTiemr invalidate];
            self.messegeForUser.text=@"Waiting for user to join..";
            [notificationTiemr invalidate];
         }// inner If
      }else{
          [self callRespectiveView];
     }//if-else
     if(!_participantsListSheet.hidden){
         //[self removeLabelsFromParticipantsSheet];
       [self setSubscribersButtonsInParticipantsSheet];
     }//if
    }//streamDestroyed

/*------setRespectiveView----*/
-(void)callRespectiveView{
    changeveiw=(changeveiw)?false:true;
    [self changeView:@"123"];
}//setRespectiveView

 /*---cleanupSubscriber--*/
 - (void)cleanupSubscriber{
 [_currentSubscriber.view removeFromSuperview];
 _currentSubscriber = nil;
 }//cleanupSubscriber
 
 
 # pragma mark - OTPublisher delegate callbacks
 
 - (void)publisher:(OTPublisherKit *)publisher
 streamCreated:(OTStream *)stream{
 //NSLog(@"Connection Meta Data  in publisher streamCreated -------: %@",stream.connection.data);
 }//streamCreated
 
 - (void)publisher:(OTPublisherKit*)publisher
 streamDestroyed:(OTStream *)stream
 {
 if ([_currentSubscriber.stream.streamId isEqualToString:stream.streamId])
 {
 [self cleanupSubscriber];
 }
 [self cleanupPublisher];
 }


/*------leavingBackgroundMode-----*/
 - (void)leavingBackgroundMode:(NSNotification*)notification{
 _publisher.publishVideo = YES;
 _publisher.publishAudio=YES;
 //[self shuffle];
 }//leavingBackgroundMode

/*-------------orientationChanged---------*/
 - (void) orientationChanged:(NSNotification *)note{
 UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
 if(sessionDisconnect==NO){
 if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight){
   [self checkSubscribersList];
 }else if(Orientation==UIDeviceOrientationPortrait) {
   [self checkSubscribersList];
 }
 }//outer if
 }//orientationChanged

/*-----------checkSubscribersList--------*/
 -(void)checkSubscribersList{
     if(_allSubscribers.count>0){
     //allowToSetScrollAxis=true;
    // if(![_changeViewButton.titleLabel.text isEqualToString:@"grid"]){
         
    // }else{
         allowToSetScrollAxis=true;
         [self callRespectiveView];

    // }
     //allowToSetScrollAxis=true;
/* if(changeveiw ==false){
 [self setUpPublisherFrame:_scrollView.frame.origin.y height:_scrollView.frame.size.height];
 [self setupScrollView];
 [self addViewMainScrollScontainer:maincontainerSub tagValue:(int)_scrollContainerView.tag];
 [self recyclerView];
 }else{
 [self setUpPublisherFrame:_publisherView.frame.origin.y height:100];
 }*/
     } else{
         [self addPublisherview:_publisher];
     }
 }//checkSubscribersList


/*---View Tapped When Hide Back and BottomView--*/
 - (void)viewTappedInLive:(UITapGestureRecognizer *)tgr {
     [self afterOverlayTimeAction];
     if(!_muteAllActionSheet.hidden){
         [self.muteAllActionSheet setHidden:YES];
         muteUnte=true;
     }
 }//viewTappedInLive
 
 -(void)afterOverlayTimeAction{
 if (tapped) {
 [UIView animateWithDuration:0.3f
 animations:^{
       if (self.overlayTimer) {[self.overlayTimer invalidate];}
 [self setHiddenShowForICONs:true];
 if(keys.count>1){ [self.changeViewButton setHidden:YES];}
 if(changeveiw==false){
 _scrollView.frame=CGRectMake(0,afterIconsOnYaxis, _scrollView.frame.size.width, _scrollView.frame.size.height);
     [self setUpPublisherFrame:afterIconsOnYaxis height:_scrollView.frame.size.height width:80];
 }
 }];
 tapped=NO;
 }else{
 [UIView animateWithDuration:0.3f
 animations:^{
 if (self.overlayTimer) {[self.overlayTimer invalidate];}
 [self setHiddenShowForICONs:false];
 [self overlayTimerSetUp];// start overlay hide timer
 if(keys.count>1){  [self.topToolBar setHidden:NO];}
 if(changeveiw==false){
     _scrollView.frame=CGRectMake(0,initialYaxisScroll,_scrollView.frame.size.width, _scrollView.frame.size.height);
 [self setUpPublisherFrame:initialYaxisScroll height:_scrollView.frame.size.height width:80];
 }
 }];
 tapped=YES;
 }
 }//afterOverlayTimeAction
 
 /*-----overlayTimerSetUp-----*/
 -(void)overlayTimerSetUp{
 self.overlayTimer =
 [NSTimer scheduledTimerWithTimeInterval:5
 target:self
 selector:@selector(overlayTimerAction)
 userInfo:nil
 repeats:NO];
 }//overlayTimerSetUp
 
 
 /*----overlayTimerAction ----*/
 - (void)overlayTimerAction{
    [self afterOverlayTimeAction];
 }//overlayTimerAction
 
/*---setHiddenShowForICONs----*/
 -(void)setHiddenShowForICONs:(Boolean ) value{
 [self.exitBtn setHidden:value];
 [self.audioSubUnsubButton setHidden:value];
 [self.videoSubUnsubButton setHidden:value];
 [self.swapCameraButton setHidden:value];
 [self.topToolBar setHidden:value];
  if(keys.count>1){ [self.changeViewButton setHidden:value];}
 }//setHiddenShowForICONs


/*--showReconnectingAlert--*/
 - (void)showReconnectingAlert{
    [self notificationMessege:@"Session Reconnecting.."];
    //[self.messegeForUser setHidden:NO];
 }//showReconnectingAlert
 
 /*---dismissReconnectingAlert---*/
 - (void)dismissReconnectingAlert{
 [self.messegeForUser setHidden:YES];
 }
 
 /*------sessionDidBeginReconnecting------*/
 - (void)sessionDidBeginReconnecting:(OTSession *)session{
 [self showReconnectingAlert];
 }//sessionDidBeginReconnecting
 
 /*-----sessionDidBeginReconnecting-----*/
 - (void)sessionDidReconnect:(OTSession *)session{
 [self dismissReconnectingAlert];
 }//sessionDidReconnect

/*-------cam swape------*/
 - (IBAction)swapCam:(id)sender {
 if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
 _publisher.cameraPosition = AVCaptureDevicePositionFront;
 } else if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
 _publisher.cameraPosition = AVCaptureDevicePositionBack;
 }
 }//cam swap

/*-------move publisher Object -----------*/
 -(void)moveObject:(UIPanGestureRecognizer *)pan;
 {
 if(changeveiw){
 _publisherView.center = [pan locationInView:_publisherView.superview];
 _publisherDeaultImage.center=[pan locationInView:_publisherDeaultImage.superview];
 }
 }//moveObject


-(void)removeSubViewsInMaincontainerViews{
    for(UIView * subview in _mainContainerView.subviews){
        [subview removeFromSuperview];
    }
    for(UIImageView * subview in _mainContainerView.subviews){
        [subview removeFromSuperview];
    }
}
/*-----loopForGridViews-----*/
 -(void)loopForGridViews:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis {
 float widthOfView=width;
 float xAxisOfview=0;
 float yAxisOfview=0;
 float heightOfView=height;
 
 //NSLog(@" -------height----- %f,%f",height,width);
 //NSLog(@"---------xaxis and yaxis----- %f,%f",xAxisOfview,yAxisOfview );
 
 for(int i=0;i<_allSubscribers.count;i++){
 OTSubscriber * sub=[_allSubscribers objectForKey:keys[i]];
 if(sub.stream.hasVideo){
 [self addViewForGridView:sub width:widthOfView height:heightOfView xAxis:xAxisOfview yAxis:yAxisOfview tagValue:i];
 }else{
 [self addDefaultImageForViewInGrid:sub width:widthOfView height:heightOfView xAxis:xAxisOfview yAxis:yAxisOfview tagValue:i];
 }
 
 yAxisOfview=(_allSubscribers.count==2 && i==0)?_mainContainerView.frame.size.height/2:(_allSubscribers.count==3 && i==1)? height:(_allSubscribers.count==4 && (i==1 || i==2))? height:0;
 xAxisOfview=((_allSubscribers.count==3||_allSubscribers.count==4)&& (i==0||i==2))? width:0;
 widthOfView=(_allSubscribers.count==3 && i==1)?_mainContainerView.frame.size.width :(_allSubscribers.count==2)?_mainContainerView.frame.size.width :width;
 }
 }//loopForGridViews

-(void)addDefaultImageForViewInGrid:(OTSubscriber *)sub width:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis tagValue:(int )tag{
    [self setSubscribersMesures:sub.stream.connection.connectionId xAxis:xAxis yAxis:yAxis width:width height:height tag:tag];
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
    image.frame = CGRectMake(xAxis, yAxis,width,height);
    image.backgroundColor=[UIColor darkGrayColor];
    image.tag=tag;
    [_mainContainerView addSubview:image];
}


/*---------addViewsForGridView------*/
 -(void)addViewForGridView:(OTSubscriber *)sub   width:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis tagValue:(int )tag {
     [self setSubscribersMesures:sub.stream.connection.connectionId xAxis:xAxis yAxis:yAxis width:width height:height tag:tag];
 UIView* subview=[[UIView alloc] initWithFrame:CGRectMake(xAxis, yAxis, width, height)];
 [_mainContainerView addSubview:subview];
 [sub.view setFrame:CGRectMake(0, 0, subview.frame.size.width, subview.frame.size.height)];
     subview.tag=tag;
     UITapGestureRecognizer * tapTwice=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwiceOnAnyTraineeInGridView:)];
     tapTwice.numberOfTapsRequired=2;
     //subAudioBtn.frame=CGRectMake(, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>);
    // UIButton * subBtn=[_allSubscribersButtons objectForKey:sub.stream.connection.connectionId];
     //subBtn.frame=CGRectMake(0, sub.view.frame.origin.y-30,30,30);
   [subview addGestureRecognizer:tapTwice];
     [subview addSubview:sub.view];
  //
     
 /*UIButton * button=(tag==0)?_audioBTNOne:(tag==1)?_audioBTNTwo:(tag==2)?_audioBTNThree:_audioBTNFour;
 [self addFrameForButtons:width button:button tagValue:tag];
 [self adjustSubscriberAudio:sub.subscribeToAudio subscriber:sub button:button];
 
 [sub.view addSubview:button];*/
 }//addViewForGridView
int selectedTappedPersonIndex;
/*-----tapTwiceOnAnyTraineeInGridView-----*/
-(void)tapTwiceOnAnyTraineeInGridView:(UIPanGestureRecognizer *)pan{
    NSLog(@"----tapped index---- %ld",pan.view.tag);
    selectedTappedPersonIndex=(int)pan.view.tag;
    if(_allSubscribers.count>1){
        changeveiw=true;
        [self changeView:@"double"];
    }
}//tapTwiceOnAnyTraineeInGridView

-(void)setSubscribersMesures:(NSString* )connectionId xAxis:(double )xAxis yAxis:(double )yAxis width:(double )width height:(double )height tag:(int )tag
{
    SubscriberMesursInGrid *mySubscriber =[[SubscriberMesursInGrid alloc] init];
    mySubscriber.indexNumber=tag;
    mySubscriber.xAxis=xAxis;
    mySubscriber.yAxis=yAxis;
    mySubscriber.width=width;
    mySubscriber.height=height;
    [_allSubscribersMesures setObject:mySubscriber forKey:connectionId];
    NSLog(@" ---count ---- %lu",(unsigned long)_allSubscribersMesures.count);
}
#pragma mark - Helper Methods
- (IBAction)endCallAction:(UIButton *)button{
    sessionDisconnect=YES;
    if (_session) {
        [self destroyAll];
    }
}

/*--------toggleVideo------*/
 - (IBAction)toggleVideo:(id)sender {
 if (_publisher.publishVideo == YES) {
 _publisher.publishVideo = NO;
    
     [self.videoSubUnsubButton setImage:[UIImage imageNamed:@"ic_pause_video"] forState:UIControlStateNormal];
      if(_allSubscribers.count!=0){
          [self.publisherDeaultImage setHidden:NO];
      }else{
          [self setPublisherView1];
      }
 } else {
 _publisher.publishVideo = YES;
 [self.videoSubUnsubButton setImage:[UIImage imageNamed:@"ic_play_video"] forState:UIControlStateNormal];
 [self.publisherDeaultImage setHidden:YES];
     if(_allSubscribers.count==0) {
         [self.publisherDeaultImage setHidden:YES];
         [self setPublisherView1];
     }
 }
 }//toggleVideo


- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error{
    NSLog(@"subscriber could not connect to stream");
}


int initialDefaultImgXaxis;
/*----changeView----*/
 - (IBAction)changeView:(id)sender {
  if(changeveiw){
      [self commonForBothViews:NO imageViewName:@"gridView" id:sender];
      [self.scrollView setHidden:NO];
      [self setupScrollView];
      initialDefaultImgXaxis=102;
          [self setUpPublisherFrame:_scrollView.frame.origin.y height:_scrollView.frame.size.height width:80];
  }else{
      [self.scrollView setHidden:YES];
          [self setUpPublisherFrame:400 height:80 width:80];
      [self commonForBothViews:YES imageViewName:@"galaryView" id:sender];
  }
 }//changeView

-(void)commonForBothViews:(Boolean )booleanValue imageViewName:(NSString *)imgName id:(NSString *)id{
    changeveiw=booleanValue;
 //   [self removeAllSubscribersButtonsFromView];
    [self setHiddenAudioButtons:true];
    [self removeSubViewsInMaincontainerViews];
    [self removeViewsFromRecycler];

    
    [_changeViewButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    if(!changeveiw){
        int tag=([id isEqual:@"double"])? selectedTappedPersonIndex:0;
        OTSubscriber *sub=[_allSubscribers objectForKey:keys[tag]];
        [self setMainContainerSubscriberView:sub tag:tag];
       
    }
    [self shuffle];
}
NSMutableArray* btnArrayKey;
-(void)removeAllSubscribersButtonsFromView{
    
    for(int i=0;i<=keys.count;i++){
        UIButton * subcriberButton=[_allSubscribersButtons objectForKey:keys[1]];
        [subcriberButton removeFromSuperview];
    }
}

/*--------setHiddenAudioButtons--------*/
-(void)setHiddenAudioButtons:(Boolean )value{
    [self.audioBTNOne setHidden:value];
    [self.audioBTNTwo setHidden:value];
    [self.audioBTNThree setHidden:value];
    [self.audioBTNFour setHidden:value];
    [self.audioBTNFive setHidden:value];
}//setHiddenAudioButtons

bool allowToSetScrollAxis=true;
/*------setupScrollView----*/
-(void)setupScrollView{
    if(allowToSetScrollAxis){
    initialYaxisScroll=_scrollView.frame.origin.y;
    afterIconsOnYaxis=_mainContainerView.frame.size.height-100;
        allowToSetScrollAxis=false;
    }
}//sedtupScrollView


 
 
/*-------shuffle-----*/
-(void)shuffle
{
    if(changeveiw){
        float width= (_allSubscribers.count==1 || _allSubscribers.count==2)?_mainContainerView.frame.size.width:_mainContainerView.frame.size.width/2 ;
        float height= (_allSubscribers.count>1)?_mainContainerView.frame.size.height/2:_mainContainerView.frame.size.height;
        [self removeSubViewsInMaincontainerViews];
        [self loopForGridViews:width height:height xAxis:0 yAxis:0];
        
    }else{
        [self addPublisherview:_publisher];
        //[self removeSubViewsInMaincontainerViews];
        //[self hideAudioButtons:YES];
        [self reCyclerView];
    }
}//shuffle


OTSubscriber *maincontainerSubcriber=nil;
-(void)setMainContainerSubscriberView:(OTSubscriber *) mainViewSubscriber tag:(int )tagNO{
    maincontainerSubcriber=mainViewSubscriber;
     self.mainContainerView.tag=tagNO;
    if(mainViewSubscriber.stream.hasVideo){  //based on user video we are setting view
        [mainViewSubscriber.view setFrame:CGRectMake(0, 0, self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height)];
        //[mainViewSubscriber.view addSubview:mainConAudioButton];
        [self.mainContainerView addSubview:mainViewSubscriber.view];
    }else{
        UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
        image.frame = CGRectMake(0, 0,self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height);
        image.backgroundColor=[UIColor darkGrayColor];
        [_mainContainerView addSubview:image];
    }
    
}

-(UIButton *) setAudioButtonsInRecyclerView:(double )xAxis yAxis:(double )yAxis width:(double )width height:(double )height tag:(int )tagNo {
     OTSubscriber *subAudio=[_allSubscribers objectForKey:keys[tagNo]];
    UIButton *button=(tagNo==0)? _audioBTNOne:(tagNo==1)?_audioBTNTwo:(tagNo==2)?_audioBTNThree:(tagNo==3)?_audioBTNFour:_audioBTNFive;
        [button setHidden:NO];
      button.frame=CGRectMake(xAxis, yAxis, width, height);
        NSString* imageType=(subAudio.subscribeToAudio==YES)?@"unmute_sm":@"mute_sm";
    // if(subAudio.subscribeToAudio==YES){
     [button setImage:[[UIImage imageNamed:imageType] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    if(subAudio.subscribeToAudio==YES){
        [button setTintColor:[UIColor greenColor]];}else{[button setTintColor:[UIColor redColor]];}
    [button setBackgroundColor:[UIColor whiteColor]];
    button.tag=tagNo;
    [button addTarget:self action:@selector(setSubscriberAudio:) forControlEvents:UIControlEventTouchDown];
    return button;
}

-(void)setSubscriberAudio:(UIButton *)sender {
    NSLog(@"---- %lu",sender.tag);
    int index=(int)sender.tag;
    OTSubscriber *subAudio=[_allSubscribers objectForKey:keys[index]];
    UIButton * clickeBTN=sender;
    if(subAudio.subscribeToAudio==YES){
        subAudio.subscribeToAudio=NO;
        [clickeBTN setImage:[[UIImage imageNamed:@"mute_sm"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
       [clickeBTN setTintColor:[UIColor redColor]];
        
    }else{
         subAudio.subscribeToAudio=YES;
         [_muteAllBtnItem setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
        [self.muteAllBtnItem setTitle:@"     Mute All" forState:UIControlStateNormal];
         [clickeBTN setImage:[[UIImage imageNamed:@"unmute_sm"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
         [clickeBTN setTintColor:[UIColor greenColor]];
        
    }
}
-(void)checkAllSubscriberAudioAndSetMuteAllBtnTitle{
    int countOfSubAudio=0;
    for(int i=0;i<_allSubscribers.count;i++){
        OTSubscriber* sub= [_allSubscribers objectForKey:keys[i]];
        if(sub.subscribeToAudio){
            countOfSubAudio=countOfSubAudio+1;
        }
    }
    if(countOfSubAudio==_allSubscribers.count){
         [_muteAllBtnItem setImage:[UIImage imageNamed:@"ic_pause_audio"] forState:UIControlStateNormal];
         [self.muteAllBtnItem setTitle:@"     Umute All" forState:UIControlStateNormal];
    }else{
         [_muteAllBtnItem setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
        [self.muteAllBtnItem setTitle:@"     Mute All" forState:UIControlStateNormal];
    }
}

-(void)reCyclerView{
    double xAxis=112;
    double width=100;
    for(int i=0;i<keys.count;i++){
        OTSubscriber *sub=[_allSubscribers objectForKey:keys[i]];
        [_scrollView setContentSize:CGSizeMake(width+100, _scrollView.frame.size.height)];
        _scrollView.delegate=self;
        [self setViewsInScrollView:sub xAxis:xAxis tagValue:i];
        if(width>350){
            [_scrollView setContentOffset:CGPointMake(width-310, 0) animated:false];
        }
        width+=100;
        xAxis+=90;
    }
   // [_scrollView setContentOffset:CGPointMake(xAxis-350, 0) animated:true];
}
-(void)setViewsInScrollView:(OTSubscriber *)sub xAxis:(double )xAxis tagValue:(int )tag{
    if(sub.stream.hasVideo && ![maincontainerSubcriber.stream.connection.connectionId isEqual:sub.stream.connection.connectionId]){
        UIView * subcriberViewInScroll=[[UIView alloc] initWithFrame:CGRectMake(xAxis, 0, 80, _scrollView.frame.size.height)];
        subcriberViewInScroll.layer.borderWidth = 2;
        subcriberViewInScroll.layer.borderColor=[[UIColor whiteColor] CGColor];
        [subcriberViewInScroll setClipsToBounds:YES];
        [sub.view setFrame:CGRectMake(0,0 ,subcriberViewInScroll.frame.size.width, subcriberViewInScroll.frame.size.height)];
        [subcriberViewInScroll addSubview:sub.view];
        subcriberViewInScroll.tag=tag;
        subcriberViewInScroll.layer.cornerRadius=5;
        subcriberViewInScroll.layer.masksToBounds = true;
        [subcriberViewInScroll addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnScrollerViews:)]];
        [_allSubcribersPresentInRecyclerView setObject:subcriberViewInScroll forKey:sub.stream.connection.connectionId];
        
        
        UIButton *subViewBtn=[self setAudioButtonsInRecyclerView:sub.view.frame.size.width-30 yAxis:sub.view.frame.size.height-30 width:30 height:30  tag:tag];

        [sub.view addSubview:subViewBtn];
        [_allSubscribersButtons setObject:subViewBtn forKey:sub.stream.connection.connectionId];
        [_scrollView addSubview:subcriberViewInScroll];
    }else{
        [self addDefaultImage:sub
                        xAxis:xAxis
                        widht:80
                        height: _scrollView.frame.size.height
                        tagValue:tag];
    
    }//if-else
}//setViewsInScrollView

int defaultImgInitialInScrollTag;
UIImageView *mainContainerDefaultImg=nil;
-(void)addDefaultImage:(OTSubscriber *)sub
                 xAxis:(double )xAxis
                 widht:(double )width
                height:(double )height
              tagValue:(int )tag
{
    NSString * imageName=([sub.stream.connection.connectionId isEqual:maincontainerSubcriber.stream.connection.connectionId])? @"bgThaminailView" :@"avatar";
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    image.frame = CGRectMake(xAxis, 0,width,height);
     image.layer.borderWidth = 2;
    image.layer.borderColor=[[UIColor whiteColor] CGColor];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.frame.size.width,image.frame.size.height )];
    if(!sub.stream.hasVideo){
        /*UILabel *videoMutelabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, label.frame.size.width,label.frame.size.height/4)];
        videoMutelabel.textColor=[UIColor redColor];
        videoMutelabel.textAlignment = NSTextAlignmentCenter;
        videoMutelabel.text=([container isEqualToString:@"main"])? @"Video muted" :@"Muted";
        [label addSubview:videoMutelabel];*/
    }
    label.textColor=[UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text=sub.stream.name;
    [image addSubview:label];
    image.tag=tag;
    image.layer.cornerRadius=5;
    image.layer.masksToBounds=true;
    image.userInteractionEnabled=YES;
        [image addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnScrollerViews:)]];
      UIButton *defaultImgBtn=[self setAudioButtonsInRecyclerView:image.frame.size.width-30 yAxis:image.frame.size.height-30 width:30 height:30  tag:tag];
      [image addSubview:defaultImgBtn];
    if([maincontainerSubcriber.stream.connection.connectionId isEqual:sub.stream.connection.connectionId]){
        defaultImgInitialInScrollTag=tag;
        mainContainerDefaultImg=image;
    }
     [_allSubscribersButtons setObject:defaultImgBtn forKey:sub.stream.connection.connectionId];
     [_scrollView addSubview:image];
     [_allSubcribersPresentInRecyclerView setObject:image forKey:sub.stream.connection.connectionId];
}//addDefaultImage
//float maincontainerIndex=0;
/*------tapOnScrollerViews-------*/
 -(void)tapOnScrollerViews:(UIPanGestureRecognizer *)pan;
 {
 NSLog(@" -------%ld",pan.view.tag);
  int index=(int)pan.view.tag;
  int mainScrollViewConTag=(int)_mainContainerView.tag;
     if(index!=mainScrollViewConTag){
  OTSubscriber * firstDefaultImgConSub=[_allSubscribers objectForKey:keys[mainScrollViewConTag]];
  OTSubscriber * tappedSub=[_allSubscribers objectForKey:keys[index]];
         UIButton * tappedSubAudioBtn=[_allSubscribersButtons objectForKey:tappedSub.stream.connection.connectionId];
         [tappedSubAudioBtn removeFromSuperview];
         [_allSubscribersButtons removeObjectForKey:tappedSub.stream.connection.connectionId];
  maincontainerSubcriber=nil;
  [self setMainContainerSubscriberView:tappedSub tag:index];
      UIView *tappedView=pan.view;
     for(UIView *subview in _scrollView.subviews){
         if(subview.tag==defaultImgInitialInScrollTag ){[subview removeFromSuperview];}
     }
     
[self setViewsInScrollView:firstDefaultImgConSub xAxis:mainContainerDefaultImg.frame.origin.x tagValue:mainScrollViewConTag];
 [tappedView removeFromSuperview];
 [self setViewsInScrollView:tappedSub xAxis:pan.view.frame.origin.x tagValue:index];
 initialDefaultImgXaxis=pan.view.frame.origin.x;
     }
 }//tapOnScrollerViews


  /*-------------removeViewsFromRecycler--------*/
  -(void)removeViewsFromRecycler{
  for(UIView *subview in _scrollView.subviews){
  [subview removeFromSuperview];
  }
  for(UIImageView *images in _scrollView.subviews){
  [images removeFromSuperview];
  }
  }//removeViewsFromRecycler
/*------setUpPublisherFrame--------*/
-(void)setUpPublisherFrame:(float )yaxis height:(float )height width:(float )width{
 self.publisherView.frame=CGRectMake(0, yaxis, width, height);
 self.publisherDeaultImage.frame=CGRectMake(0, yaxis, width, height);
 [self addPublisherview:_publisher];
 }//setUpPublisherFrame

/*------subscriberVideoDisabled------*/
- (void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason{
    if(keys !=nil && _allSubscribers.count>1){
       OTSubscriber *videoMutedSubscriber= [_allSubscribers objectForKey:subscriber.stream.connection.connectionId];
       if(changeveiw){//If changeview is true then we will call gridview functionalities
        SubscriberMesursInGrid *mySubscriber=[_allSubscribersMesures objectForKey:subscriber.stream.connection.connectionId];
        for(UIView *subview in _mainContainerView.subviews){
            if(subview.tag==mySubscriber.indexNumber){
                [subview removeFromSuperview];
                [self addDefaultImageForViewInGrid:videoMutedSubscriber width:mySubscriber.width height:mySubscriber.height xAxis:mySubscriber.xAxis yAxis:mySubscriber.yAxis tagValue:mySubscriber.indexNumber];
               
            }// inner-if
         }//for
       }else{
           UIView* subscriberViewInScroll=[_allSubcribersPresentInRecyclerView objectForKey:subscriber.stream.connection.connectionId];
           if(subscriber.stream.connection.connectionId==maincontainerSubcriber.stream.connection.connectionId){
               [self removeSubViewsInMaincontainerViews];
               [self setMainContainerSubscriberView:videoMutedSubscriber tag:(int)subscriberViewInScroll.tag];
           }else{
           for(UIView *subview in _scrollView.subviews){
               if(subscriberViewInScroll.tag==subview.tag){
                   NSLog(@"------- checking --- %ldl",(long)subscriberViewInScroll.tag);
                   [subview removeFromSuperview];
                   NSLog(@"------- checking --- %ldl",(long)subscriberViewInScroll.tag);
                   [self addDefaultImage:videoMutedSubscriber xAxis:subscriberViewInScroll.frame.origin.x widht:subscriberViewInScroll.frame.size.width height:subscriberViewInScroll.frame.size.height
                       tagValue:(int)subscriberViewInScroll.tag];
               }//inner-if
           }//for
         }//inner if-else
       }//if-else
    }//if checking keys
}//subscriberVideoDisabled
/*-------subscriberVideoEnabled------*/
- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    if(keys !=nil&&_allSubscribers.count>1){
       OTSubscriber *videoMutedSubscriber= [_allSubscribers objectForKey:subscriber.stream.connection.connectionId];
       if(changeveiw){
         SubscriberMesursInGrid *mySubscriberViewMesurs=[_allSubscribersMesures objectForKey:subscriber.stream.connection.connectionId];
         for(UIImageView *subview in _mainContainerView.subviews){
            if(subview.tag==mySubscriberViewMesurs.indexNumber){
                [subview removeFromSuperview];
                [self addViewForGridView:videoMutedSubscriber width:mySubscriberViewMesurs.width height:mySubscriberViewMesurs.height xAxis:mySubscriberViewMesurs.xAxis yAxis:mySubscriberViewMesurs.yAxis tagValue:mySubscriberViewMesurs.indexNumber];
            }//if
          }//for
        }else{
            UIView* subscriberViewInScroll=[_allSubcribersPresentInRecyclerView objectForKey:subscriber.stream.connection.connectionId];
            if(subscriber.stream.connection.connectionId==maincontainerSubcriber.stream.connection.connectionId){
                [self removeSubViewsInMaincontainerViews];
                [self setMainContainerSubscriberView:videoMutedSubscriber tag:(int)subscriberViewInScroll.tag];
            }else{
            for(UIImageView *subview in _scrollView.subviews){
                if(subscriberViewInScroll.tag==subview.tag){
                    NSLog(@"------- checking --- %ldl",(long)subscriberViewInScroll.tag);
                    [subview removeFromSuperview];
                    NSLog(@"------- checking --- %ldl",(long)subscriberViewInScroll.tag);
                  [self setViewsInScrollView:videoMutedSubscriber xAxis:subscriberViewInScroll.frame.origin.x tagValue:(int)subscriberViewInScroll.tag];
                }//inner -if
           }//for
          }
        }//if-else
    }//if
}//subscriberVideoEnabled
NSTimer * notificationTiemr;
-(void)notificationMessege:(NSString *)messege{
   notificationTiemr=[NSTimer scheduledTimerWithTimeInterval: 5.0f target:self selector:@selector(stopNotification) userInfo:nil repeats: NO];
    [notificationTiemr isValid];
    [self.messegeForUser setHidden:NO];
    self.messegeForUser.text=messege;
}

- (void)backButtonOfParticipants{
   // [self removeLabelsFromParticipantsSheet];
    [self.participantsListSheet setHidden:YES];
    [self.muteAllActionSheet setHidden:YES];
    [self callRespectiveView];
    muteUnte=true;
}
/*-------showTheParticipantsList------*/
- (IBAction)showTheParticipantsList:(id)sender {
    [self.participantsListSheet setHidden:NO];
    [self setParticipantsHeader];
  //  [self removeLabelsFromParticipantsSheet];
    [self setSubscribersButtonsInParticipantsSheet];
}



/*--------muteAll-------*/
- (IBAction)muteAll:(id)sender {
    if([_muteAllBtnItem.titleLabel.text isEqualToString:@"     Mute All"]){
        [self muteAllSubscriberAudio:NO];
        [_muteAllBtnItem setImage:[UIImage imageNamed:@"ic_pause_audio"] forState:UIControlStateNormal];
        [_muteAllBtnItem setTitle:@"     Umute All" forState:UIControlStateNormal];
        
    }else{
        [self muteAllSubscriberAudio:YES];
          [_muteAllBtnItem setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
        [_muteAllBtnItem setTitle:@"     Mute All" forState:UIControlStateNormal];
      
    }
    [self.muteAllActionSheet setHidden:YES];
    muteUnte=true;
}//muteAll

/*-----muteAllSubscriberAudio---*/
-(void)muteAllSubscriberAudio:(Boolean )value{
    for(int i=0;i<_allSubscribers.count;i++){
        OTSubscriber * sub=[_allSubscribers objectForKey:keys[i]];
        sub.subscribeToAudio=value;
    }
    //[self afterOverlayTimeAction];
    [self callRespectiveView];
}//muteAllSubscriberAudio

bool muteUnte=true;
/*--------menuBTN-------*/
- (IBAction)menuBTN:(id)sender {
    if(muteUnte){
        [self.muteAllActionSheet setHidden:NO];
        muteUnte=false;
    }else{
        [self.muteAllActionSheet setHidden:YES];
        muteUnte=true;
    }
 /*   if(_allSubscribers.count==1){
        [self.muteAllBtnItem setTitle:@"     Mute" forState:UIControlStateNormal];
        [self.ParticioantsBtnItem setHidden:YES];
    }else{
        [self.muteAllBtnItem setTitle:@"     Mute All" forState:UIControlStateNormal];
        [self.ParticioantsBtnItem setHidden:NO];
    }*/
}//menuBTN



/*-------removeLabelsFromParticipantsSheet----*/
-(void)removeLabelsFromParticipantsSheet{
    for(UIView* subview in _participantsListSheet.subviews){
        if(subview.tag!=111){
            [subview removeFromSuperview];
        }
    }
}//removeLabelsFromParticipantsSheet

/*------setSubscribersButtonsInParticipantsSheet-----*/
-(void)setSubscribersButtonsInParticipantsSheet{
    [self removeLabelsFromParticipantsSheet];
     float yAxis=100;
    for (int i=0; i<_allSubscribers.count; i++) {
        OTSubscriber * participant=[_allSubscribers objectForKey:keys[i]];
      UIView *viewsInParticipants=[[UIView alloc] initWithFrame:CGRectMake(0,yAxis, _participantsListSheet.frame.size.width,60)];
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0,5, _participantsListSheet.frame.size.width,50)];
        label.userInteractionEnabled=YES;
        label.text=[@"  " stringByAppendingString:participant.stream.name];
        label.textColor=[UIColor lightGrayColor];
        UIButton* particioantAudioBTN=[self setAudioButtonsInRecyclerView:(viewsInParticipants.frame.size.width-50) yAxis:10 width:40 height:40 tag:i];
        viewsInParticipants.tag=i;
        
        if(i>0){
            viewsInParticipants.layer.borderWidth=0.5;
            viewsInParticipants.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        }
        [label addSubview:particioantAudioBTN];
        [viewsInParticipants addSubview:label];
        [_participantsListSheet addSubview:viewsInParticipants];
        yAxis=yAxis+60;
    }
}//setSubscribersButtonsInParticipantsSheet


/*--setBackgroudForButtonsAndViews---*/
-(void) setBackgroudForButtonsAndViews{
    [self.messegeForUser setBackgroundColor:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.1f] ];
    [_mainContainerView setBackgroundColor: [UIColor colorWithRed:36/255.0f green:36/255.0f blue:36/255.0f alpha:1.0f]];
    //[self.videoSubUnsubButton setBackgroundColor: [UIColor colorWithRed:64/255.0f green:180/255.0f blue:202/255.0f alpha:1.0f]];
    [self.audioSubUnsubButton setBackgroundColor: [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1f]];
    [self.topToolBar setBackgroundColor: [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1f]];
}//setBackgroudForButtonsAndViews

/*------setParticipantsHeader---*/
-(void)setParticipantsHeader{
    UIView * participantsHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.participantsListSheet.frame.size.width,50)];
    UILabel* participantsHeader=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,participantsHeaderView.frame.size.width, 80)];
    participantsHeader.userInteractionEnabled=YES;
    participantsHeader.text=@"             Participants";
    participantsHeader.textColor=[UIColor whiteColor];
    [participantsHeader setBackgroundColor: [UIColor colorWithRed:64/255.0f green:180/255.0f blue:202/255.0f alpha:1.0f]];
    UIButton * headerBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 20, 40, 40)];
    [headerBtn setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [headerBtn addTarget:self action:@selector(backButtonOfParticipants) forControlEvents:UIControlEventTouchDown];
    [participantsHeader addSubview:headerBtn];
    participantsHeaderView.tag=111;
    [participantsHeaderView addSubview:participantsHeader];
    [self.participantsListSheet addSubview:participantsHeaderView];
}//setParticipantsHeader

/*-(BOOL)shouldAutorotate{
   return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}*/

/*dealloc--*/
 - (void)dealloc{
 [[NSNotificationCenter defaultCenter]
 removeObserver:self
 name:UIApplicationWillResignActiveNotification
 object:nil];
 
 [[NSNotificationCenter defaultCenter]
 removeObserver:self
 name:UIApplicationDidBecomeActiveNotification
 object:nil];
 }//dealloc


/*------connection created ---------*/
- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
     sessionDisconnect=NO;
    //NSLog(@"----session connectionCreated------- %@",connection.connectionId);
  
}//connection created
/*--------------connection destroyed-------*/
- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
   
    if(_allSubscribers.count==0){[_messegeForUser setHidden:NO]; //[self.defaultimage setHidden:YES]; //[self.subscriberOneAudioAdjustBtn setHidden:YES];
        
    }

}//connectionDestroyed
@end

