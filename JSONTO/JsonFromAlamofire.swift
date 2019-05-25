//
//  Alamo.swift
//  JSONTO
//
//  Created by Brijesh Patel on 25/05/19.
//  Copyright © 2019 Brijesh Patel. All rights reserved.
//

import Foundation
import Alamofire

class JsonFromAlamofire{
  typealias WebServiceResponse = ([[String: Any]]?, Error?) -> Void
  func execute(_ url: URL, completion: @escaping WebServiceResponse){
    Alamofire.request(url).validate().responseJSON { response in
      if let error = response.error{
        completion(nil, error)
      }else if let jsonArray = response.result.value as? [[String: Any]]{
        completion(jsonArray, nil)
      }else if let jsonDict = response.result.value as? [String: Any]{
        completion([jsonDict], nil)
      }
    }
  }
}
