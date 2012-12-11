ABGameKitHelper
===============

Objective-C Helper class to ease interaction with Apple&#39;s GameKit API

Should work with all types of Apps, also Cocos2d 1 & 2+

Features:
--
- Show Leaderboards (specify which) / Achievements
- Report Scores to Leaderboards / Report Achievements
- Achievement / Score Caching System
- All saved data is encrypted (AppStore Safe) … no cheating here ;)

____

Tutorial:
--
Getting ABGameKitHelper up and running is fairly easy, here a step by step guide to get you started:

1. Add "GameKit.framework" Library to your Project

2. In your AppDelegate's ..application didFinishLaunchingWithOptions… Method add following code to automatially authenticate player with GameCenter: 

	<code>[[ABGameKitHelper sharedClass] authenticatePlayer];</code>


3. Thats the basic setup, easy huh? Now on to actually interacting with GameCenter:

<strong>Show Leaderboard</strong>

<code>[[ABGameKitHelper sharedClass] showLeaderboard:@"leaderboardID"];</code>

<strong>Show Achievements</strong>

<code>[[ABGameKitHelper sharedClass] showAchievements];</code>

<strong>Report Achievement</strong>

<code>[[ABGameKitHelper sharedClass] reportAchievement:@"achievementID" percentComplete:100];</code>

<strong>Show Notification</strong> (Is only once per completed Achievement)

<code>[[ABGameKitHelper sharedClass] showNotification:@"Notification Title" message:@"Some Message" identifier:@"achievementID"];</code>

<strong>Report Leaderboard Score</strong>

<code>
[[ABGameKitHelper sharedClass] reportScore:2000 forLeaderboard:@"leaderboardID"];
</code>

<strong>!</strong>
If no Internet connection is present during reporting Achievemnts/Leaderboard Scores are automatically cached and reported the next time the Player authenticates (The Code in the AppDelegate)

____

Future:
--
- Mac / Moutain Lion Compatibility

____

License:
--
Copyright (c) 2012 Ablfx (Alexander Blunck)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.