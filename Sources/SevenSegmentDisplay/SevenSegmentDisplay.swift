//
//  SevenSegmentDisplay.swift
//  Seven-Segment Display
//
//  Created by Ben Leggiero on 2019-12-20.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//

import SwiftUI
import SafePointer
import RectangleTools



/// Seven display segments placed together to be a 7-segment display. And a period.
public struct SevenSegmentDisplay: View {
    
    @MutableSafePointer
    public var color: Color = .red
    
    @MutableSafePointer
    public var displayState: DisplayState = []
    
    /// The skew to apply to this display
    public var skew: Skew = .none
    
    
    public var body: some View {
        GeometryReader { geometry in
            self.segments(in: geometry)
                .padding(.horizontal, self.skew.paddingNeededToEnsureFullDisplayIsShown(in: geometry.size))
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: self.skew.cgAffineTransformCValue, d: 1, tx: 0, ty: 0))
        }
        .drawingGroup()
    }
}



public extension SevenSegmentDisplay {
    /// Creates a new seven-segment display, whose display state resembles the given character. If the character can't
    /// be represented on a 7-segment display, `nil` is returned.
    ///
    /// - Parameters:
    ///   - character: The character which would be approximated on the display.
    ///   - color:     _optional_ - The color of the resulting display. Defaults to `.red`
    ///   - skew:      The skew to apply to this display
    init?(resembling character: Character, color: Color = .red, skew: Skew = .none) {
        guard let state = SevenSegmentDisplay.DisplayState(resembling: character) else {
            return nil
        }
        
        self.init(color: color, displayState: state, skew: skew)
    }
    
    
    /// Creates a blank seven-segment display
    ///
    /// - Parameter color: _optional_ - The color of the segments in the blank display. Defaults to `.red`
    static func blank(color: Color = .red) -> Self {
        self.init(color: color, displayState: [])
    }
    
    
    
    /// The skew to apply to a 7-segment display
    enum Skew {
        /// No skew; it's perfectly orthogonal
        case none
        
        /// Apply a custom skew to the display.
        ///
        /// See also `.traditional`
        ///
        /// - Parameter affineTransformCValue: The value to apply to the C component of the affine transform matrix
        case custom(affineTransformCValue: CGFloat)
        
        
        /// The value to apply to the C component of the affine transform matrix
        var cgAffineTransformCValue: CGFloat {
            switch self {
            case .none: return 0
            case .custom(let affineTransformCValue): return affineTransformCValue
            }
        }
        
        
        func paddingNeededToEnsureFullDisplayIsShown(in parentFrameSize: CGSize) -> CGFloat {
            return abs(cgAffineTransformCValue) * parentFrameSize.width
        }
        
        
        /// A good skew to mimic traditional 7-segment displays
        public static let traditional = Skew.custom(affineTransformCValue: -0.1)
    }
}



private extension SevenSegmentDisplay {
    func segments(in geometry: GeometryProxy) -> some View {
        Group {
            self.positionedSegmentView(.top, geometry: geometry)
            self.positionedSegmentView(.topRight, geometry: geometry)
            self.positionedSegmentView(.bottomRight, geometry: geometry)
            self.positionedSegmentView(.bottom, geometry: geometry)
            self.positionedSegmentView(.bottomLeft, geometry: geometry)
            self.positionedSegmentView(.topLeft, geometry: geometry)
            self.positionedSegmentView(.center, geometry: geometry)
            self.positionedSegmentView(.period, geometry: geometry)
        }
    }
    
    
    func positionedSegmentView(_ segment: Segment, geometry: GeometryProxy) -> some View {
        let frame = self.frame(for: segment, inGeometryOfSize: geometry.size)
        return unpositionedSegmentView(segment)
            .position(x: frame.x, y: frame.y)
            .frame(width: frame.width, height: frame.height)
    }
    
    
    func unpositionedSegmentView(_ segment: Segment) -> DisplaySegmentView {
        DisplaySegmentView(color: self.adjustedColor(for: segment), kind: segment.kind)
    }
    
    
    func adjustedColor(for segment: Segment) -> Color {
        return isSegmentOn(segment) ? self.color : self.color.opacity(0.1)
    }
    
    
    func isSegmentOn(_ segment: Segment) -> Bool {
        return self.displayState.contains(segment.displayState)
    }
    
    
    func frame(for segment: Segment, inGeometryOfSize parentSize: CGSize) -> CGRect {
        let minMeasurement = min(parentSize.measurementX, parentSize.measurementY)
        let thin = max(1, minMeasurement * 0.1)
        let halfThin = thin / 2
        
        let segmentSize: CGSize = {
            switch segment.kind {
            case .horizontal:
                return CGSize(width: parentSize.width - (thin * 2.5), height: thin)
                
            case .vertical:
                return CGSize(width: thin, height: (parentSize.height - thin) / 2)
                
            case .dot:
                return CGSize(width: thin, height: thin)
            }
        }()
        
        let segmentOrigin: CGPoint = {
            switch segment {
            case .top: return CGPoint(x: (segmentSize.width / 2) + halfThin, y: halfThin)
            case .center: return CGPoint(x: (segmentSize.width / 2) + halfThin, y: parentSize.height / 2)
            case .bottom: return CGPoint(x: (segmentSize.width / 2) + halfThin, y: parentSize.height - halfThin)
                
            case .topRight: return CGPoint(x: parentSize.width - (thin * 2), y: ((parentSize.height - thin) / 4) + halfThin)
            case .bottomRight: return CGPoint(x: parentSize.width - (thin * 2), y: ((parentSize.height - thin) * (3 / 4)) + halfThin)
                
            case .topLeft: return CGPoint(x: halfThin, y: ((parentSize.height - thin) / 4) + halfThin)
            case .bottomLeft: return CGPoint(x: halfThin, y: ((parentSize.height - thin) * (3 / 4)) + halfThin)
                
            case .period: return CGPoint(x: parentSize.maxX - halfThin, y: parentSize.maxY - halfThin)
            }
        }()
        
        return CGRect(origin: segmentOrigin, size: segmentSize)
    }
}



public extension SevenSegmentDisplay {
    enum Segment: UInt8 {
        case top         = 0b00000001
        case topRight    = 0b00000010
        case bottomRight = 0b00000100
        case bottom      = 0b00001000
        case bottomLeft  = 0b00010000
        case topLeft     = 0b00100000
        case center      = 0b01000000
        case period      = 0b10000000
        
        
        
        typealias OptionSet = SevenSegmentDisplay.DisplayState
    }

    
    
    
    struct DisplayState: OptionSet {
        
        public typealias RawValue = Segment.RawValue
        
        public var rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        
        public init(_ segment: Segment) {
            self.rawValue = segment.rawValue
        }
        
        
        public static let top         = DisplayState(.top)
        public static let topRight    = DisplayState(.topRight)
        public static let bottomRight = DisplayState(.bottomRight)
        public static let bottom      = DisplayState(.bottom)
        public static let bottomLeft  = DisplayState(.bottomLeft)
        public static let topLeft     = DisplayState(.topLeft)
        public static let center      = DisplayState(.center)
        public static let period      = DisplayState(.period)
    }
}



internal extension SevenSegmentDisplay.Segment {
    
    var kind: DisplaySegmentView.Kind {
        switch self {
        case .top,
             .center,
             .bottom:
            return .horizontal
            
        case .topRight,
             .bottomRight,
             .bottomLeft,
             .topLeft:
            return .vertical
            
        case .period:
            return .dot
        }
    }
    
    
    @inline(__always)
    var bitMask: RawValue {
        return rawValue
    }
    
    
    var displayState: SevenSegmentDisplay.DisplayState {
        return .init(self)
    }
}



public extension SevenSegmentDisplay.DisplayState {
    
    
    private static let characterEncodings: [Character : Self] = [
        "0" : [.top, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft],
        "1" : [.topRight, .bottomRight],
        "2" : [.top, .topRight, .center, .bottomLeft, .bottom],
        "3" : [.top, .topRight, .center, .bottomRight, .bottom],
        "4" : [.topLeft, .topRight, .center, .bottomRight],
        "5" : [.top, .topLeft, .center, .bottomRight, .bottom],
        "6" : [.top, .topLeft, .center, .bottomRight, .bottom, .bottomLeft],
        "7" : [.top, .topRight, .bottomRight],
        "8" : [.top, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft, .center],
        "9" : [.bottom, .bottomRight, .topRight, .top, .topLeft, .center],
        
        "A" : [.bottomLeft, .topLeft, .top, .topRight, .bottomRight, .center],
//        "B" : [],
        "C" : [.top, .topLeft, .bottomLeft, .bottom],
//        "D" : [],
        "E" : [.top, .topLeft, .bottomLeft, .bottom, .center],
        "F" : [.top, .topLeft, .bottomLeft, .center],
//        "G" : [],
        "H" : [.topLeft, .bottomLeft, .center, .topRight, .bottomRight],
        "I" : [.topRight, .bottomRight],
        "J" : [.topRight, .bottomRight, .bottom, .bottomLeft],
//        "K" : [],
        "L" : [.topLeft, .bottomLeft, .bottom],
//        "M" : [],
//        "N" : [],
        "O" : [.top, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft],
        "P" : [.bottomLeft, .topLeft, .top, .topRight, .center],
//        "Q" : [],
//        "R" : [],
        "S" : [.top, .topLeft, .center, .bottomRight, .bottom],
//        "T" : [],
        "U" : [.topLeft, .bottomLeft, .bottom, .bottomRight, .topRight],
//        "V" : [],
//        "W" : [],
//        "X" : [],
//        "Y" : [],
        "Z" : [.top, .topRight, .center, .bottomLeft, .bottom],
        
        "a" : [.top, .topRight, .center, .bottomLeft, .bottom, .bottomRight],
        "b" : [.center, .bottomRight, .bottom, .bottomLeft, .topLeft],
        "c" : [.center, .bottomLeft, .bottom],
        "d" : [.center, .bottomLeft, .bottom, .bottomRight, .topRight],
        "e" : [.center, .topRight, .top, .topLeft, .bottomLeft, .bottom],
        "f" : [.bottomLeft, .topLeft, .top, .center],
        "g" : [.center, .topLeft, .top, .topRight, .bottomRight, .bottom],
        "h" : [.topLeft, .bottomLeft, .center, .bottomRight],
        "i" : [.bottomRight],
        "j" : [.topRight, .bottomRight, .bottom, .bottomLeft],
//        "k" : [],
        "l" : [.topLeft, .bottomLeft],
//        "m" : [],
        "n" : [.bottomLeft, .center, .bottomRight],
        "o" : [.center, .bottomRight, .bottom, .bottomLeft],
        "p" : [.bottomLeft, .topLeft, .top, .topRight, .center],
        "q" : [.bottomRight, .topRight, top, .topLeft, .center],
        "r" : [.bottomLeft, .center],
        "s" : [.top, .topLeft, .center, .bottomRight, .bottom],
        "t" : [.topLeft, .bottomLeft, .bottom, .center],
        "u" : [.bottomLeft, .bottom, .bottomRight],
//        "v" : [],
//        "w" : [],
//        "x" : [],
        "y" : [.topLeft, .center, .topRight, .bottomRight, .bottom],
        "z" : [.top, .topRight, .center, .bottomLeft, .bottom],
        
        " " : [],
        "-" : [.center],
        "_" : [.bottom],
        "=" : [.center, .bottom],
        "'" : [.topRight],
    ]
    
    
    
    init?(resembling character: Character, allowAutoToggleCase: Bool = true) {
        if let encoded = Self.characterEncodings[character] {
            self = encoded
        }
        else if allowAutoToggleCase,
            let toggleCaseCharacter = character.togglingCase().first,
            let encodedToggleCase = Self.characterEncodings[toggleCaseCharacter]
        {
            self = encodedToggleCase
        }
        else {
            return nil
        }
    }
    
    
    /// Lets you set or check whether this display state has a period
    var hasPeriod: Bool {
        get { contains(.period) }
        set { insert(.period) }
    }
    
    
    /// Returns a copy of this display state with (or without) a period
    ///
    /// - Parameter hasPeriod: _optional_ - Iff `true`, returns this same display state with a period
    func withPeriod(_ hasPeriod: Bool = true) -> Self {
        var copy = self
        copy.hasPeriod = hasPeriod
        return copy
    }
}



extension SevenSegmentDisplay.DisplayState: Hashable {}



private extension Character {
    func togglingCase() -> String {
        if isLowercase {
            return uppercased()
        }
        else if isUppercase {
            return lowercased()
        }
        else {
            return String(self)
        }
    }
}



struct SevenSegmentDisplay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                ForEach(digitCharacters, id: \.self) { numChar in
                    preview(resembling: numChar)
                }
            }
                .drawingGroup()
                .previewDisplayName("Digits")
            
            HStack {
                ForEach(upperCaseLatinLetterCharacters, id: \.self) { lowerCaseChar in
                    preview(resembling: lowerCaseChar)
                }
            }
                .drawingGroup()
                .previewDisplayName("Upper-Case Letters")
            
            HStack {
                ForEach(lowerCaseLatinLetterCharacters, id: \.self) { lowerCaseChar in
                    preview(resembling: lowerCaseChar)
                }
            }
                .drawingGroup()
                .previewDisplayName("Lower-Case Letters")
            
            HStack {
                ForEach(Array("HELLO hello"), id: \.self) { lowerCaseChar in
                    preview(resembling: lowerCaseChar)
                }
            }
                .drawingGroup()
                .previewDisplayName("\"HELLO hello\"")
        }
    }
    
    
    static let digitCharacters = [Character]("0123456789")
    
    static let lowerCaseLatinLetterCharacters = [Character]("abcdefghijklmnopqrstuvwxyz")
    
    static let upperCaseLatinLetterCharacters = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    
    static func preview(resembling character: Character) -> some View {
        (SevenSegmentDisplay(resembling: character) ?? .blank())
            .frame(width: 9 * 4, height: 16 * 4, alignment: .center)
    }
}
