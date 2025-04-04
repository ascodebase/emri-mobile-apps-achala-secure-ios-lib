import CoreGraphics

struct Prediction {
    var bbox: CGRect
    var label: String
    var maskLabel: String

    // Initializer for bbox and label
    init(bbox: CGRect, label: String) {
        self.bbox = bbox
        self.label = label
        self.maskLabel = ""
    }

    // Initializer for bbox, label, and maskLabel
    init(bbox: CGRect, label: String, maskLabel: String) {
        self.bbox = bbox
        self.label = label
        self.maskLabel = maskLabel
    }

    // To display the properties as a string (similar to the `toString` method in Java)
    var description: String {
        return "Prediction(bbox: \(bbox), label: \(label), maskLabel: \(maskLabel))"
    }
}
