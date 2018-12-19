//
//  NewLocationViewController.swift
//  Locale
//
//  Created by John Baker on 8/15/18.
//  Copyright © 2018 B4k3R. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class NewLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
	
	let locationManager = CLLocationManager()
	
	//---VIEW LOAD---//
	override func viewDidLoad() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		mapKitOutlet.delegate = self
		phoneInputOutlet.delegate = self
		
		super.viewDidLoad()
	}
	
	//---VARIABLES---//
	let vc = ViewController()
	let currentDate = Date()
	var dateTrialEnds = Date()
	var name = ""
	var timeRemaining = 1
	var latitude = 2.2
	var longitude = 2.2
	
	//---VARIABLES TO SAVE---//
	var latToSave = ""
	var longToSave = ""
	var locationName = ""
	var contactName = ""
	var contactNumber = ""
	var cityToSave = ""
	var stateToSave = ""
	var addressStringToSave = ""
	
	//---GET USER LOCATION---//
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last as! CLLocation
		if location == locations.last {
			latitude = location.coordinate.latitude
			longitude = location.coordinate.longitude
			latitudeTextFieldOutlet.text = String(location.coordinate.latitude)
			latToSave = String(location.coordinate.latitude)
			longitudeTextFieldOutlet.text = String(location.coordinate.longitude)
			longToSave = String(location.coordinate.longitude)
		}
		updateMap(mapLat: latitude, mapLong: longitude)
		
		getPlacemark(forLocation: location) {
			(originPlacemark, error) in
			if let err = error {
				print(err)
			} else if let placemark = originPlacemark {
				//subThoroughFare !! thoroughfare !,! locality !,! administrativeArea !! postalCode
				self.addressStringToSave = self.formatAddress(addressNumber: placemark.subThoroughfare!, streetName: placemark.thoroughfare!, city: placemark.locality!, state: placemark.administrativeArea!, zip: placemark.postalCode!)
				self.cityToSave = placemark.locality!
				self.stateToSave = placemark.administrativeArea!
				
				//Update Text Fields
				self.streetAddress1Outlet.text = ("\(placemark.subThoroughfare as! String) \(placemark.thoroughfare as! String)")
				self.cityOutlet.text = ("\(placemark.locality as! String)")
				self.stateOutlet.text = ("\(placemark.administrativeArea as! String)")
				self.zipOutlet.text = ("\(placemark.postalCode as! String)")
			}
		}
	}
	
	//---CHANGE FIELDS IF GET LOCATION FAIL---//
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to find user's location: \(error.localizedDescription)")
		latitudeLabelOutlet.isHidden = true
		longitudeLabelOutlet.isHidden = true
		latitudeTextFieldOutlet.isHidden = true
		longitudeTextFieldOutlet.isHidden = true
		latitudeTextFieldOutlet.isEnabled = false
		longitudeTextFieldOutlet.isEnabled = false
		
		streetAddress1Outlet.isHidden = false
		streetAddress1Outlet.isEnabled = true
		streetAddress2Outlet.isHidden = false
		streetAddress2Outlet.isEnabled = true
		cityOutlet.isHidden = false
		cityOutlet.isEnabled = true
		stateOutlet.isHidden = false
		stateOutlet.isEnabled = true
		zipOutlet.isHidden = false
		zipOutlet.isEnabled = true
	}
	
	//---UPDATE MAP---//
	func updateMap(mapLat: Double, mapLong: Double) {
		let center = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
		self.mapKitOutlet.setRegion(region, animated: true)
		//--Add Waypoint--//
		let annotation = MKPointAnnotation()
		let centerCoordinate = CLLocationCoordinate2D(latitude: mapLat, longitude:mapLong)
		annotation.coordinate = centerCoordinate
		mapKitOutlet.addAnnotation(annotation)
	}
	
	//---LINKED OUTLETS & ACTIONS---//
	@IBOutlet weak var mapKitOutlet: MKMapView!
	
	@IBOutlet weak var latitudeLabelOutlet: UILabel!
	@IBOutlet weak var latitudeTextFieldOutlet: UITextField!
	@IBAction func latitudeTextFieldAction(_ sender: Any) {
		if latitudeTextFieldOutlet.text! != "" {
			if let inputLat = String(latitudeTextFieldOutlet.text!).doubleValue {
				latToSave = String(inputLat)
				latitude = inputLat
				updateMap(mapLat: latitude, mapLong: longitude)
			}
			else {
				print("not a valid latitude input")
			}
		}
		else {
			print("please input a latitude that is not empty")
		}
	}
	
	@IBOutlet weak var longitudeLabelOutlet: UILabel!
	@IBOutlet weak var longitudeTextFieldOutlet: UITextField!
	@IBAction func longitudeTextFieldAction(_ sender: Any) {
		if longitudeTextFieldOutlet.text! != "" {
			if let inputLong = String(longitudeTextFieldOutlet.text!).doubleValue {
				longToSave = String(inputLong)
				longitude = inputLong
				updateMap(mapLat: latitude, mapLong: longitude)
			}
			else {
				print("not a valid latitude input")
			}
		}
		else {
			print("please input a latitude that is not empty")
		}
	}
	
	@IBOutlet weak var streetAddress1Outlet: UITextField!
	@IBAction func streetAddress1Action(_ sender: Any) {
		formatInputtedAddress()
	}
	
	@IBOutlet weak var streetAddress2Outlet: UITextField!
	@IBAction func streetAddress2Action(_ sender: Any) {
		formatInputtedAddress()
	}
	
	@IBOutlet weak var cityOutlet: UITextField!
	@IBAction func cityAction(_ sender: Any) {
		formatInputtedAddress()
		cityToSave = cityOutlet.text!
	}
	
	@IBOutlet weak var stateOutlet: UITextField!
	@IBAction func stateAction(_ sender: Any) {
		formatInputtedAddress()
		stateToSave = stateOutlet.text!
	}
	
	@IBOutlet weak var zipOutlet: UITextField!
	@IBAction func zipAction(_ sender: Any) {
		formatInputtedAddress()
	}
	
	@IBOutlet weak var nameTextFieldOutlet: UITextField!
	@IBAction func nameTextFieldAction(_ sender: Any) {
		locationName = String(nameTextFieldOutlet.text!)
	}
	
	@IBOutlet weak var contactNameOutlet: UITextField!
	@IBAction func contactNameAction(_ sender: Any) {
		contactName = String(contactNameOutlet.text!)
	}
	
	@IBOutlet weak var phoneInputOutlet: UITextField!
	@IBAction func phoneInputAction(_ sender: Any) {
		contactNumber = String(phoneInputOutlet.text!)
	}
	
	@IBOutlet weak var saveButtonOutlet: UIButton!
	@IBAction func saveButton(_ sender: Any) {
		ViewController().save(name: locationName, city: cityToSave, state: stateToSave, addressString: addressStringToSave, latitude: latToSave, longitude: longToSave, contactName: contactName, contactNumber: contactNumber)
	}
	
	//---CONVERT COORDINATES TO ADDRESS---//
	func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
		let geocoder = CLGeocoder()
		geocoder.reverseGeocodeLocation(location, completionHandler: {
			placemarks, error in
			
			if let err = error {
				completionHandler(nil, err.localizedDescription)
			} else if let placemarkArray = placemarks {
				if let placemark = placemarkArray.first {
					completionHandler(placemark, nil)
				} else {
					completionHandler(nil, "Placemark was nil")
				}
			} else {
				completionHandler(nil, "Unknown error")
			}
		})
	}

	//---CONVERT ADDRESS TO COORDINATES---//
	func convertAddressToCoordinates(addressToConvert: String){
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressToConvert, completionHandler: {(placemarks, error) -> Void in
			if((error) != nil){
				print("Error", error)
			}
			if let placemark = placemarks?.first {
				let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
				coordinates.latitude
				coordinates.longitude
				print("lat", coordinates.latitude)
				print("long", coordinates.longitude)
				
				self.latToSave = String(coordinates.latitude)
				self.longToSave = String(coordinates.longitude)
				
				self.updateMap(mapLat: coordinates.latitude, mapLong: coordinates.longitude)
				
			}
		})
	}

	//---LOCATION FORMATTING EXAMPLE---//
	//---subThoroughFare !! thoroughfare !,! locality !,! administrativeArea !! postalCode !,! isoCountryCode
	
	//---FORMAT ADDRESS FROM COORDINATES---//
	func formatAddress(addressNumber: String, streetName: String, city: String, state: String, zip: String) -> String {
		let formattedAddress = String("\(addressNumber) \(streetName), \n\(city), \(state) \(zip)")
		print(formattedAddress)
		addressStringToSave = formattedAddress
		return formattedAddress
	}
	
	//---FORMAT ADDRESS FROM INPUT---//
	func formatInputtedAddress() {
		let formattedAddress = ("\(streetAddress1Outlet.text!) \(streetAddress2Outlet.text!), \n\(cityOutlet.text!), \(stateOutlet.text!) \(zipOutlet.text!)")
		print(formattedAddress)
		addressStringToSave = formattedAddress
		convertAddressToCoordinates(addressToConvert: formattedAddress)
	}

	//---FORMAT PHONE FIELD---//
	func textField(_ phoneInputOutlet: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var fullString = phoneInputOutlet.text ?? ""
		fullString.append(string)
		if range.length == 1 {
			phoneInputOutlet.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
		} else {
			phoneInputOutlet.text = format(phoneNumber: fullString)
		}
		return false
	}
	
	func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
		guard !phoneNumber.isEmpty else { return "" }
		guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
		let r = NSString(string: phoneNumber).range(of: phoneNumber)
		var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
		if number.count > 10 {
			let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
			number = String(number[number.startIndex..<tenthDigitIndex])
		}
		if shouldRemoveLastDigit {
			let end = number.index(number.startIndex, offsetBy: number.count-1)
			number = String(number[number.startIndex..<end])
		}
		if number.count < 7 {
			let end = number.index(number.startIndex, offsetBy: number.count)
			let range = number.startIndex..<end
			number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
		} else {
			let end = number.index(number.startIndex, offsetBy: number.count)
			let range = number.startIndex..<end
			number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
		}
		return number
	}
}

extension String {
	var doubleValue: Double? {
		return Double(self)
	}
	var floatValue: Float? {
		return Float(self)
	}
	var integerValue: Int? {
		return Int(self)
	}
}
