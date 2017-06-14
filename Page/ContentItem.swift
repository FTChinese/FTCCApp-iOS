// MARK: The data source for a channel page collection view

import UIKit

class ContentItem{
    var thumbnail : UIImage?
    var largeImage : UIImage?
    let id : String
    let image: String
    let headline : String
    let lead : String
    let type : String
    let section: Int
    let row: Int
    
    init (id: String, image: String, headline: String, lead: String, type: String, section: Int, row: Int) {
        self.id = id
        self.image = image
        self.headline = headline
        self.lead = lead
        self.type = type
        self.section = section
        self.row = row
    }
    
    func getImageURL(_ imageUrl: String, width: Int, height: Int) -> URL? {
        let urlString: String
        if let u = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            urlString = "https://www.ft.com/__origami/service/image/v2/images/raw/\(u)?source=ftchinese&width=\(width * 2)&height=\(height * 2)&fit=cover"
        } else {
            urlString = imageUrl
        }
        if let url =  URL(string: urlString) {
            return url
        }
        return nil
    }
    
    func loadLargeImage(width: Int, height: Int, completion: @escaping (_ contentItem:ContentItem, _ error: NSError?) -> Void) {
        guard let loadURL = getImageURL(image, width: width, height: height) else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }
        //print ("\(loadURL.absoluteString) should be loaded just once")
        let loadRequest = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }
            
            let returnedImage = UIImage(data: data)
            self.largeImage = returnedImage
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }
    
    func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
        guard let thumbnail = thumbnail else {
            return size
        }
        let imageSize = thumbnail.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        return returnSize
    }
    
}
