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
    private var _level: Int = 0
    var level: Int{
        get{
            return _level
        }
        set(newLevel){
            _level = newLevel
        }
    }
    private var _xp: Int = 0
    var xp: Int{
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
    private var _currentLat: Double = 0
    var currentLat: Double{
        get{
            return _currentLat
        }
        set(newCurrentLat){
            _currentLat = newCurrentLat
        }
    }
    private var _currentLon: Double = 0
    var currentLon: Double{
        get{
            return _currentLon
        }
        set(newCurrentLon){
            _currentLon = newCurrentLon
        }
    }
}
