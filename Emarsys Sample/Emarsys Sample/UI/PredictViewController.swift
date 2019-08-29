//
//  Copyright © 2018. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class PredictViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: Outlets
    @IBOutlet weak var tfItemId: UITextField!
    @IBOutlet weak var tfCategoryId: UITextField!
    @IBOutlet weak var tfSearchTerm: UITextField!
    @IBOutlet weak var tvCartItems: UITextView!
    @IBOutlet weak var tfOrderId: UITextField!
    @IBOutlet weak var cvProducts: UICollectionView!
    
    //MARK: Variables
    var cartItems = [EMSCartItem]()
    var logic = EMSLogic.search()
    var products = [EMSProduct]()

    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        cartItems.append(generateCartItem())
        cartItems.append(generateCartItem())
        tvCartItems.text = cartItems.description
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCellId", for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }

        let product = self.products[indexPath.item]
        
        cell.lbTitle.text = product.title
        cell.lbFeature.text = product.feature
        
        guard let rawImageUrl = product.imageUrl else {
            return cell
        }
        let imageUrlString = rawImageUrl.absoluteString
        let correctedImageUrlString = imageUrlString.replacingOccurrences(of: "http:", with: "https:")
        
        guard let imageUrl = URL(string: correctedImageUrlString) else {
            return cell
        }
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            DispatchQueue.main.async {
                cell.ivProduct.image = data != nil ? UIImage(data: data!) : #imageLiteral(resourceName: "placeholder")
            }
            }.resume()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = self.products[indexPath.item]
        Emarsys.predict.trackItemView(with: product)
    }

    //MARK: Actions
    @IBAction func trackItemViewButtonClicked(_ sender: Any) {
        guard let itemId = tfItemId.text, itemId.count > 0 else {
            return
        }
        self.logic = EMSLogic.related(withViewItemId: itemId)
        Emarsys.predict.trackItemView(withItemId: itemId)
    }

    @IBAction func trackCategoryIdButtonClicked(_ sender: Any) {
        guard let categoryId = tfCategoryId.text, categoryId.count > 0 else {
            return
        }
        Emarsys.predict.trackCategoryView(withCategoryPath: categoryId)
    }

    @IBAction func trackSearchTermButtonClicked(_ sender: Any) {
        guard let searchTerm = tfSearchTerm.text, searchTerm.count > 0 else {
            return
        }
        self.logic = EMSLogic.search(withSearchTerm: searchTerm)
        Emarsys.predict.trackSearch(withSearchTerm: searchTerm)
    }

    @IBAction func addCartItemButtonClicked(_ sender: Any) {
        cartItems.append(generateCartItem())
        tvCartItems.text = cartItems.description
    }

    @IBAction func trackCartItemButtonClicked(_ sender: Any) {
        self.logic = EMSLogic.cart(withCartItems: cartItems)
        Emarsys.predict.trackCart(withCartItems: cartItems)
    }

    @IBAction func trackPurchaseButtonClicked(_ sender: Any) {
        guard let orderId = tfOrderId.text, orderId.count > 0 else {
            return
        }
        Emarsys.predict.trackPurchase(withOrderId: orderId, items: cartItems)
    }

    @IBAction func recommendProductsButtonClicked(_ sender: Any) {
        Emarsys.predict.recommendProducts({ (products: [EMSProduct]?, error: Error?) in
            guard let existingProducts = products else {
                return
            }
            self.products = existingProducts
            self.cvProducts.reloadData()
        }, with:self.logic)
    }


    //MARK: Privates
    private func generateCartItem() -> EMSCartItem {
        let itemIds = [
            "2185",
            "2186",
            "2187",
            "2188",
            "2189",
            "2190",
            "2191",
            "2192",
            "2193",
            "2194",
            "2195",
            "2196",
            "2197",
            "2198",
            "2199",
            "2200",
            "2201",
            "2202",
            "2206",
            "2209",
            "2210",
            "2211",
            "2213",
            "2215",
            "2231",
            "2232",
            "2233",
            "2235",
            "2236",
            "2237",
            "2239",
            "2240",
            "2241",
            "2244",
            "2289"
        ];
        let price = Double.random(in: 1..<100)
        let quantity = Double.random(in: 1..<5)
        return EMSCartItem(itemId: itemIds[Int.random(in: 0..<itemIds.count)], price: price, quantity: quantity)
    }

    @objc func backgroundTapped() {
        self.view.endEditing(true)
    }
}
