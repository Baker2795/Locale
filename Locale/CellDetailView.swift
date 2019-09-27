//
//  CellDetailView.swift
//  Locale
//
//  Created by John Baker on 8/15/18.
//  Copyright © 2018 B4k3R. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class CellDetailView: UIViewController, MKMapViewDelegate {
	
	//---VARIABLES AND CONSTANTS---//
	let context = DatabaseController.persistentContainer.viewContext
	var locations: [Location] = []
	var settings: [Settings] = []
	
	var selectedIndex = Int()
	var locationToPass = Int64()
	
	var newLat = Double()
	var newLong = Double()
	var newName = String()
	
	//---LOAD DATA---//
	func getData() {
		let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
		let sort = NSSortDescriptor(key: #keyPath(Location.name), ascending: true)
		//let sortDescriptors = [sort]
		fetchRequest.sortDescriptors = [sort]
		do {
			locations = try context.fetch(fetchRequest)
		} catch {
			print("Cannot fetch Expenses")
		}
	}
	
	//---VIEW LEAVE---//
	override func viewWillDisappear(_ animated : Bool) {
		super.viewWillDisappear(animated)
		
		if self.isMovingFromParent {
			navigationController?.navigationItem.hidesBackButton = true
		}
	}
	
	//---VIEW LOAD---//
	override func viewDidLoad() {
		super.viewDidLoad()
		getData()
		let selectedLocation = locations[selectedIndex]
		
		newLat = (selectedLocation.latitude! as NSString).doubleValue
		newLong = (selectedLocation.longitude! as NSString).doubleValue
		newName = (selectedLocation.name!)
		
		locationNameLabelOutlet.text = selectedLocation.name
		addressLabelOutlet.text = selectedLocation.addressString
		contactNameLabelOutlet.text = selectedLocation.contactName
		contactNumberTextView.isEditable = false
		contactNumberTextView.text = selectedLocation.contactNumber
		
		locationToPass = selectedLocation.locationID
		print(selectedLocation.locationID)

		//---LOAD MAP---//
		mapViewOutlet.delegate = self
		//---ADD WAYPOINT---//
		let annotation = MKPointAnnotation()
		let centerCoordinate = CLLocationCoordinate2D(latitude: newLat, longitude:newLong)
		annotation.coordinate = centerCoordinate
		annotation.title = selectedLocation.name
		mapViewOutlet.addAnnotation(annotation)
		//---LOAD AND CENTER MAP---//
		let center = CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
		self.mapViewOutlet.setRegion(region, animated: true)
	}
	
	//---OUTLETS---//
	@IBOutlet weak var mapViewOutlet: MKMapView!
	@IBOutlet weak var locationNameLabelOutlet: UILabel!
	@IBOutlet weak var addressLabelOutlet: UILabel!
	@IBOutlet weak var contactNameLabelOutlet: UILabel!
	@IBOutlet weak var contactNumberTextView: UITextView!
	@IBOutlet weak var openWithButtonOutlet: UIButton!
	
	//TODO: ADD OTHER MAP OPTIONS -- GOOGLE MAPS BELOW
	@IBAction func openWithButtonAction(_ sender: Any) {
		openInMaps()
		//openInGoogleMaps()
	}
	
	//---CREATE MKMAPITEM TO SEND---//
	func createMapItemToShare() -> MKMapItem {
		let theLatitude: CLLocationDegrees = newLat
		let theLongitude: CLLocationDegrees = newLong
		let coordinate = CLLocationCoordinate2DMake(theLatitude,theLongitude)
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
		mapItem.name = newName
		return mapItem
	}

	@IBOutlet weak var
		shareButtonOutlet: UIButton!
	
	//---SHARE LOCATION---//
	@IBAction func shareButtonAction(_ sender: Any) {
		let coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
		let vCard = vCardURL(from: coordinate, with: newName)
		let activityViewController = UIActivityViewController(activityItems: [vCard], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
	
	//---OPEN IN GOOGLE MAPS---//
	func openInGoogleMaps() {
		if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(newLat),\(newLong)&directionsmode=driving") {
			UIApplication.shared.open(url, options: [:])
		}
	}
	
	//---OPEN IN APPLE MAPS---//
	func openInMaps() {
		let theLatitude: CLLocationDegrees = newLat
		let theLongitude: CLLocationDegrees = newLong
		let coordinate = CLLocationCoordinate2DMake(theLatitude,theLongitude)
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
		mapItem.name = newName
		mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
	}
	
	@IBAction func editLocationButton(_ sender: Any) {
		performSegue(withIdentifier: "editLocationSegue", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.destination is EditLocationViewController
		{
			let vc = segue.destination as? EditLocationViewController
			vc?.selectedLocation = locationToPass
			vc?.selectedIndex = selectedIndex
		}
	}
	
	func removeCharactersFromLabel(latOrLong: String) -> String {
		var shortenedLabel = ""
		if latOrLong.first == "-" {
			shortenedLabel = String(latOrLong.prefix(9))
		}
		else {
			shortenedLabel = String(latOrLong.prefix(8))
		}
		return String(shortenedLabel)
	}
}

//---PHONE CALL LINK FIXER---//
extension String {
	enum RegularExpressions: String {
		case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
	}
	
	func isValid(regex: RegularExpressions) -> Bool {
		return isValid(regex: regex.rawValue)
	}
	
	func isValid(regex: String) -> Bool {
		let matches = range(of: regex, options: .regularExpression)
		return matches != nil
	}
	
	func onlyDigits() -> String {
		let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
		return String(String.UnicodeScalarView(filtredUnicodeScalars))
	}
	
	func makeACall() {
		if isValid(regex: .phone) {
			if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
				if #available(iOS 10, *) {
					UIApplication.shared.open(url)
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
	}
}

//---CREATE LOCATION CARD TO SEND---//
extension CellDetailView {
	func vCardURL(from coordinate: CLLocationCoordinate2D, with name: String?) -> URL {
		let vCardFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name!).loc.vcf")
		
		let vCardString = [
			"BEGIN:VCARD",
			"VERSION:4.0",
			"FN:\(name ?? "Shared Location")",
			"item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
			"item1.X-ABLabel:map url",
			"END:VCARD"
			].joined(separator: "\n")
		
		do {
			try vCardString.write(toFile: vCardFileURL.path, atomically: true, encoding: .utf8)
		} catch let error {
			print("Error, \(error.localizedDescription), saving vCard: \(vCardString) to file path: \(vCardFileURL.path).")
		}
		return vCardFileURL
	}
}
