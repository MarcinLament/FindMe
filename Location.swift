//
//  Location.swift
//  
//
//  Created by Marcin Lament on 04/09/2016.
//
//

import Foundation
import CoreData


class Location: NSManagedObject {

    convenience init(userId: String, date: NSDate, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Location", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.userId = userId
            self.date = date
            self.latitude = latitude
            self.longitude = longitude
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
    class func fetchAllLocations(userId: String, completionHandler: ( fetchError: NSErrorPointer, fetchedLocations: [ Location ]? ) -> Void )
    {
        let fetchError: NSErrorPointer = nil
        let locationFetchRequest = NSFetchRequest( entityName: "Location" )
        locationFetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        let locations: [Location]?
        do{
            locations = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(locationFetchRequest) as? [ Location ]
        }catch{
            completionHandler(fetchError: fetchError, fetchedLocations: nil)
            return
        }
        
        return ( locations!.count > 0 ) ?
            completionHandler( fetchError: nil, fetchedLocations: locations ) :
            completionHandler( fetchError: nil, fetchedLocations: nil )
    }
    
    class func fetchLatestLocation(userId: String, completionHandler: ( fetchError: NSErrorPointer, fetchedLocation: Location? ) -> Void )
    {
        let fetchError: NSErrorPointer = nil
        let locationFetchRequest = NSFetchRequest( entityName: "Location" )
        locationFetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        locationFetchRequest.fetchLimit = 1
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        locationFetchRequest.sortDescriptors = sortDescriptors
        
        var location: Location?
        do{
            let locations = try (CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(locationFetchRequest) as? [Location])!
            if(locations.count > 0){
                location = locations[0]
            }
        }catch{
            completionHandler(fetchError: fetchError, fetchedLocation: nil)
            return
        }
        
        completionHandler( fetchError: nil, fetchedLocation: location )
    }
}
