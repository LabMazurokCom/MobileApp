//
//  ViewController.swift
//  AllaGraph
//
//  Created by Алла Марокко on 18.06.18.
//  Copyright © 2018 Алла Марокко. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class ViewController: UIViewController {
    @IBOutlet weak var graph: BarChartView!
    
    @IBOutlet weak var text: UITextField!
    
    var askBitfinex : Double = 0.0
    var bidBitfinex : Double = 0.0
    var priceBitfinex : Double = 0.0
    
    var askBitstamp : Double = 0.0
    var bidBitstamp : Double = 0.0
    var priceBitstamp : Double = 0.0
    
    var askCEX : Double = 0.0
    var bidCEX : Double = 0.0
    var priceCEX : Double = 0.0
    
    var timer = Timer()
    var timer1 = Timer()
    var timer2 = Timer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(fetchCEX_BTC_USDListing), userInfo: nil, repeats: true)
        timer1 = Timer(timeInterval: 5.0, target: self, selector: #selector(fetchBitfinex_BTC_USDListing), userInfo: nil, repeats: true)
        timer2 = Timer(timeInterval: 5.0, target: self, selector: #selector(fetchBitstamp_BTC_USDListing), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        RunLoop.main.add(timer1, forMode: RunLoopMode.defaultRunLoopMode)
        RunLoop.main.add(timer2, forMode: RunLoopMode.defaultRunLoopMode)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    @objc func fetchBitfinex_BTC_USDListing()  {
         API.Bitfinex_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.askBitfinex = Double(listing.ask)!
            self.bidBitfinex = Double(listing.bid)!
            self.priceBitfinex = Double(listing.last_price)!
            self.updateGraph()
        }
    }
    
    @objc func fetchBitstamp_BTC_USDListing()  {
         API.Bitstamp_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = BitstampListingItem(with: json)
            self.askBitstamp = Double(listing.ask)!
            self.bidBitstamp = Double(listing.bid)!
            self.priceBitstamp = Double(listing.last)!
            self.updateGraph()
        }
    }
    
    @objc func fetchCEX_BTC_USDListing()  {
         API.CEX_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = CEXListingItem(with: json)
            self.askCEX = listing.ask
            self.bidCEX = listing.bid
            self.priceCEX = Double(listing.last)!
            self.updateGraph()
        }
    }
    
    func updateGraph() {
        var barChartEntry = [BarChartDataEntry]()
        let value1 = BarChartDataEntry(x: 1.0, y: askBitfinex)
        barChartEntry.append(value1)
        let value2 = BarChartDataEntry(x: 2.0, y: askBitstamp)
        barChartEntry.append(value2)
        let value3 = BarChartDataEntry(x: 3.0, y: askCEX)
        barChartEntry.append(value3)
        
        var barChartEntry1 = [BarChartDataEntry]()
        let value4 = BarChartDataEntry(x: 4.0, y: bidBitfinex)
        barChartEntry1.append(value4)
        let value5 = BarChartDataEntry(x: 5.0, y: bidBitstamp)
        barChartEntry1.append(value5)
        let value6 = BarChartDataEntry(x: 6.0, y: bidCEX)
        barChartEntry1.append(value6)
        
        var barChartEntry2 = [BarChartDataEntry]()
        let value7 = BarChartDataEntry(x: 7.0, y: priceBitfinex)
        barChartEntry2.append(value7)
        let value8 = BarChartDataEntry(x: 8.0, y: priceBitstamp)
        barChartEntry2.append(value8)
        let value9 = BarChartDataEntry(x: 9.0, y: priceCEX)
        barChartEntry2.append(value9)
        
        let bar1 = BarChartDataSet(values: barChartEntry, label: "Ask")
        bar1.setColor(NSUIColor.red)
        
        let bar2 = BarChartDataSet(values: barChartEntry1, label : "Bid")
        bar2.setColor(NSUIColor.green)
        
        let bar3 = BarChartDataSet(values: barChartEntry2, label : "Last Price")
        bar3.setColor(NSUIColor.black)
        
        let xAxis = graph.xAxis
        xAxis.drawLabelsEnabled = false
        xAxis.drawGridLinesEnabled = false
        
        
        let yAxis = graph.rightAxis
        yAxis.drawLabelsEnabled = false
        yAxis.drawGridLinesEnabled = false
        
        let yAxis1 = graph.leftAxis
        //yAxis1.drawGridLinesEnabled = false
        yAxis1.drawLabelsEnabled = false
        
        let data = BarChartData(dataSets: [bar1,bar2,bar3])
        data.barWidth = 0.5
        data.groupBars(fromX: 1.0, groupSpace: 1.0, barSpace: 0.03)
        
        let l = graph.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        
        graph.isUserInteractionEnabled = false
        graph.data = data
        //graph.fitBars = true
        graph.chartDescription?.text = ""
        
    }
    
    

}

