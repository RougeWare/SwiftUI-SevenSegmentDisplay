//
//  SevenSegmentDisplay.swift
//  Seven-Segment Display
//
//  Created by Ben Leggiero on 2019-12-20.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//

import SwiftUI



public struct SevenSegmentDisplay: View {
    
    @State
    public var color: Color = .red
    
    @State
    public var displayState: DisplayState = []
    
    
    public init(color: Color, displayState: DisplayState) {
        self.color = color
        self.displayState = displayState
    }
    
    
    public var body: some View {
        GeometryReader { geometry in
            self.segments(in: geometry).drawingGroup()
        }
    }
}



public extension SevenSegmentDisplay {
    /// Creates a new seven-segment display, whose display state resembles the given character. If the character can't
    /// be represented on a 7-segment display, `nil` is returned.
    ///
    /// - Parameters:
    ///   - character: The character which would be approximated on the display.
    ///   - color:     _optional_ - The color of the resulting display. Defaults to `.red`
    init?(resembling character: Character, color: Color = .red) {
        guard let state = SevenSegmentDisplay.DisplayState(resembling: character) else {
            return nil
        }
        
        self.init(color: color, displayState: state)
    }
    
    
    /// Creates a blank seven-segment display
    ///
    /// - Parameter color: _optional_ - The color of the segments in the blank display. Defaults to `.red`
    static func blank(color: Color = .red) -> Self {
        self.init(color: color, displayState: [])
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
        let framePercent = percentSize(for: segment)
        let positionPercent = percentCenter(for: segment)
        return unpositionedSegmentView(segment)
            .position(percentX: positionPercent.x, percentY: positionPercent.y, in: geometry)
            .frame(percentWidth: framePercent.width, percentHeight: framePercent.height, in: geometry)
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
    
    
    func percentSize(for segment: Segment) -> CGSize {
        switch segment.kind {
        case .horizontal:
            return CGSize(width: 0.75, height: 0.1)
            
        case .vertical:
            return CGSize(width: 0.1, height: 0.45)
            
        case .dot:
            return CGSize(width: 0.1, height: 0.1)
        }
    }
    
    
    func percentCenter(for segment: Segment) -> CGPoint {
        switch segment {
        case .top: return CGPoint(x: 0.425, y: 0.05)
        case .center: return CGPoint(x: 0.425, y: 0.5)
        case .bottom: return CGPoint(x: 0.425, y: 0.95)
            
        case .topRight: return CGPoint(x: 0.8, y: 0.275)
        case .bottomRight: return CGPoint(x: 0.8, y: 0.725)
            
        case .topLeft: return CGPoint(x: 0.05, y: 0.275)
        case .bottomLeft: return CGPoint(x: 0.05, y: 0.725)
            
        case .period: return CGPoint(x: 0.95, y: 0.95)
        }
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
        
        public var rawValue: Segment.RawValue
        
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



internal extension SevenSegmentDisplay.DisplayState {
    
    
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
    
    static let lowerCaseLatinLetterCharacters = [Character]("abcdefghijklmnopqrstufwxyz")
    
    static let upperCaseLatinLetterCharacters = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    
    static func preview(resembling character: Character) -> some View {
        (SevenSegmentDisplay(resembling: character) ?? .blank())
            .frame(width: 9 * 4, height: 16 * 4, alignment: .center)
    }
}
