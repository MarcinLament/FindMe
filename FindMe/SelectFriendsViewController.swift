//
//  SelectFriendsViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 25/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SelectFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var friendsList: [PFObject]?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func done(sender: AnyObject) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(friendsList == nil) {return 0}
        else{ return (friendsList?.count)!}
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
//        if (cell != nil){
//            cell = UITableViewCell(style: UITableViewCellStyle.Basic,
//                                   reuseIdentifier: "TableCell")
//        }
        
        let displayName = friendsList![indexPath.row]["displayName"] as! String
        cell!.textLabel!.text = displayName

        return cell!
//        return
    }

    
}