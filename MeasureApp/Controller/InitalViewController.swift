//
//  InitalViewController.swift
//  MeasureApp
//
//  Created by AR on 04/06/21.
//

import UIKit

class InitalViewController: UIViewController {

    @IBOutlet weak var btnMeasure: UIButton!    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMeasure.layer.cornerRadius = 8
        btnMeasure.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    @IBAction func btnMeasure(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
