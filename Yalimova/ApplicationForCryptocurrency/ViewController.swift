import UIKit
import SwiftyJSON
import Charts
import Alamofire


class ViewController: UIViewController {
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var ask: UITextField!
    @IBOutlet weak var bid: UITextField!
    
    fileprivate var currentRequest: DataRequest?
    
    var asksArr : [ListingItem] = []
    var bidsArr : [ListingItem] = []
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChartsView()
        fetchBitfinex_BTC_USDListing()
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(fetchBitfinex_BTC_USDListing), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
    }
    
    @objc func fetchBitfinex_BTC_USDListing() {
        API.Bitfinex_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listings = Listing(with: json)
            
            self.ask.text = listings.asks
                .map({String($0.amount)})
                .joined(separator: ", ")
            self.bid.text = listings.bids
                .map({String($0.amount)})
                .joined(separator: ", ")
            
            self.asksArr = listings.asks
            self.bidsArr = listings.bids
            
            self.drawChart()
        }
    }
    
    private func setupChartsView() {
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 60
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
    }
    
    func drawChart() {
        let asksVals = asksArr.map({ BarChartDataEntry(x: $0.price, y: $0.amount) })
        let bidsVals = bidsArr.map({ BarChartDataEntry(x: $0.price, y: $0.amount) })
        let yVals = asksVals + bidsVals
        let colors = yVals.enumerated().map { (offset, _) -> UIColor in
            if offset < asksVals.count {
                return UIColor.red // Цвет для asks
            } else {
                return UIColor.blue // Цвет для bids
            }
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            set1.colors = colors
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "Latest data")
            set1.colors = colors
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.4 // Ширина колонки
            chartView.data = data
        }
    }
}
