//
//  ViewController.swift
//  Coin List
//
//  Created by Suren Poghosyan on 16.08.23.
//


import UIKit

struct Coins: Codable {
    var coins: [Coin]
}


struct Coin: Codable {
    var icon: String
    var symbol: String
    var price: Double
    
    enum CodingKeys: String, CodingKey {
        case icon = "icon"
        case symbol = "symbol"
        case price = "price"
    }
}

class ViewController: UIViewController {
    var coinsList: Coins?
    var backedUpCoinList: Coins?
    var iconList: [String: UIImage] = [:]
    let defaults = UserDefaults.standard

    @IBOutlet weak var coinsTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardDismissal()
        self.view.bringSubviewToFront(loader)
        searchTextField.addTarget(self, action: #selector(onSearchInputChange), for: .editingChanged)

        showLoader()

        if let date = defaults.date(forKey: "lastUpdate")  {
            let timeDifference = abs(date.timeIntervalSinceNow)
            print(timeDifference)
            if timeDifference >= 60{
                getCoins()
            } else {
                if let contentData = defaults.object(forKey: "coinsList") as? Data,
                    let content = try? JSONDecoder().decode(Coins.self, from: contentData) {
                    self.coinsList = content
                    self.backedUpCoinList = content
                    
                    DispatchQueue.main.async {
                        self.coinsTableView.reloadData()
                    }
                    
                    hideLoader()
                    
                } else {
                    getCoins()
                }
            }
        } else {
            getCoins()
        }
        
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        coinsTableView.delegate = self
        coinsTableView.dataSource = self
        coinsTableView.addSubview(refreshControl)
        coinsTableView.register(CoinsTableViewCell.self, forCellReuseIdentifier: "coinItem")
    }
    
    
    func getCoins(reachedBottom: Bool? = nil){
        let session = URLSession(configuration: .default)
        
        var bottomCount: Int = 0
        
        if let _ = reachedBottom {
            bottomCount = (coinsList?.coins.count ?? 0)
        }
        
        
        var componets = URLComponents(string: "https://api.coinstats.app/public/v1/coins")
        componets?.queryItems = [
            URLQueryItem(name: "skip", value: "\(bottomCount)"),
            URLQueryItem(name: "limit", value: "\(20)"),
            URLQueryItem(name: "currency", value: "USD")
        ]
        
        guard let url = componets?.url else { return }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet {
                    print("Not connected to internet")
                }
                DispatchQueue.main.async {
                    self.hideLoader()
                }
            }
            
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    self.hideLoader()
                }
                print(response.statusCode)
            }
            
            do {
                if let data {
                    
                    let results = try JSONDecoder().decode(Coins.self, from: data)
                    
                    if let _ = self.coinsList {
                        if let _ = reachedBottom {
                            self.coinsList?.coins += results.coins
                        } else{
                            self.coinsList = results
                        }
                        
                    } else {
                        self.coinsList = results
                    }

                    self.backedUpCoinList = self.coinsList

                    if let contentData = try? JSONEncoder().encode(self.coinsList) {
                        self.defaults.removeObject(forKey: "lastUpdate")
                        let date = Date()
                        self.defaults.set(date: date, forKey: "lastUpdate")
                        self.defaults.set(contentData, forKey: "coinsList")
                    }
                    
                    

                    DispatchQueue.main.async {
                        self.coinsTableView.reloadData()

                    }

                }
            } catch{
                print(error)
            }
        }
        
        task.resume()
        
    }
    
    func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func onRefresh(){
        getCoins()
        refreshControl.endRefreshing()
    }
    
    @objc func onSearchInputChange(){
        
        if let text = searchTextField.text {
            if text.count == 0 {
                self.coinsList = self.backedUpCoinList
                self.coinsTableView.reloadData()
            
            } else {
                let coins = self.backedUpCoinList?.coins
                
                let filteredCoins = coins!.filter { coin in
                    return coin.symbol.lowercased().contains(text.lowercased())
                }
                
                self.coinsList?.coins = filteredCoins
                self.coinsTableView.reloadData()
            }
        }
    }
    
    func showLoader(){
        self.loader.startAnimating()
        self.loader.isHidden = false

    }
    
    func hideLoader(){
        self.loader.stopAnimating()
        self.loader.isHidden = true

    }

}


class CoinsTableViewCell: UITableViewCell {
    var icon: UIImageView!
    var title: UILabel!
    var price: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         
         setupSubviews()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         
         setupSubviews()
     }
    
    private func setupSubviews() {
        title = UILabel()
        price = UILabel()
        icon = UIImageView()

        title.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(title)
        contentView.addSubview(price)
        contentView.addSubview(icon)
        title.clipsToBounds = true
        
         NSLayoutConstraint.activate([
             title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             title.topAnchor.constraint(equalTo: contentView.topAnchor),
             title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
             title.widthAnchor.constraint(equalToConstant: 60),
             
             icon.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 40),
             icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             icon.heightAnchor.constraint(equalToConstant: 30),
             icon.widthAnchor.constraint(equalToConstant: 30),
             
             
             price.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
             price.topAnchor.constraint(equalTo: contentView.topAnchor),
             price.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
             price.widthAnchor.constraint(equalToConstant: 90)
         ])
     }
    
    func configure(label: String, image: UIImage, priceValue: Double) {
        title.text = label
        price.text = "$" + String(format: "%.2f", priceValue)
        icon.image = image
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            self?.coinsList?.coins.remove(at: indexPath.row)
            self?.coinsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        action.backgroundColor = .red
        action.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let text = self.searchTextField.text {
            if text.count == 0 {
                if indexPath.row + 1 == coinsList?.coins.count {
                    showLoader()
                    getCoins(reachedBottom: true)
                }

            }
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}




extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (coinsList?.coins.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinItem", for: indexPath) as! CoinsTableViewCell
        let item = (coinsList?.coins[indexPath.row] as? Coin)!
        
        if let image = self.iconList[item.symbol] {
            DispatchQueue.main.async {
                cell.configure(label: item.symbol, image: image, priceValue: item.price)
            }
        } else {
            
            let url = URL(string: item.icon)!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.iconList[item.symbol] = image
                    DispatchQueue.main.async {
                        cell.configure(label: item.symbol, image: image, priceValue: item.price)
                    }
                }
            }
            task.resume()
        }
        
        return cell
    }
    

}


extension UserDefaults {
    func set(date: Date?, forKey key: String){
        self.set(date, forKey: key)
    }
    
    func date(forKey key: String) -> Date? {
        return self.value(forKey: key) as? Date
    }
}
