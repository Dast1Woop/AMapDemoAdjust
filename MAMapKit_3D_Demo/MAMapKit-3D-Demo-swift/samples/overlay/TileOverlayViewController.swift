//
//  TileOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

let kURL4TileOverlayLevel0 = "https://dev.indoormap.huatugz.com/xyztiles/a11y/{z}/{x}/{y}.png?tileSize=512&scale=2"

class TileOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var tileOverlay: MATileOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateTileOverlay()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.zoomLevel = 13
        mapView.isRotateCameraEnabled = false
        mapView.setCenter(CLLocationCoordinate2DMake(23.11623425763484, 113.32610067743077), animated: true)
        self.view.addSubview(mapView)
        
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(tapG(ges:)))
        view.addGestureRecognizer(tapG)
        tapG.delegate = self
    }
    
    @objc func tapG(ges:UITapGestureRecognizer)  {
        print(#function)
        updateTileOverlay()
    }
    
    func creatOverlay(urlTemplate:String) -> MATileOverlay! {
        var tileOverlay:MATileOverlay!
        tileOverlay = MATileOverlay.init(urlTemplate: urlTemplate)
        tileOverlay.minimumZ = 4;
        tileOverlay.maximumZ = 19;
        tileOverlay.boundingMapRect = MAMapRectWorld
        return tileOverlay;
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MATileOverlay.self))
        {
            let renderer = MATileOverlayRenderer.init(tileOverlay: overlay as! MATileOverlay!)
            return renderer;
        }
        
        return nil;
    }
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        print("tap at:",coordinate)
    }
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        for i in 0..<pois.count{
            let p = pois[i] as! MATouchPoi
            print("taped poi:",p.coordinate,p.name)
        }
        
    }
    
    //MARK: - event handling
    @objc func updateTileOverlay() {
        print(#function)
        
        /* 删除之前的楼层. */
        self.mapView.remove(self.tileOverlay)
        
        /* 添加新的楼层. */
        self.tileOverlay = self.creatOverlay(urlTemplate: kURL4TileOverlayLevel0 )
        
        self.mapView.add(self.tileOverlay)
    }
    
    
    
}

extension TileOverlayViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
