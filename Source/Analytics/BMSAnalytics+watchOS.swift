/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/


import WatchKit
import BMSCore


public extension Analytics {
    
    
    /**
        Starts a timer to record the length of time the WatchOS app is being used before becoming inactive.
        This event will be recorded and sent to the Analytics console, provided that the `Analytics.enabled` property is set to `true`.

        This should be called in the `ExtensionDelegate applicationDidBecomeActive` method.
     */
    public static func recordApplicationDidBecomeActive() {
        
        BMSAnalytics.logSessionStart()
    }
    
    
    /**
        Ends the timer started by the `Analytics startRecordingApplicationLifecycleEvents` method.
        This event will be recorded and sent to the Analytics console, provided that the `Analytics.enabled` property is set to `true`.

        This should be called in the `ExtensionDelegate applicationWillResignActive` method.
     */
    public static func recordApplicationWillResignActive() {
        
        BMSAnalytics.logSessionEnd()
    }
    
}



// MARK: -


public extension BMSAnalytics {
    
    
    // Create a UUID for the current device and save it to the keychain
    // This is necessary because there is currently no API for programatically retrieving the UDID for watchOS devices
    internal static var uniqueDeviceId: String? {
        
        // First, check if a UUID was already created
        #if swift(>=3.0)
            
            let bmsUserDefaults = UserDefaults(suiteName: Constants.userDefaultsSuiteName)
            guard bmsUserDefaults != nil else {
                Analytics.logger.error(message: "Failed to get an ID for this device.")
                return ""
            }
            
            var deviceId = bmsUserDefaults!.string(forKey: Constants.Metadata.Analytics.deviceId)
            if deviceId == nil {
                deviceId = NSUUID().uuidString
                bmsUserDefaults!.setValue(deviceId, forKey: Constants.Metadata.Analytics.deviceId)
            }
            
        #else
            
            let bmsUserDefaults = NSUserDefaults(suiteName: Constants.userDefaultsSuiteName)
            guard bmsUserDefaults != nil else {
                Analytics.logger.error("Failed to get an ID for this device.")
                return ""
            }
            
            var deviceId = bmsUserDefaults!.stringForKey(Constants.Metadata.Analytics.deviceId)
            if deviceId == nil {
                deviceId = NSUUID().UUIDString
                bmsUserDefaults!.setValue(deviceId, forKey: Constants.Metadata.Analytics.deviceId)
            }
            
        #endif
        
        return deviceId!
    }
    
    
    
    internal static func getWatchOSDeviceInfo() -> (String, String, String) {
        
        var osVersion = "", model = "", deviceId = ""
        
        #if swift(>=3.0)
            let device = WKInterfaceDevice.current()
        #else
            let device = WKInterfaceDevice.currentDevice()
        #endif
        
        osVersion = device.systemVersion
        model = device.model
        deviceId = BMSAnalytics.getDeviceId(from: BMSAnalytics.uniqueDeviceId)
        
        return (osVersion, model, deviceId)
    }
    
}
