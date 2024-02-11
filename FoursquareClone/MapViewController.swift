//
//  MapViewController.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 4.02.2024.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage

class MapViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClicked))

        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)

    }
    @objc func saveButtonClicked() {
        let place = Places.sharedInstance

        let storage = Storage.storage()
        let storageReferance = storage.reference()

        let mediaFolder = storageReferance.child("media")

        if let data = place.image.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    imageReferance.downloadURL(completion: { url, error in
                        if error == nil {
                            

                            let firestore = Firestore.firestore()
                            var firestoreReferance: DocumentReference? = nil
                            if let currentUser = Auth.auth().currentUser{
                                let userId = currentUser.uid
                                
                                // Resmin Firestore'a eklenmeye uygun URL'sini al
                                guard let imageUrl = url?.absoluteString else {
                                    self.makeAlert(titleInput: "Error!", messageInput: "Image URL not found")
                                    return
                                }
                                
                                let placeData = [
                                    "userId": userId,
                                    "placeName": place.placeName,
                                    "placeType": place.placeType,
                                    "placeAtmosphere": place.placeAtmosphere,
                                    "latitude": place.latitude,
                                    "longitude": place.longitude,
                                    "imageURL": imageUrl // Resmin Firestore'a eklenen URL'si
                                ] as [String: Any]

                                
                                firestoreReferance=firestore.collection("Places").addDocument(data: placeData, completion: { error in
                                    if error != nil{
                                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                    }else{
                                        place.image=UIImage(named: "selectimage.png")!
                                        place.placeName=""
                                        place.placeType=""
                                        place.latitude=""
                                        place.longitude=""
                                        place.placeAtmosphere=""
                                        self.performSegue(withIdentifier: "toListVCfromMapVC", sender: nil)
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    @objc func chooseLocation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touches = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = Places.sharedInstance.placeName
            annotation.subtitle = Places.sharedInstance.placeType
            
            self.mapView.addAnnotation(annotation)
            
            
            Places.sharedInstance.latitude = String(coordinates.latitude)
            Places.sharedInstance.longitude = String(coordinates.longitude)
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locationManager.stopUpdatingLocation()
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    @objc func backButtonClicked() {
        //navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
