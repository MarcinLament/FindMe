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
            newUserProfile.displayName = friend["display_name"]! as? String
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
            newSentInvite.recipientEmail = invite["recipient_email"]! as? String
            newSentInvite.status = invite["status"]! as? String
            sentInvitesList.append(newSentInvite)
        }
    }
}

class UserProfile{
    var objectId: String?
    var displayName: String?
}

class FriendRequest{
    var objectId: String?
    var authorName: String?
    var authorProfileId: String?
    var recipientEmail: String?
    var status: String?
}