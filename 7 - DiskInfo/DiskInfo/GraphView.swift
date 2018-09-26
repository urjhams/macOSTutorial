//
//  GraphView.swift
//  DiskInfo
//
//  Created by Quân Đinh on 26.09.18.
//  Copyright © 2018 erndev. All rights reserved.
//

import Cocoa

/// This class was marked as @IBDesignable, so any change can apply and show on Interface Builder
@IBDesignable class GraphView: NSView {
    
    fileprivate struct Constants {
        static let barHeight: CGFloat = 30.0
        static let barMinHeight: CGFloat = 20.0
        static let barMaxHeight: CGFloat = 40.0
        static let marginSize: CGFloat = 20.0
        static let pieChartWidthPercentage: CGFloat = 1.0 / 3.0
        static let pieChartBorderWidth: CGFloat = 1.0
        static let pieChartMinRadius: CGFloat = 30.0
        static let pieChartGradientAngle: CGFloat = 90.0
        static let barChartCornerRadius: CGFloat = 4.0
        static let barChartLegendSquareSize: CGFloat = 8.0
        static let legendTextMargin: CGFloat = 5.0
    }
    
    @IBInspectable var barHeight: CGFloat = Constants.barHeight {
        didSet {
            barHeight = max(min(barHeight, Constants.barMaxHeight), Constants.barMinHeight)
        }
    }
    
    //-- Inspectable var MUST declare type (...:NSColor = ...),
    //   use for show attributes on Interface Builder to alter
    @IBInspectable var pieChartUsedLineColor:NSColor = NSColor.pieChartUsedStrokeColor
    @IBInspectable var pieChartAvailableLineColor:NSColor = NSColor.pieChartAvailableStrokeColor
    @IBInspectable var pieChartAvailableFillColor:NSColor = NSColor.pieChartAvailableFillColor
    @IBInspectable var pieChartGradientStartColor:NSColor = NSColor.pieChartGradientStartColor
    @IBInspectable var pieChartGradientEndColor:NSColor = NSColor.pieChartGradientEndColor
    
    @IBInspectable var barChartAvailableLineColor:NSColor = NSColor.availableStrokeColor
    @IBInspectable var barChartAvailAbleFillColor:NSColor = NSColor.availableFillColor
    @IBInspectable var barChartAppsLineColor:NSColor = NSColor.appsStrokeColor
    @IBInspectable var barChartAppsFillColor:NSColor = NSColor.appsFillColor
    @IBInspectable var barChartMovieLineColor:NSColor = NSColor.moviesStrokeColor
    @IBInspectable var barChartMovieFillColor:NSColor = NSColor.moviesFillColor
    @IBInspectable var barChartPhotosLineColor:NSColor = NSColor.photosStrokeColor
    @IBInspectable var barChartPhotosFillColor:NSColor = NSColor.photosFillColor
    @IBInspectable var barChartAudioLineColor:NSColor = NSColor.audioStrokeColor
    @IBInspectable var barChartAudioFillColor:NSColor = NSColor.audioFillColor
    @IBInspectable var barChartOtherLineColor:NSColor = NSColor.othersStrokeColor
    @IBInspectable var barChartOtherFillColor:NSColor = NSColor.othersFillColor
    
    func colorsForFileType(fileType: FileType) -> (strokeColor: NSColor, fillColor: NSColor) {
        switch fileType {
        case .audio(_, _):
            return (barChartAudioLineColor, barChartAudioFillColor)
        case .movies(_, _):
            return (barChartMovieLineColor, barChartMovieFillColor)
        case .photos(_, _):
            return (barChartPhotosLineColor, barChartPhotosFillColor)
        case .apps(_, _):
            return (barChartAppsLineColor,barChartAppsFillColor)
        case .other(_, _):
            return (barChartOtherLineColor, barChartOtherFillColor)
        }   // underscore ("_") means any possible value in a tuple
    }
    
    fileprivate var bytesFormatter = ByteCountFormatter()
    
    var fileDistribution: FilesDistribution? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func prepareForInterfaceBuilder() {
        let used = Int64(100000000000)
        let available = used / 3
        let filesBytes = used / 5
        let distribution: [FileType] = [.apps(bytes: filesBytes / 2, percent: 0.1),
                                        .photos(bytes: filesBytes, percent: 0.2),
                                        .movies(bytes: filesBytes * 2, percent: 0.15),
                                        .audio(bytes: filesBytes, percent: 0.18),
                                        .other(bytes: filesBytes, percent: 0.2)]
        
        fileDistribution = FilesDistribution(capacity: used + available,
                                             available: available,
                                             distribution: distribution)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = NSGraphicsContext.current?.cgContext
        self.drawBarGraphInContext(context: context)
        self.drawPieChart()
        
//        NSColor.white.setFill()
//
//        // __NSRectFill(self.bounds)
//        // NSRectFill() changed to __NSRectFill(), seem it is low-level function
//        // should use bounds.fill() instead
//        self.bounds.fill()
    }
}

extension GraphView {
    
    func drawRoundedRect(rect: CGRect, inContext context: CGContext?,
                         radius: CGFloat, borderColor: CGColor,
                         fillColor: CGColor) {
        
        // create a mutable path
        let path = CGMutablePath()
        
        // from the current path:
        // move center point to botom of rectangle
        // add lines with rounded corners -> got the segment lines of the pie chart
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius)
        
        context?.setLineWidth(1.0)
        context?.setFillColor(fillColor)
        context?.setStrokeColor(borderColor)
        
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
        // after this will have a rounded rectangle (not a circle yet)
        // with start point from the center of bottom line
    }
}

// MARK: - Calculations

extension GraphView {
    
    /// The pie chart at center vertically and one third of view's width
    func pieChartRectangle() -> CGRect {
        let width = bounds.size.width * Constants.pieChartWidthPercentage - 2 * Constants.marginSize
        let height = bounds.size.height - 2 * Constants.marginSize
        let diameter = max(min(width, height), Constants.pieChartMinRadius)
        return CGRect(x: Constants.marginSize,
                      y: bounds.midY - diameter / 2.0,
                      width: diameter, height: diameter)
    }
    
    /// The bar chart takes two third of the pie chart's width and above the view's vertical center
    func barChartRectangle() -> CGRect {
        let pieChartRect = pieChartRectangle()
        let width = bounds.size.width - pieChartRect.maxX - 2 * Constants.marginSize
        return CGRect(x: pieChartRect.maxX + Constants.marginSize,
                      y: pieChartRect.midY + Constants.marginSize,
                      width: width, height: barHeight)
    }
    
    /// The graphic legend base on minimum y position of the pie chart and the margins
    func barChartLegendRectangle() -> CGRect {
        let barChartRect = barChartRectangle()
        return barChartRect.offsetBy(dx: 0.0,
                                     dy: -(barChartRect.size.height + Constants.marginSize))
    }
}

extension GraphView {
    
    /// draw the charts
    func drawBarGraphInContext(context: CGContext?) {
        
        // -------- draw segments
        let barChartRect = barChartRectangle()
        drawRoundedRect(rect: barChartRect,
                        inContext: context,
                        radius: Constants.barChartCornerRadius,
                        borderColor: barChartAvailableLineColor.cgColor,
                        fillColor: barChartAvailAbleFillColor.cgColor)
        
        if let fileTypes = fileDistribution?.distribution, let capacity = fileDistribution?.capacity, capacity > 0 {
            
            var clipRect = barChartRect
            for (index, fileType) in fileTypes.enumerated() {
                
                // caculate the clipping rect
                let fileTypeInfo = fileType.fileTypeInfo
                let clipWidth = floor(barChartRect.width * CGFloat(fileTypeInfo.percent))
                clipRect.size.width = clipWidth
                
                // save state of current context, set clipping & draw rect then restore state of context
                context?.saveGState()
                context?.clip(to: clipRect)
                let fileTypeColors = colorsForFileType(fileType: fileType)
                drawRoundedRect(rect: barChartRect,
                                inContext: context,
                                radius: Constants.barChartCornerRadius,
                                borderColor: fileTypeColors.strokeColor.cgColor,
                                fillColor: fileTypeColors.fillColor.cgColor)
                context?.restoreGState()
                
                // move origin x of clipping rect before next loop
                clipRect.origin.x = clipRect.maxX
                
                // ------ strings
                let legendRectWidth = barChartRect.size.width / CGFloat(fileTypes.count)
                let legendOriginX = barChartRect.origin.x + floor(CGFloat(index) * legendRectWidth)
                let legnendOriginY = barChartRect.minY - 2 * Constants.marginSize
                let legendSquareRect = CGRect(x: legendOriginX,
                                              y: legnendOriginY,
                                              width: Constants.barChartLegendSquareSize,
                                              height: Constants.barChartLegendSquareSize)
                let legendSquarePath = CGMutablePath()
                legendSquarePath.addRect(legendSquareRect)
                context?.addPath(legendSquarePath)
                context?.setFillColor(fileTypeColors.fillColor.cgColor)
                context?.setStrokeColor(fileTypeColors.strokeColor.cgColor)
                context?.drawPath(using: .fillStroke)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                paragraphStyle.alignment = .left
                let nameTextAttributes = [NSAttributedString.Key.font : NSFont.barChartLegendNameFont,
                                          NSAttributedString.Key.paragraphStyle : paragraphStyle]
                
                let nameTextSize = fileType.name.size(withAttributes: nameTextAttributes)
                let legendTextOriginX = legendSquareRect.maxX + Constants.legendTextMargin
                let legendTextOriginY = legnendOriginY - 2 * Constants.pieChartBorderWidth
                let legendNameRect = CGRect(x: legendTextOriginX,
                                            y: legendTextOriginY,
                                            width: legendRectWidth - legendSquareRect.size.width - 2 * Constants.legendTextMargin,
                                            height: nameTextSize.height)
                
                fileType.name.draw(in: legendNameRect, withAttributes: nameTextAttributes)
                
                let bytesText = bytesFormatter.string(fromByteCount: fileTypeInfo.bytes)
                let bytesTextAttributes = [NSAttributedString.Key.font : NSFont.barChartLegendSizeTextFont,
                                           NSAttributedString.Key.paragraphStyle : paragraphStyle,
                                           NSAttributedString.Key.foregroundColor : NSColor.secondaryLabelColor]
                let bytesTextSize = bytesText.size(withAttributes: bytesTextAttributes)
                let bytesTextRect = legendNameRect.offsetBy(dx: 0.0, dy: -bytesTextSize.height)
                bytesText.draw(in: bytesTextRect, withAttributes: bytesTextAttributes)
            }
        }
    }
    
    /// Using BezierPath instead of core graphic, automatically get the current view's context as context
    func drawPieChart() {
        guard let fileDistribution = fileDistribution else {
            return
        }
        
        // create a circle path
        let rect = pieChartRectangle()
        let circle = NSBezierPath(ovalIn: rect)
        pieChartAvailableFillColor.setFill()
        pieChartAvailableLineColor.setStroke()
        circle.stroke()
        circle.fill()
        
        // create a path for used space circle segment
        let path = NSBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let usedPercent = Double(fileDistribution.capacity - fileDistribution.available) / Double(fileDistribution.capacity)
        let endAngle = CGFloat(360 * usedPercent)
        let radius = rect.size.width / 2.0
        path.move(to: center)                               // move to center of the circle
        path.line(to: CGPoint(x: rect.maxX, y: center.y))   // add horizontal line from center to right side of the circle
        path.appendArc(withCenter: center,
                       radius: radius,
                       startAngle: 0,
                       endAngle: endAngle)                  // add arc from current point to the caculated angle
        path.close()                                        // close the path, add line from arc's end point back to center point
        
        // set stroke color and stroke the path
        pieChartUsedLineColor.setStroke()
        path.stroke()
        
        // ---- draw the gradients
        if let gradient = NSGradient(starting: pieChartGradientStartColor, ending: pieChartGradientEndColor) {
            gradient.draw(in: path, angle: Constants.pieChartGradientAngle)
        }
        
        // --- draw the string text
        let usedMidAngle = endAngle / 2.0
        let availableMidAngle = (360.0 - endAngle) / 2.0
        let halfRadius = radius / 2.0
        
        // used space text attribute & draw
        let usedSpaceText = bytesFormatter.string(fromByteCount: fileDistribution.capacity)
        let usedSpaceTextAttributes = [NSAttributedString.Key.font : NSFont.pieChartLegendFont,
                                       NSAttributedString.Key.foregroundColor : NSColor.pieChartUsedSpaceTextColor]
        let usedSpaceTextSize = usedSpaceText.size(withAttributes: usedSpaceTextAttributes)
        let xPos = rect.midX + CGFloat(cos(usedMidAngle.radians)) * halfRadius - (usedSpaceTextSize.width / 2.0)
        let yPos = rect.midY + CGFloat(sin(usedMidAngle.radians)) * halfRadius - (usedSpaceTextSize.height / 2.0)
        usedSpaceText.draw(at: CGPoint(x: xPos, y: yPos), withAttributes: usedSpaceTextAttributes)
        
        // available space text attribute & draw
        let availableSpaceText = bytesFormatter.string(fromByteCount: fileDistribution.available)
        let availableSpaceTextAttributes = [NSAttributedString.Key.font : NSFont.pieChartLegendFont,
                                            NSAttributedString.Key.foregroundColor : NSColor.pieChartAvailableSpaceTextColor]
        let availableSpaceTextSize = availableSpaceText.size(withAttributes: availableSpaceTextAttributes)
        let availableXPos = rect.midX + cos(-availableMidAngle.radians) * halfRadius - (availableSpaceTextSize.width / 2.0)
        let availableYPos = rect.midY + sin(-availableMidAngle.radians) * halfRadius - (availableSpaceTextSize.height / 2.0)
        availableSpaceText.draw(at: CGPoint(x: availableXPos, y: availableYPos), withAttributes: availableSpaceTextAttributes)
    }
}
