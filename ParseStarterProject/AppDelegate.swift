/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import  GooglePlaces
import GoogleMaps
import Parse
import PushNotifications
import PusherSwift

// If you want to use any of the UI components, uncomment this line
// import ParseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let pushNotifications = PushNotifications.shared
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    @objc
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: String]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        GMSPlacesClient.provideAPIKey("AIzaSyAGnITomPNjwl1FYmrR-0xmamHwLPUs5-A")
        GMSServices.provideAPIKey("AIzaSyAGnITomPNjwl1FYmrR-0xmamHwLPUs5-A")
        
        self.pushNotifications.start(instanceId: "ff9cbfd6-053f-4184-ba70-d5f0fda73b01")
        self.pushNotifications.registerForRemoteNotifications()
    
        Parse.enableLocalDatastore()
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "bde526d929b23f5a4b7c38ac0d8fcaa22f603ef7"
            ParseMutableClientConfiguration.clientKey = "58f73919b988fcc0cf00249e96ffdaf078e5b5b8"
            ParseMutableClientConfiguration.server = "http://ec2-18-222-176-19.us-east-2.compute.amazonaws.com/parse"
        })
        
        Parse.initialize(with: parseConfiguration)

        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        let pusher = Pusher(
            key: "5116ed2572ce0befb684",
            options: options
        )
        
        // subscribe to channel and bind to event
        let channel = pusher.subscribe("littyct")
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print("The message",message)
                }
            }
        })
        
        pusher.connect()

        // ****************************************************************************
        // Uncomment and fill in with your Parse credentials:
        // Parse.setApplicationId("your_application_id", clientKey: "your_client_key")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************

        //PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.hasPublicReadAccess = true
        defaultACL.hasPublicWriteAccess = true

        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)

        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            /*
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
 */
        }

        return true
    }

    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       /* let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()

        PFPush.subscribeToChannel(inBackground: "") { (succeeded, error) in // (succeeded: Bool, error: NSError?) is now (succeeded, error)

            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }*/
        self.pushNotifications.registerDeviceToken(deviceToken) {
            try? self.pushNotifications.subscribe(interest: "orders_" + AppMisc.USER_ID)
            print("Error", Error.self)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handle(userInfo)
        if application.applicationState == UIApplicationState.inactive {
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("User Info: ",userInfo)
    }

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }

    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}
