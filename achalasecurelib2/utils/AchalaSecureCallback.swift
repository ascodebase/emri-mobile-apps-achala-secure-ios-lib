import Foundation
import UIKit
protocol AchalaSecureCallback: AnyObject {
    func onCompareSuccess(result: String, score: String,capturedImage:UIImage)
    func onCompareFailed(failed: String,score: String)
}
