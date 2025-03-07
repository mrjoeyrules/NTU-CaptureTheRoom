//
//  User.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 13/01/2025.
//
import FirebaseAuth
import Foundation
class UserLocal{
    static var currentUser: UserLocal?
    
    private var _user: FirebaseAuth.User? = nil
    var user: FirebaseAuth.User?{
        get{
            return _user
        }
        set(newUser){
            _user = newUser
        }
    }
    init(username: String) {
            self._username = username
        }
    
    private var _username: String = ""
    var username: String{
        get{
            return _username
        }
        set(newUsername){
            _username = newUsername
        }
    }
    private var _setUpStatus: String = ""
    var setUpStatus: String{
        get{
            return _setUpStatus
        }
        set(newSetUpStatus){
            _setUpStatus = newSetUpStatus
        }
    }
    private var _xpStored: CGFloat = 0
    var xpStored: CGFloat{
        get{
            return _xpStored
        }
        set(newXpStored){
            _xpStored = newXpStored
        }
    }
    private var _roomsCapped: Int = 0
    var roomsCapped: Int{
        get{
            return _roomsCapped
        }
        set(newRoomscapped){
            _roomsCapped = newRoomscapped
        }
    }
    private var _totalSteps: Int = 0
    var totalSteps: Int{
        get{
            return _totalSteps
        }
        set(newTotalSteps){
            _totalSteps = newTotalSteps
        }
    }
    
    private var _level: Int = 1
    var level: Int{
        get{
            return _level
        }
        set(newLevel){
            _level = newLevel
        }
    }
    private var _xp: CGFloat = 0
    var xp: CGFloat{
        get{
            return _xp
        }
        set(newXp){
            _xp = newXp
        }
    }
    private var _team: String = ""
    var team: String{
        get{
            return _team
        }
        set(newTeam){
            _team = newTeam
        }
    }
}
