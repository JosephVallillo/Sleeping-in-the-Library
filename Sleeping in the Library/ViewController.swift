//
//  ViewController.swift
//  Sleeping in the Library
//
//  Created by Joseph Vallillo on 1/25/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Properties
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.galleries.getPhotos"
    let API_KEY = "2db569c23aac5e508aa08bf35ddd02c6"
    let GALLERY_ID = "5704-72157622566655097"
    let EXTRAS = "url_m"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    
    //MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoDetails: UILabel!
    @IBOutlet weak var getNewImageButton: UIButton!
    
    //MARK: - Button Actions
    @IBAction func getNewImage() {
        getSleepingInTheLibraryImageFromFlickr()
    }
    
    
    
    //MARK: - Flickr Functions
    func getSleepingInTheLibraryImageFromFlickr() {
        
        //API method arguments
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "gallery_id": GALLERY_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        //Initialize session and url
        let session = NSURLSession.sharedSession()
        let requestURL = NSURL(string: BASE_URL + escapedParameters(methodArguments))!
        let request = NSURLRequest(URL: requestURL)
        
        
        //initialize task for getting data
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            //Check for a successful response
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            
            //Check for a 2xx HTTP response
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response: \(response.statusCode)")
                } else if let response = response {
                    print("You request returned an invalid response: \(response)")
                } else {
                    print("Your request returned an invalid response: \(response)")
                }
                
                return
            }
            
            //Check if any data returned
            guard let data = data else {
                print("No data was returned by the request")
                return
            }
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //Check flickr for error
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error")
                return
            }
            
            //Check if photos and photo ket are in result
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary,
                photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find keys 'photos' and 'photo' in \(parsedResult)")
                    return
            }
            
            //generate random number and select the corresponding photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
            let photoTitle = photoDictionary["title"] as? String
            
            //get image url
            guard let imageURLString = photoDictionary["url_m"] as? String else{
                print("Cannot find key 'url_m' in \(photoDictionary)")
                return
            }
            
            
            let imageURL = NSURL(string: imageURLString)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageView.image = UIImage(data: imageData)
                    self.photoDetails.text = photoTitle ?? "(Untitled)"
                })
            }
            
        }
        
        //start task
        task.resume()

    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getSleepingInTheLibraryImageFromFlickr()
        
    }
    
    
    
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    


}

