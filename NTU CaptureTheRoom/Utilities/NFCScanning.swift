//
//  NFCScanning.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025.
//

import SwiftUI
import CoreNFC
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

// nfc setup
class NFCScanner: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?

    func beginScanning(completion: @escaping (String) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion("NFC reading not available on this device")
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your device near the rooms NFC tag" // default message when loading the iOS nfc scanning tool
        session?.begin() // start the nfc session

        scanCompletion = completion
    }

    private var scanCompletion: ((String) -> Void)?

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let rawString = String(data: record.payload, encoding: .utf8) {
                    print("scanned data: \(rawString)")
                    parseNFCData(rawString) { message in
                        self.scanCompletion?(message)
                    }
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        print("NFC scanning failed: \(error.localizedDescription)")
    }

    func saveUserStats() {
        guard let user = Auth.auth().currentUser else { // get current user for fs auth
            print("User not authed")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid) // get doc from users collection with the document name being the users uid

        userRef.getDocument { _, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            let updatedXp = UserLocal.currentUser?.xp ?? 0
            let updatedLevel = UserLocal.currentUser?.level ?? 0
            let roomsCapped = UserLocal.currentUser?.roomsCapped ?? 0
            let totalXp = UserLocal.currentUser?.totalXp ?? 0

            userRef.updateData([
                "xp": updatedXp, // update data in firestore with new data as this is ran after add xp
                "level": updatedLevel,
                "roomscapped": roomsCapped,
                "totalxp": totalXp
            ]) { error in
                if let error = error {
                    print("Error updating xp or level: \(error.localizedDescription)")
                } else {
                    print("XP and level successfully updated in Firestore")
                    UserLocal.currentUser?.xpStored = 0 // Reset stored XP
                }
            }
        }
    }

    private func parseNFCData(_ rawData: String, completion: @escaping (String) -> Void) { // nfc data manipulation
        let cleanedData = rawData.filter { $0.isASCII && $0.isLetter || $0.isNumber || $0 == "=" || $0 == ";" } // clearing hidden data on tag text
        let sanitizedData = cleanedData.replacingOccurrences(of: "en", with: "") // remove language encoding
        let keyValuePairs = sanitizedData.split(separator: ";") // split data if there is a semicolon used for testing multiple data
        var parsedData: [String: String] = [:]

        for pair in keyValuePairs {
            let components = pair.split(separator: "=", maxSplits: 1)
            if components.count == 2 {
                let key = String(components[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                parsedData[key] = value // splits room and name of room in nfc string on nfc tag. nfc tages consist of room=[ROOMNAME] this filters out the room= and just leaves the room name
            }
        }

        guard let roomName = parsedData["room"] else {
            print("NFC Data incorect room not found")
            return // if there isnt any data when the parsedData with the key room then data is incorrect
        }

        let db = Firestore.firestore() // updates room info in rooms collection
        let roomRef = db.collection("Rooms").document(roomName) // get doc from rooms collection with the roomname
        roomRef.getDocument { document, error in
            if let error = error {
                print("Error fetching room doc: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Room \(roomName) not found in firestore")
                return
            }

            guard let user = Auth.auth().currentUser, // get user to allow use in fs
                  let username = UserLocal.currentUser?.username,
                  let team = UserLocal.currentUser?.team else {
                print("User not authed or missing data")
                return
            }

            let currentOwner = document.data()?["userowner"] as? String ?? "" // get the current owner from the room

            if currentOwner == username { // if user already owns this room return an alert
                print("User already owns this room")
                completion("You already own this room")
                return
            }

            roomRef.updateData([ // update the userowner and team owner
                "userowner": username,
                "teamowner": team,
            ]) { error in
                if let error = error {
                    print("Failed to update room: \(error.localizedDescription)")
                    completion("Failed to claim room")
                } else {
                    UserLocal.currentUser?.totalXp += 20
                    UserLocal.currentUser?.xpStored += 20 // add 20 xp to the xp stored
                    print("Room successfully updated")
                    
                    let maxXp: CGFloat = 200 // max xp per level is 200
                    var currentXp = UserLocal.currentUser?.xp ?? 0
                    let storedXp = UserLocal.currentUser?.xpStored ?? 0
                    let totalXp = currentXp + storedXp
                    
                    
                    if totalXp >= maxXp {
                        let overflowXp = totalXp - maxXp // XP carried over to next level
                        let levelsGained = Int(totalXp / maxXp) // How many levels to increase

                        UserLocal.currentUser?.level += levelsGained
                        UserLocal.currentUser?.xp = overflowXp // XP left after leveling up
                    } else {
                        UserLocal.currentUser?.xp = totalXp
                    }
                    UserLocal.currentUser?.roomsCapped += 1
                    self.saveUserStats()

                    UserLocal.currentUser?.xpStored = 0
                    completion("Successfully claimed \(roomName) for \(team)")
                }
            }
        }
    }
}
