import Vision
import AVFoundation
import MLKitVision
import MLKitTextRecognitionChinese
import MLKitTextRecognitionKorean
import CoreImage
import UIKit
import Vision
import AVFoundation
import MLKitImageLabeling
import MLKitVision
import MLKitTextRecognitionChinese
import MLKitTextRecognitionKorean
import CoreImage
import UIKit

@objc(ImageLabelerFrameProcessorPlugin)
public class ImageLabelerFrameProcessorPlugin: FrameProcessorPlugin {
    
    private static let labeler: ImageLabeler = {
        let options = ImageLabelerOptions()
        return ImageLabeler.imageLabeler(options: options)
    }()
    
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
   // @objc public static func labelImage(_ frame: Frame, withArguments arguments: [Any]?) -> Any? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
          print("Failed to get image buffer from sample buffer.")
          return nil
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create bitmap from image.")
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
       
        let visionImage = VisionImage(image: image)
        
        // TODO: Get camera orientation state
        visionImage.orientation = .up
        
        var results: [[String: Any]] = []
        
        // do {
        //     let labels = try ImageLabelerFrameProcessorPlugin.labeler.results(in: visionImage)
        //     results = labels.map { label in
        //         return [
        //             "label": label.text,
        //             "confidence": label.confidence
        //         ]
        //     }
        // } catch let error {
        //     print("Failed to label image with error: \(error.localizedDescription)")
        //     return nil
        // }
        
        var labels: [ImageLabel]

        do {
            labels = try ImageLabelerFrameProcessorPlugin.labeler.results(in: visionImage)
        } catch let error {
            print("Failed to label image with error: \(error.localizedDescription)")
            return nil
        }        
        
        return [
            "Text": labels.first?.text,
            "Confidence": labels.first?.confidence
        ]
    }
}


@objc(OCRFrameProcessorPlugin)
public class OCRFrameProcessorPlugin: FrameProcessorPlugin {
    
    private let chineseTextRecognizer = TextRecognizer.textRecognizer(options: ChineseTextRecognizerOptions.init())
    private let koreanTextRecognizer = TextRecognizer.textRecognizer(options: KoreanTextRecognizerOptions.init())
    
    private func processWithRecognizer(_ visionImage: VisionImage, recognizer: TextRecognizer) -> (blocks: [TextBlock], confidence: Float)? {
        do {
            let result = try recognizer.results(in: visionImage)
            // Calculate a confidence score based on the number of recognized blocks and their language confidence
            let confidence = result.blocks.reduce(0.0) { sum, block in
                // If no languages recognized, consider it low confidence
                guard !block.recognizedLanguages.isEmpty else { return sum + 0.1 }
                return sum + 1.0
            } / Float(max(1, result.blocks.count))
            return (blocks: result.blocks, confidence: confidence)
        } catch {
            print("Failed to process image with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getBlockArray(_ blocks: [TextBlock]) -> [[String: Any]] {
        var blockArray: [[String: Any]] = []
        
        for block in blocks {
            blockArray.append([
                "text": block.text,
                "recognizedLanguages": getRecognizedLanguages(block.recognizedLanguages),
                "cornerPoints": getCornerPoints(block.cornerPoints),
                "frame": getFrame(block.frame),
                "boundingBox": getBoundingBox(block.frame) as Any,
                "lines": getLineArray(block.lines),
            ])
        }
        
        return blockArray
    }
    
    private func getLineArray(_ lines: [TextLine]) -> [[String: Any]] {
        var lineArray: [[String: Any]] = []
        
        for line in lines {
            lineArray.append([
                "text": line.text,
                "recognizedLanguages": getRecognizedLanguages(line.recognizedLanguages),
                "cornerPoints": getCornerPoints(line.cornerPoints),
                "frame": getFrame(line.frame),
                "boundingBox": getBoundingBox(line.frame) as Any,
                "elements": getElementArray(line.elements),
            ])
        }
        
        return lineArray
    }
    
    private func getElementArray(_ elements: [TextElement]) -> [[String: Any]] {
        var elementArray: [[String: Any]] = []
        
        for element in elements {
            elementArray.append([
                "text": element.text,
                "cornerPoints": getCornerPoints(element.cornerPoints),
                "frame": getFrame(element.frame),
                "boundingBox": getBoundingBox(element.frame) as Any,
                "symbols": []
            ])
        }
        
        return elementArray
    }
    
    private func getRecognizedLanguages(_ languages: [TextRecognizedLanguage]) -> [String] {
        var languageArray: [String] = []
        
        for language in languages {
            guard let code = language.languageCode else {
                print("No language code exists")
                break;
            }
            languageArray.append(code)
        }
        
        return languageArray
    }
    
    private func getCornerPoints(_ cornerPoints: [NSValue]) -> [[String: CGFloat]] {
        var cornerPointArray: [[String: CGFloat]] = []
        
        for cornerPoint in cornerPoints {
            guard let point = cornerPoint as? CGPoint else {
                print("Failed to convert corner point to CGPoint")
                break;
            }
            cornerPointArray.append([ "x": point.x, "y": point.y])
        }
        
        return cornerPointArray
    }
    
    private func getFrame(_ frameRect: CGRect) -> [String: CGFloat] {
        let offsetX = (frameRect.midX - ceil(frameRect.width)) / 2.0
        let offsetY = (frameRect.midY - ceil(frameRect.height)) / 2.0

        let x = frameRect.maxX + offsetX
        let y = frameRect.minY + offsetY

        return [
          "x": frameRect.midX + (frameRect.midX - x),
          "y": frameRect.midY + (y - frameRect.midY),
          "width": frameRect.width,
          "height": frameRect.height,
          "boundingCenterX": frameRect.midX,
          "boundingCenterY": frameRect.midY
        ]
    }
    
    private func getBoundingBox(_ rect: CGRect?) -> [String: CGFloat]? {
         return rect.map {[
             "left": $0.minX,
             "top": $0.maxY,
             "right": $0.maxX,
             "bottom": $0.minY
         ]}
    }
    
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get image buffer from sample buffer.")
            return nil
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create bitmap from image.")
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        let visionImage = VisionImage(image: image)
        visionImage.orientation = .up
        
        // Process with both recognizers
        let chineseResult = processWithRecognizer(visionImage, recognizer: chineseTextRecognizer)
        let koreanResult = processWithRecognizer(visionImage, recognizer: koreanTextRecognizer)
        
        // Choose which result to use based on confidence
        let selectedBlocks: [TextBlock]
        if let chinese = chineseResult, let korean = koreanResult {
            // If we have results from both, use the one with higher confidence
            selectedBlocks = chinese.confidence >= korean.confidence ? chinese.blocks : korean.blocks
        } else if let chinese = chineseResult {
            selectedBlocks = chinese.blocks
        } else if let korean = koreanResult {
            selectedBlocks = korean.blocks
        } else {
            selectedBlocks = []
        }
        
        // Get the full text from the selected blocks
        let fullText = selectedBlocks.map { $0.text }.joined(separator: "\n")
        
        return [
            "result": [
                "text": fullText,
                "blocks": getBlockArray(selectedBlocks)
            ]
        ]
    }
}
