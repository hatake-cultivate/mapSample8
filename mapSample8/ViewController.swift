//
//  ViewController.swift
//  mapSample8
//
//  Created by Takeuchi Haruki on 2016/02/21.
//  Copyright © 2016年 Takeuchi Haruki. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var myMapView: MKMapView!
    
    @IBAction func ClearB() {
        myMapView.removeAnnotations(myMapView.annotations)
        i = 0
    }
    
    func WriteB() {
        for j in 1..<self.i {
            print("in!")
            addRoute(self.locations[j-1], toCoordinate: self.locations[j])
        }
    }
    
//    @IBOutlet var Writer: UIBarButtonItem!
    @IBOutlet var Writer: UIButton!
    
    var longtapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    var locations: [CLLocationCoordinate2D] = []
    var i: Int = 0
    
    var fl: Bool = true
    
    var routes: [MKRoute] = [] {
        didSet {
            var time: Double = 0
            var dist: Double = 0
            for route in self.routes {
                time += Double(route.expectedTravelTime)
                dist += Double(route.distance)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let location1: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.0212466, 135.7555968)
        myMapView.setCenterCoordinate(location1, animated: true)
        
//        let writeGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: Writer, action: "WriteB:")
//        self.Writer.addGestureRecognizer(writeGesture)
        
        var region: MKCoordinateRegion = myMapView.region
        region.center = location1
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        myMapView.setRegion(region, animated: true)
        myMapView.mapType = MKMapType.Standard
        
        self.longtapGesture.addTarget(self, action: "longPressed:")
        self.myMapView.addGestureRecognizer(self.longtapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressed(sender: UILongPressGestureRecognizer){
        
        //指を離したときだけ反応するようにする
        if(sender.state != .Began){
            return
        }
        
        let location = sender.locationInView(self.myMapView)
        let mapPoint:CLLocationCoordinate2D = self.myMapView.convertPoint(location, toCoordinateFromView: self.myMapView)
        
        //ピンを生成
        let theRoppongiAnnotation = MKPointAnnotation()
        //ピンを置く場所を設定
        theRoppongiAnnotation.coordinate  = mapPoint
        //ピンを地図上に追加
        self.myMapView.addAnnotation(theRoppongiAnnotation)

        print(i)
        print(mapPoint)
        locations.insert(mapPoint, atIndex: i++)
    }
    
    func addRoute(fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D){
        let fromItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil))
        let toItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate, addressDictionary: nil))
        
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        // 出発&目的地
        myRequest.source = fromItem
        myRequest.destination = toItem
        myRequest.requestsAlternateRoutes = false
        
        // 徒歩
        myRequest.transportType = MKDirectionsTransportType.Walking
        
        // MKDirectionsを生成してRequestをセット.
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        // 経路探索.
        myDirections.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if let route = response?.routes.first as MKRoute? {
                print("目的地まで \(route.distance)m")
                print("所要時間 \(Int(route.expectedTravelTime/60))分")
                
                self.routes.append(route)
                
                // mapViewにルートを描画.
                self.myMapView.addOverlay(route.polyline)
            }
        }
    }
    
    func fitMapWithSpots(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        // fromLocation, toLocationに基いてmapの表示範囲を設定
        // 現在地と目的地を含む矩形を計算
        let maxLat: Double
        let minLat: Double
        let maxLon: Double
        let minLon: Double
        if fromLocation.latitude > toLocation.latitude {
            maxLat = fromLocation.latitude
            minLat = toLocation.latitude
        } else {
            maxLat = toLocation.latitude
            minLat = fromLocation.latitude
        }
        if fromLocation.longitude > toLocation.longitude {
            maxLon = fromLocation.longitude
            minLon = toLocation.longitude
        } else {
            maxLon = toLocation.longitude
            minLon = fromLocation.longitude
        }
        
        let center = CLLocationCoordinate2DMake((maxLat + minLat) / 2, (maxLon + minLon) / 2)
        
        let mapMargin:Double = 1.5;  // 経路が入る幅(1.0)＋余白(0.5)
        let leastCoordSpan:Double = 0.005;    // 拡大表示したときの最大値
        let span = MKCoordinateSpanMake(fmax(leastCoordSpan, fabs(maxLat - minLat) * mapMargin), fmax(leastCoordSpan, fabs(maxLon - minLon) * mapMargin))
        
        self.myMapView.setRegion(myMapView.regionThatFits(MKCoordinateRegionMake(center, span)), animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        // rendererを生成.
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        // 線の太さを指定.
        myPolyLineRendere.lineWidth = 5
        
        // 線の色を指定.
        myPolyLineRendere.strokeColor = UIColor.redColor()
        
        return myPolyLineRendere
    }
}

