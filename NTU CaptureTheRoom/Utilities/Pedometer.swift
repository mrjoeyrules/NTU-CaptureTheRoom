//
//  Pedometer.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import CoreMotion
import FirebaseFirestore

// step tracker using pedometer
class StepTrackerManager: NSObject, ObservableObject {
    private let pedometer = CMPedometer()
    private let motionActivityManager = CMMotionActivityManager()
    @Published var totalSteps: Int = 0 // users total steps
    private var sessionSteps: Int = 0 // session steps
    private var trackingActive = false
    
    override init(){
        super.init()
        fetchSavedSteps() // on initialisation fetch the users saved steps and start tracking steps
        startTrackingSteps()
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void){ // request permission to track motion activity
        guard CMMotionActivityManager.isActivityAvailable() else{
            print("Motion activity tracking is not avaiable on this device")
            completion(false)
            return
        }
        // request permission by checking previous motion activity
        motionActivityManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
            if let error = error{
                print("Motion permission denied: \(error.localizedDescription)")
                completion(false)
            }else{
                completion(true) // permission granted
            }
        }
    }
    
    
    func startTrackingSteps(){
        
        requestPermission { granted in
            guard granted else{return} // exit if permission is not granted
            
            guard CMPedometer.isStepCountingAvailable() else{ // is pedometer actually available on the device
                print("Pedometer not available on this device")
                return
            }
            self.fetchSavedSteps()   // load previous step data from FS
            self.trackingActive = true // set tracking flag to true
            
            self.pedometer.startUpdates(from: Date()) { data, error in  // start getting step count updates from pedometer
                if let error = error{
                    print("Pedometer error: \(error.localizedDescription)")
                    return
                }
                // get the number of steps and update FS
                if let stepData = data?.numberOfSteps {
                    DispatchQueue.main.async{
                        self.sessionSteps = stepData.intValue // store the session steps
                        self.totalSteps += self.sessionSteps // set total steps to add on sessions steps
                        self.saveStepsToFireStore() // save values to FS
                    }
                }
            }
        }
    }
    // Stops tracking. I only want to track when user is on maps page
    func stopTracking(){
        trackingActive = false // flag to false
        pedometer.stopUpdates() // stop revieing pedometer updates
        saveStepsToFireStore() // save to FS
    }
    private func fetchSavedSteps(){
        guard let user = Auth.auth().currentUser else { return } // Check if user is authed to access FS
        // Get doc reference
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        
        // get the document
        userRef.getDocument { document, error in
            if let error = error{
                print("error fetching saved steps: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists { // if doc exists get totalsteps value
                self.totalSteps = document.data()?["totalsteps"] as? Int ?? 0
                UserLocal.currentUser?.totalSteps = self.totalSteps // set total steps in userlocal to the value of totalsteps
            }
        }
    }
    
    private func saveStepsToFireStore(){
        guard let user = Auth.auth().currentUser else { return } // check if user is authed to access FS
        let userRef = Firestore.firestore().collection("users").document(user.uid) // GET DOC REF
        
        userRef.setData(["totalsteps": totalSteps], merge: true){ error in // set the data for total steps value and allow for updated using merge flag
            DispatchQueue.main.async{
                if let error = error{ // if error print error 
                    print("Error saving steps: \(error.localizedDescription)")
                }
            }
        }
    }
}

