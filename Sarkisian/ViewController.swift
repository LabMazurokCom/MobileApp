import UIKit
import DropDown
import SwiftyJSON
import Charts
import Alamofire



class ViewController: UIViewController {
    
    @IBOutlet weak var cruptocurButton: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var ask: UITextField!
    @IBOutlet weak var last_price: UITextField!
    @IBOutlet weak var bid: UITextField!
    @IBOutlet weak var graph: LineChartView!
    
    fileprivate var currentRequest: DataRequest?
    
    var dict = ["ETH", "EOS"]
    var dict1 = ["Bitstamp","CEX"]
    var dict2 = ["EUR"]
    
    var asks : [Double] = []
    var bids : [Double] = []
    var prices : [Double] = []
    
    var timer = Timer()
    
    @IBAction func cryptos(_ sender:Any) {
        let dropDown = DropDown()
        dropDown.anchorView = cruptocurButton
        dropDown.dataSource = dict
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let text1 = self.cruptocurButton.text
            let x = dropDown.indexForSelectedRow
            self.cruptocurButton.text = dropDown.selectedItem
            self.dict.append(text1!)
            self.dict.remove(at: x!)
            self.reset()
            self.change()
            
        }
        dropDown.show()
    }
    
    @IBAction func stocks(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = stock
        dropDown.dataSource = dict1
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let text1 = self.stock.text
            let x = dropDown.indexForSelectedRow
            self.stock.text = dropDown.selectedItem
            self.dict1.append(text1!)
            self.dict1.remove(at: x!)
            self.reset()
            self.change()
            
            
        }
        dropDown.show()
    }
    
    @IBAction func values(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = value
        dropDown.dataSource = dict2
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let text1 = self.value.text
            let x = dropDown.indexForSelectedRow
            self.value.text = dropDown.selectedItem
            self.dict2.append(text1!)
            self.dict2.remove(at: x!)
            self.reset()
            self.change()
            
        }
        dropDown.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        change()
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(change), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }

    
    @objc func change() {
        currentRequest?.cancel()
        if cruptocurButton.text == "BTC" && stock.text == "Bitfinex" && value.text == "USD" {
            currentRequest = fetchBitfinex_BTC_USDListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "Bitfinex" && value.text == "USD" {
            currentRequest = fetchBitfinex_ETH_USDListing()
        }
        if cruptocurButton.text == "EOS" && stock.text == "Bitfinex" && value.text == "USD" {
            currentRequest = fetchBitfinex_EOS_USDListing()
        }
        if cruptocurButton.text == "BTC" && stock.text == "Bitfinex" && value.text == "EUR" {
            currentRequest = fetchBitfinex_BTC_EURListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "Bitfinex" && value.text == "EUR" {
            currentRequest = fetchBitfinex_ETH_EURListing()
        }
        if cruptocurButton.text == "EOS" && stock.text == "Bitfinex" && value.text == "EUR" {
            currentRequest = fetchBitfinex_EOS_EURListing()
        }
        if cruptocurButton.text == "BTC" && stock.text == "Bitstamp" && value.text == "USD" {
            currentRequest = fetchBitstamp_BTC_USDListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "Bitstamp" && value.text == "USD" {
            currentRequest = fetchBitstamp_ETH_USDListing()
        }
        if cruptocurButton.text == "BTC" && stock.text == "Bitstamp" && value.text == "EUR" {
            currentRequest = fetchBitstamp_BTC_EURListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "Bitstamp" && value.text == "EUR" {
            currentRequest = fetchBitstamp_ETH_EURListing()
        }
        if cruptocurButton.text == "EOS" && stock.text != "Bitfinex"  {
            ask.text = "No info"
            bid.text = "No info"
            last_price.text = "No info"
            resetGraph()
        }
        if cruptocurButton.text == "BTC" && stock.text == "CEX" && value.text == "USD" {
            currentRequest = fetchCEX_BTC_USDListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "CEX" && value.text == "USD" {
            currentRequest = fetchCEX_ETH_USDListing()
        }
        if cruptocurButton.text == "BTC" && stock.text == "CEX" && value.text == "EUR" {
            currentRequest = fetchCEX_BTC_EURListing()
        }
        if cruptocurButton.text == "ETH" && stock.text == "CEX" && value.text == "EUR" {
            currentRequest = fetchCEX_ETH_EURListing()
        }
    }
    
    func fetchBitfinex_BTC_USDListing() -> DataRequest {
        return API.Bitfinex_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitfinex_ETH_USDListing() -> DataRequest {
        return API.Bitfinex_ETH_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitfinex_EOS_USDListing() -> DataRequest {
        return API.Bitfinex_EOS_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitfinex_BTC_EURListing() -> DataRequest {
        return API.Bitfinex_BTC_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitfinex_ETH_EURListing() -> DataRequest {
       return API.Bitfinex_ETH_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitfinex_EOS_EURListing() -> DataRequest {
        return API.Bitfinex_EOS_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = ListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last_price
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last_price)!)
        }
    }
    
    func fetchBitstamp_BTC_USDListing() -> DataRequest {
        return API.Bitstamp_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = BitstampListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchBitstamp_ETH_USDListing() -> DataRequest {
        return API.Bitstamp_ETH_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = BitstampListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchBitstamp_BTC_EURListing() -> DataRequest {
        return API.Bitstamp_BTC_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = BitstampListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchBitstamp_ETH_EURListing() -> DataRequest {
        return API.Bitstamp_ETH_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = BitstampListingItem(with: json)
            self.ask.text = listing.ask
            self.bid.text = listing.bid
            self.last_price.text = listing.last
            self.asks.append(Double(listing.ask)!)
            self.bids.append(Double(listing.bid)!)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchCEX_BTC_USDListing() -> DataRequest {
        return API.CEX_BTC_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = CEXListingItem(with: json)
            self.ask.text = String(listing.ask)
            self.bid.text = String(listing.bid)
            self.last_price.text = listing.last
            self.asks.append(listing.ask)
            self.bids.append(listing.bid)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchCEX_ETH_USDListing() -> DataRequest {
        return API.CEX_ETH_USD().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = CEXListingItem(with: json)
            self.ask.text = String(listing.ask)
            self.bid.text = String(listing.bid)
            self.last_price.text = listing.last
            self.asks.append(listing.ask)
            self.bids.append(listing.bid)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchCEX_BTC_EURListing() -> DataRequest {
        return API.CEX_BTC_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = CEXListingItem(with: json)
            self.ask.text = String(listing.ask)
            self.bid.text = String(listing.bid)
            self.last_price.text = listing.last
            self.asks.append(listing.ask)
            self.bids.append(listing.bid)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func fetchCEX_ETH_EURListing() -> DataRequest {
        return API.CEX_ETH_EUR().responseJSON { (response) in
            guard let JSONObject = response.value
                else { return }
            
            let json = JSON(JSONObject)
            let listing = CEXListingItem(with: json)
            self.ask.text = String(listing.ask)
            self.bid.text = String(listing.bid)
            self.last_price.text = listing.last
            self.asks.append(listing.ask)
            self.bids.append(listing.bid)
            self.prices.append(Double(listing.last)!)
        }
    }
    
    func reset() {
        asks.removeAll()
        bids.removeAll()
        prices.removeAll()
    }
    
    func resetGraph() {
        graph.clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


