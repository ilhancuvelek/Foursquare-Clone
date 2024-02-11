//
//  PlaceDetailViewController.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 4.02.2024.
//

import UIKit
import MapKit
import Firebase

class PlaceDetailViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeNameText: UITextField!
    @IBOutlet weak var placeTypeText: UITextField!
    @IBOutlet weak var placeAtmosphereText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var selectedPlaceId=""
    var chosenLatitude = Double()
    var chosenLongitude = Double()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClicked))
        
        
        getPlaceById()
        mapView.delegate = self
    }

    func getPlaceById() {
        let firestore = Firestore.firestore()

        firestore.collection("Places").document(selectedPlaceId).addSnapshotListener { snapShot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if snapShot != nil {
                    if let data = snapShot?.data() {
                        if let placeName = data["placeName"] as? String {
                            self.placeNameText.text = placeName
                        }

                        if let placeType = data["placeType"] as? String {
                            self.placeTypeText.text = placeType
                        }

                        if let placeAtmosphere = data["placeAtmosphere"] as? String {
                            self.placeAtmosphereText.text = placeAtmosphere
                        }
                        if let latitude = data["latitude"] as? String {
                            if let doubleLatitude=Double(latitude){
                                self.chosenLatitude = doubleLatitude
                            }
                            
                        }
                        if let longitude = data["longitude"] as? String {
                            if let doubleLongtitude=Double(longitude){
                                self.chosenLongitude = doubleLongtitude
                            }
                        }
                        if let imageUrl = data["imageURL"] as? String {
                            // Assuming you have a function to load the image from the URL
                            self.loadImage(from: imageUrl)
                        }
                        // MAPS

                        let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)

                        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)

                        let region = MKCoordinateRegion(center: location, span: span)

                        self.mapView.setRegion(region, animated: true)

                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = self.placeNameText.text!
                        annotation.subtitle = self.placeTypeText.text!
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenLongitude != 0.0 && self.chosenLatitude != 0.0 {
            let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                if let placemark = placemarks {
                    
                    if placemark.count > 0 {
                        
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.placeNameText.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                    
                }
            }
            
        }
    }
    func loadImage(from urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }else if let error = error {
                    print("Resim yüklenirken hata oluştu: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
    @objc func backButtonClicked() {
        //navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }


}
