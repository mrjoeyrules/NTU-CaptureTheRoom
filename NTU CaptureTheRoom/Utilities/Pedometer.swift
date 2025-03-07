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
    @Published var totalSteps: Int = 0
    private var sessionSteps: Int = 0
    private var trackingActive = false
    
    override init(){
        super.init()
        fetchSavedSteps()
        startTrackingSteps()
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void){
        guard CMMotionActivityManager.isActivityAvailable() else{
            print("Motion activity tracking is not avaiable on this device")
            completion(false)
            return
        }
        motionActivityManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
            if let error = error{
                print("Motion permission denied: \(error.localizedDescription)")
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    
    func startTrackingSteps(){
        
        requestPermission { granted in
            guard granted else{return}
            guard CMPedometer.isStepCountingAvailable() else{
                print("Pedometer not available on this device")
                return
            }
            self.fetchSavedSteps()
            self.trackingActive = true
            
            self.pedometer.startUpdates(from: Date()) { data, error in
                if let error = error{
                    print("Pedometer error: \(error.localizedDescription)")
                    return
                }
                if let stepData = data?.numberOfSteps {
                    DispatchQueue.main.async{
                        self.sessionSteps = stepData.intValue
                        self.totalSteps += self.sessionSteps
                        self.saveStepsToFireStore()
                    }
                }
            }
        }
    }
    
    func stopTracking(){
        trackingActive = false
        pedometer.stopUpdates()
        saveStepsToFireStore()
    }
    private func fetchSavedSteps(){
        guard let user = Auth.auth().currentUser else { return }
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            if let error = error{
                print("error fetching saved steps: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                self.totalSteps = document.data()?["totalsteps"] as? Int ?? 0
                UserLocal.currentUser?.totalSteps = self.totalSteps
            }
        }
    }
    
    private func saveStepsToFireStore(){
        guard let user = Auth.auth().currentUser else { return }
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        userRef.setData(["totalsteps": totalSteps], merge: true){ error in
            DispatchQueue.main.async{
                if let error = error{
                    print("Error saving steps: \(error.localizedDescription)")
                }
            }
        }
    }
}

