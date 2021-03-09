//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import XCTest

class EMSProductMapperSwiftTests: XCTestCase {

    let mapper = EMSProductMapper()
    
    func testMapFromResponse_customFields_shouldNotCrash() {
        let product: EMSProduct = mapper.map(fromResponse: createResponseModel()).first!
        
        var success = false
        product.customFields.forEach { key, value in
        }
        success = true
        
        XCTAssertTrue(success)
    }
    
    func createResponseModel() -> EMSResponseModel {
        let rawResponse = """
                          {\n
                                  \"cohort\": \"AAAA\",\n
                                  \"visitor\": \"11730071F07F469F\",\n
                                  \"session\": \"28ACE5FD314FCC1A\",\n
                                  \"features\": {\n
                                    \"SEARCH\": {\n
                                      \"hasMore\": true,\n
                                      \"merchants\": [\n
                                        \"1428C8EE286EC34B\"\n
                                      ],\n
                                      \"items\": [\n
                                        {\n
                                          \"id\": \"2119\",\n
                                          \"spans\": [\n
                                            [\n
                                              [\n
                                                8,\n
                                                12\n
                                              ],\n
                                              [\n
                                                13,\n
                                                18\n
                                              ]\n
                                            ],\n
                                            [\n
                                              [\n
                                                4,\n
                                                9\n
                                              ]\n
                                            ]\n
                                          ]\n
                                        },\n
                                        {\n
                                          \"id\": \"2120\",\n
                                          \"spans\": [\n
                                            [\n
                                              [\n
                                                8,\n
                                                12\n
                                              ],\n
                                              [\n
                                                13,\n
                                                18\n
                                              ]\n
                                            ],\n
                                            [\n
                                              [\n
                                                4,\n
                                                9\n
                                              ]\n
                                            ]\n
                                          ]\n
                                        }\n
                                      ]\n
                                    }\n
                                  },\n
                                  \"products\": {\n
                                    \"2119\": {\n
                                      \"item\": \"2119\",\n
                                      \"category\": \"MEN>Shirts\",\n
                                      \"title\": \"LSL Men Polo Shirt SE16\",\n
                                      \"available\": true,\n
                                      \"msrp\": 100,\n
                                      \"price\": 100,\n
                                      \"msrp_gpb\": \"83.2\",\n
                                      \"price_gpb\": \"83.2\",\n
                                      \"msrp_aed\": \"100\",\n
                                      \"price_aed\": \"100\",\n
                                      \"msrp_cad\": \"100\",\n
                                      \"price_cad\": \"100\",\n
                                      \"msrp_mxn\": \"2057.44\",\n
                                      \"price_mxn\": \"2057.44\",\n
                                      \"msrp_pln\": \"100\",\n
                                      \"price_pln\": \"100\",\n
                                      \"msrp_rub\": \"100\",\n
                                      \"price_rub\": \"100\",\n
                                      \"msrp_sek\": \"100\",\n
                                      \"price_sek\": \"100\",\n
                                      \"msrp_try\": \"339.95\",\n
                                      \"price_try\": \"339.95\",\n
                                      \"msrp_usd\": \"100\",\n
                                      \"price_usd\": \"100\",\n
                                      \"null_value\": null,\n
                                      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-se16.html\",\n
                                      \"image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n
                                      \"zoom_image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n
                                      \"description\": \"product Description\",\n
                                      \"album\": \"album\",\n
                                      \"actor\": \"actor\",\n
                                      \"artist\": \"artist\",\n
                                      \"author\": \"author\",\n
                                      \"brand\": \"brand\",\n
                                      \"year\": 2000,\n
                                    },\n
                                    \"2120\": {\n
                                      \"item\": \"2120\",\n
                                      \"title\": \"LSL Men Polo Shirt LE16\",\n
                                      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html\",\n
                                    }\n
                                  }\n
                                }
                          """
        let responseDict: [String: Any] = try! JSONSerialization.jsonObject(with: rawResponse.data(using: .utf8)!, options: .allowFragments) as! [String: Any]
        let data = try! JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted) as NSData
        
        return EMSResponseModel(statusCode: 200, headers: [:], body: data as Data, parsedBody: nil, requestModel: EMSRequestModel(), timestamp: Date())
    }
}
