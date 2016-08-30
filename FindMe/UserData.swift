//
//  UserData.swift
//  FindMe
//
//  Created by Marcin Lament on 08/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
class UserData{
    
    var friendsList: [UserProfile] = [UserProfile]()
    var friendRequestList: [FriendRequest] = [FriendRequest]()
    var sentInvitesList: [FriendRequest] = [FriendRequest]()
    
    init(jsonObject: AnyObject){
        let friends = jsonObject["friends"]! as! [AnyObject]
        for friend in friends{
            let newUserProfile: UserProfile = UserProfile()
            newUserProfile.objectId = friend["objectId"]! as? String
            newUserProfile.displayName = friend["displayName"]! as? String
            friendsList.append(newUserProfile)
        }
        
        let friendRequests = jsonObject["friendRequests"] as! [AnyObject]
        for friendRequest in friendRequests{
            let newFriendRequest: FriendRequest = FriendRequest()
            newFriendRequest.objectId = friendRequest["objectId"]! as? String
            newFriendRequest.authorName = friendRequest["authorName"]! as? String
            newFriendRequest.recipientEmail = friendRequest["recipientEmail"]! as? String
            newFriendRequest.status = friendRequest["status"]! as? String
            
            let authorProfile = friendRequest["authorProfile"]
            
            newFriendRequest.authorProfileId = authorProfile!!["objectId"]! as? String
            friendRequestList.append(newFriendRequest)
        }
        
        let sentInvites = jsonObject["sentInvites"] as! [AnyObject]
        for invite in sentInvites{
            let newSentInvite: FriendRequest = FriendRequest()
            newSentInvite.objectId = invite["objectId"]! as? String
            newSentInvite.authorName = invite["authorName"]! as? String
            newSentInvite.recipientEmail = invite["recipientEmail"]! as? String
            newSentInvite.status = invite["status"]! as? String
            sentInvitesList.append(newSentInvite)
        }
    }
}

class FriendLocationData{
    
    var friendLocationList: [UserProfile] = [UserProfile]()
    
    init(jsonObject: AnyObject){
        let friendProfiles = jsonObject["friendProfiles"]! as! [AnyObject]
        for profile in friendProfiles{
            
            let newUserProfile: UserProfile = UserProfile()
            newUserProfile.objectId = profile["objectId"]! as? String
            newUserProfile.displayName = profile["displayName"]! as? String
            
            let profileLocation = profile["userLocation"]
            if(profileLocation != nil){
                
                let userLocation: UserLocation = UserLocation()
                userLocation.date = profileLocation!!["updatedAt"] as? String
                
                let location = profileLocation!!["location"]
                if(location != nil){
                    userLocation.latitude = location!!["latitude"] as? Double
                    userLocation.longitude = location!!["longitude"] as? Double
                    newUserProfile.userLocation = userLocation
                }
            }
            
            friendLocationList.append(newUserProfile)
        }
    }
}

class UserLocation{
    var date: String?
    var latitude: Double?
    var longitude: Double?
}

class UserProfile{
    var objectId: String?
    var displayName: String?
    var userLocation: UserLocation?
}

class FriendRequest{
    var objectId: String?
    var authorName: String?
    var authorProfileId: String?
    var recipientEmail: String?
    var status: String?
}