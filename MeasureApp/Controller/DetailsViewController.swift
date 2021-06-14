//
//  DetailsViewController.swift
//  MeasureApp
//
//  Created by AR on 04/06/21.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var lblResult: UILabel!
    var temp:String = ""
    var image:UIImage?
    var images: [UIImage] = []
    @IBOutlet weak var wallImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        //lblResult.text = temp
        wallImage.image = images[0]
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
