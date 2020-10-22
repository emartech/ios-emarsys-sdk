//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage(systemName: "gear")!
    var url: String?

    init(withURL url:String) {
        self.url = url
        imageLoader = ImageLoader(urlString:url)
    }

    var body: some View {
        Image(uiImage: !imageLoader.data.isEmpty ? UIImage(data: imageLoader.data)! : image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100, height:100)
                .onReceive(imageLoader.didChange) { data in
                    if( data.isEmpty) {
                        self.image = UIImage(systemName:"gear")!
                    } else {
                        self.image = UIImage(data: data) ?? UIImage(systemName: "gear")!
                    }
        }
    }
}
