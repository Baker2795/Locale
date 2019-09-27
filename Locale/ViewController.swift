//
//  ViewController.swift
//  Locale
//
//  Created by John Baker on 7/10/18.
//  Copyright © 2018 B4k3R. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableViewOutlet: UITableView!
	var indexToPass = 0
	
	//---GET DATA---//
	func getData() {
		let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
		let sort = NSSortDescriptor(key: #keyPath(Location.name), ascending: true)
		fetchRequest.sortDescriptors = [sort]
		do {
			locations = try context.fetch(fetchRequest)
		} catch {
			print("Cannot fetch Expenses")
		}
	}
	
	//---SAVE TO COREDATA---//
	func save(name: String, city: String, state: String, addressString: String, latitude: String, longitude: String, contactName: String, contactNumber: String) {
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		let managedContext =
			DatabaseController.persistentContainer.viewContext
		let entity =
			NSEntityDescription.entity(forEntityName: "Location",
									   in: managedContext)!
		let location = NSManagedObject(entity: entity,
								   insertInto: managedContext)
		location.setValue(name, forKeyPath: "name")
		location.setValue(city, forKey: "city")
		location.setValue(state, forKey: "state")
		location.setValue(latitude, forKey: "latitude")
		location.setValue(longitude, forKey: "longitude")
		location.setValue(contactName, forKey: "contactName")
		location.setValue(contactNumber, forKey: "contactNumber")
		location.setValue(addressString, forKey: "addressString")
		location.setValue(getRandID(), forKey: "locationID")
		do {
			try managedContext.save()
			locations.append(location as! Location)
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	let context = DatabaseController.persistentContainer.viewContext
	var locations: [Location] = []
	
	
	func updateLocation(locationToUpdate: Int64, name: String, city: String, state: String, addressString: String, latitude: String, longitude: String, contactName: String, contactNumber: String) {
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		let managedContext =
			DatabaseController.persistentContainer.viewContext
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
		
		fetchRequest.predicate = NSPredicate(format: "locationID = \(locationToUpdate)")
		
		print(locationToUpdate)
		
		do {
			let results = try context.fetch(fetchRequest) as? [NSManagedObject]
			if results?.count != 0 {
				results![0].setValue(name, forKeyPath: "name")//(name, forKey: "name")
				results![0].setValue(city, forKey: "city")
				results![0].setValue(state, forKey: "state")
				results![0].setValue(latitude, forKey: "latitude")
				results![0].setValue(longitude, forKey: "longitude")
				results![0].setValue(contactName, forKey: "contactName")
				results![0].setValue(contactNumber, forKey: "contactNumber")
				results![0].setValue(addressString, forKey: "addressString")
				results![0].setValue(locationToUpdate, forKey: "locationID")
			}
		}
		catch {
			print("Fetch Failed: \(error)")
		}
		do {
			try context.save()
		}
		catch {
			print("Saving Core Data Failed: \(error)")
		}
	}
	
	func getRandID() -> Int64{
		let randInt = Int64(arc4random_uniform(99999999) + 1)
		return randInt
	}
	
	
	
	func checkIfDuplicate(newLocationID: Int64) -> Bool {
		for location in locations {
			if newLocationID != location.locationID {
				return true
			}
			else {
				return false
			}
		}
		return true
	}
		
	
	
	
	//---SLIDE TO DELETE---//
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let locationToDelete = locations[indexPath.row]
			context.delete(locationToDelete)
			DatabaseController.saveContext()
			getData()
		}
		tableViewOutlet.reloadData()
	}
	
	//---VIEW DID LOAD---//
	override func viewDidLoad() {
		super.viewDidLoad()
		tableViewOutlet.delegate = self
		tableViewOutlet.dataSource = self
		tableViewOutlet.reloadData()
		self.tableViewOutlet.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	//---LOAD TABLE---//
	override func viewWillAppear(_ animated: Bool) {
		getData()
		tableViewOutlet.reloadData()
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
		let location = locations[indexPath.row]

		cell.locationNameLabelOutlet.text = location.name
		cell.cityLabelOutlet.text = location.city
		cell.stateLabelOutlet.text = location.state
		
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		indexToPass = indexPath.row
		performSegue(withIdentifier: "cellDetailViewSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.destination is CellDetailView
		{
			let vc = segue.destination as? CellDetailView
			vc?.selectedIndex = indexToPass
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}


//---CUSTOM CELL---//
class CustomTableViewCell: UITableViewCell {
	@IBOutlet weak var locationNameLabelOutlet: UILabel!
	@IBOutlet weak var cityLabelOutlet: UILabel!
	@IBOutlet weak var stateLabelOutlet: UILabel!
}






//---GL CODES---//

//23069 !! Meadow Wood Ct. Apt 310 !,! Seaford !,! DE !! 19973 !,! United States

//subThoroughFare !! thoroughfare !,! locality !,! administrativeArea !! postalCode !,! isoCountryCode

// country // print("Inside what is in p: \(p?.country )")
// county // print(p?.subAdministrativeArea)
// address number // print(p?.subThoroughfare)
// street name // print(p?.thoroughfare)
// city // print(p?.locality)
// zip code // print(p?.postalCode)
// state // print(p?.administrativeArea)
// country // print(p?.country)
// country code // print(p?.isoCountryCode)
