//
//  ABGameKitHelper.m
//  Pastry Panic
//
//  Created by Alexander Blunck on 27.02.12.
//  Copyright (c) 2012 Ablfx. All rights reserved.
//

#import "ABGameKitHelper.h"
#import "AppDelegate.h"
#import "NSData+AES256.h"

#define APPNAME @"MyAppName"
#define AESKEY @"RandomKeyHere"

@implementation ABGameKitHelper

@synthesize isAuthenticated, isActivated;

//Singleton Setup
+ (id)sharedClass
{
    static dispatch_once_t pred;
    static ABGameKitHelper *gameKit = nil;
    
    dispatch_once(&pred, ^{ gameKit = [[self alloc] init]; });
    return gameKit;
}

-(void) authenticatePlayer {
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    [player authenticateWithCompletionHandler:^(NSError *error) {
        if (player.isAuthenticated) {
            isAuthenticated = YES;
            NSLog(@"GK - Player successfully authenticated");
            //Report possible cached Achievements / Scores
            [self reportCachedAchievements];
            [self reportCachedScores];
        }
        
        if (error != nil) {
            NSLog(@"GK - Error in authenticatePlayer - Error: %@", error);
        }
    }];
}

-(void) showLeaderboard:(NSString*)leaderboardID {
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    if (leaderboardID) {
        leaderboardViewController.category = leaderboardID;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [[keyWindow rootViewController] presentModalViewController:leaderboardViewController animated:YES];
}

-(void) showAchievements {
    GKAchievementViewController *achievementsViewController = [[GKAchievementViewController alloc] init];
    achievementsViewController.achievementDelegate = self;
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [[keyWindow rootViewController] presentModalViewController:leaderboardViewController animated:YES];
}

-(void) reportScore:(int)score forLeaderboard:(NSString*)leaderboardName {
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboardName] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil){
            NSLog(@"GK - Error during reportScore: - Error: %@", error);
            [self cacheScore:scoreReporter];
        } else {
            NSLog(@"GK - Score:%i Leaderboard:%@ reported", score, leaderboardName);
        }
    }];
}

-(void) cacheScore:(GKScore*)score {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedscores"];
    id achievements = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    NSMutableArray *scoresArray = [[NSMutableArray alloc] initWithArray:achievements];
    
    //Add new achievement to Array
    [scoresArray addObject:score];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:scoresArray];
    [self saveData:newArrayData withKey:@"cachedscores"];
    
    NSLog(@"Cached Score: %lld for LB:%@", score.value, score.category);
}

-(void) reportCachedScores {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedscores"];
    id achievements = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    NSMutableArray *scoresArray = [[NSMutableArray alloc] initWithArray:achievements];
    
    NSLog(@"Number of cached scores: %i", scoresArray.count);
    
    for (GKScore *score in scoresArray) {
        
        [score reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"GK - Error during reportCachesScores: - Error: %@", error);
                [self cacheScore:score];
            } else {
                NSLog(@"GK - CachedScore:%lld Leaderboard:%@ reported", score.value, score.category);
            }
        }];
        
    }
    
    [self deleteScoresFromCache];
    
}

-(void) deleteScoresFromCache  {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedscores"];
    id scores = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    NSMutableArray *scoresArray = [[NSMutableArray alloc] initWithArray:scores];
    
    [scoresArray removeAllObjects];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:scoresArray];
    [self saveData:newArrayData withKey:@"cachedscores"];
}

-(void) reportAchievement:(NSString*)identifier percentComplete:(float)percent {
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement) {
        achievement.percentComplete = percent;
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"GK - Error during reportAchievement: - Error: %@", error);
                //Caching solution
                [self cacheAchievement:achievement];
                
            } else {
                NSLog(@"GK - Achievement:%@ Percent:%f reported", identifier, percent);
                //Locally report Achievement as completed
                if (percent == 100) {
                    [self saveBool:YES withKey:identifier];
                }
            }
            
        }];
    }
    
}

-(void) cacheAchievement:(GKAchievement*)achievement {
    NSLog(@"Cached Achievement: %@", achievement.identifier);
    
    NSString *identifier = achievement.identifier;
    double percentage = achievement.percentComplete;
    
    //Retrieve Array of all Cached Achievements
    NSData *loadedDicData = [self loadDataForKey:@"cachedachievements"];
    id achievements = [NSKeyedUnarchiver unarchiveObjectWithData:loadedDicData];
    NSMutableDictionary *achievementDic = [[NSMutableDictionary alloc] initWithDictionary:achievements];
    
    //Add new achievement to Array
    [achievementDic setObject:[NSNumber numberWithDouble:percentage] forKey:identifier];
    
    //Save Array back to presitent storage
    NSData *newDicData = [NSKeyedArchiver archivedDataWithRootObject:achievementDic];
    
    [self saveData:newDicData withKey:@"cachedachievements"];
}

-(void) reportCachedAchievements {
    //Retrieve Array of all Cached Achievements
    NSData *loadedDicData = [self loadDataForKey:@"cachedachievements"];
    id achievements = [NSKeyedUnarchiver unarchiveObjectWithData:loadedDicData];
    NSMutableDictionary *achievementDic = [[NSMutableDictionary alloc] initWithDictionary:achievements];
    
    NSLog(@"Number of cached Achievements: %i", achievementDic.count);
    
    [achievementDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *identifier = key;
        double percentage = [obj doubleValue];
        
        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        achievement.percentComplete = percentage;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"GK - Error during reportCachedAchievement: - Error: %@", error);
                
            } else {
                NSLog(@"GK - CachedAchievement:%@ Percent:%f reported", identifier, percentage);
                //Locally report Achievement as completed
                if (achievement.percentComplete == 100) {
                    [self saveBool:YES withKey:identifier];
                }
                //Add to deleteArray
                [self deleteAchievementFromCache:identifier];
            }
            
        }];
    }];
}

-(void) deleteAchievementFromCache:(NSString*)identifier {
    NSData *loadedDicData = [self loadDataForKey:@"cachedachievements"];
    id achievements = [NSKeyedUnarchiver unarchiveObjectWithData:loadedDicData];
    NSMutableDictionary *achievementDic = [[NSMutableDictionary alloc] initWithDictionary:achievements];
    
    [achievementDic removeObjectForKey:identifier];
    
    NSLog(@"post deletion count: %i", achievementDic.count);
    
    //Save Array back to presitent storage
    NSData *newDicData = [NSKeyedArchiver archivedDataWithRootObject:achievementDic];
    [self saveData:newDicData withKey:@"cachedachievements"];
}

-(void) resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"GK - Error during resetAchievements: - Error: %@", error);
        }
    }];
}

-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)identifier {
    //Show notification only if it hasn't been achieved before
    if (![self loadBoolForKey:identifier]) {
        [GKNotificationBanner showBannerWithTitle:title message:message completionHandler:^{
            //
        }];
    }
}

#pragma mark GK Delegate Methods
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


#pragma mark Data Persistence Methods

-(NSString*) getBinaryPath {
    
    NSString *returnString;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullFileName = [NSString stringWithFormat:@"%@_ABGameKitHelper.absave", APPNAME];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fullFileName]; 
    returnString = path;
    
    //Shouldn't happen:
    return returnString;
}

-(void) saveData:(NSData *)data withKey:(NSString *)key {
    //Check if file exits, if so init Dictionary with it's content, otherwise allocate new one
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self getBinaryPath]];
    NSMutableDictionary *tempDic;
    if (fileExists == NO) {
        tempDic = [[NSMutableDictionary alloc] init];
    } else {
        NSData *binaryFile = [NSData dataWithContentsOfFile:[self getBinaryPath]];
        NSData *dataKey = [[NSString stringWithString:AESKEY] dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decryptedData = [binaryFile decryptedWithKey:dataKey];
        tempDic = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
    }
    
    //Populate Dictionary with to save value/key and write to file
    [tempDic setObject:data forKey:key];
    //[tempDic writeToFile:[self getPath:fileName] atomically:YES];
    
    NSData *dicData = [NSKeyedArchiver archivedDataWithRootObject:tempDic];
    
    NSData *dataKey = [[NSString stringWithString:AESKEY] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [dicData encryptedWithKey:dataKey];
    
    [encryptedData writeToFile:[self getBinaryPath] atomically:YES];
    
    //Release allocated Dictionary
    //[tempDic release];
}

-(NSData*) loadDataForKey:(NSString*)key {
    NSData *binaryFile = [NSData dataWithContentsOfFile:[self getBinaryPath]];
    NSData *dataKey = [[NSString stringWithString:AESKEY] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = [binaryFile decryptedWithKey:dataKey];
    
    NSMutableDictionary *tempDic = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
    NSData *loadedData = [tempDic objectForKey:key];
    
    //[tempDic release];
    
    return loadedData;
}

-(void) saveBool:(BOOL) boolean withKey:(NSString*) key {
    NSNumber *boolNumber = [NSNumber numberWithBool:boolean];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:boolNumber];
    [self saveData:data withKey:key];
}

-(BOOL) loadBoolForKey:(NSString*) key {
    NSData *loadedData = [self loadDataForKey:key];
    NSNumber *boolean;
    if (loadedData != NULL) {
        boolean = [NSKeyedUnarchiver unarchiveObjectWithData:loadedData];
    } else {
        boolean = [NSNumber numberWithBool:NO];
    }
    return [boolean boolValue];
}

-(void) saveINT:(int) number withKey:(NSString*) key{
    NSNumber *numberObject = [NSNumber numberWithInt:number];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:numberObject];
    [self saveData:data withKey:key];
}
-(int) loadINTForKey:(NSString*) key{
    NSData *loadedData = [self loadDataForKey:key];
    NSNumber *loadedNumberObject;
    if (loadedData != NULL) {
        loadedNumberObject = [NSKeyedUnarchiver unarchiveObjectWithData:loadedData];
    } else {
        loadedNumberObject = [NSNumber numberWithInt:0];
    }
    //Convert NSNumber object back to int
    int loadedNumber = (int) [loadedNumberObject intValue];
    return loadedNumber;
}

@end