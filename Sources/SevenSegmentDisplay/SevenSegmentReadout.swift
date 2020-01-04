//
//  SevenSegmentReadout.swift
//  Seven-Segment Display
//
//  Created by Ben Leggiero on 2020-01-02.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//

import SwiftUI
import SafePointer



/// A readout is a series of displays strung together horizontally
public struct SevenSegmentReadout: View {
    
    @MutableSafePointer
    public var color: Color
    
    @MutableSafePointer
    public var states: [SevenSegmentDisplay.DisplayState]
    
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.displaySpacing(in: geometry)) {
                ForEach(self.states, id: \.self) { state in
                    SevenSegmentDisplay(color: self.color, displayState: state)
                }
            }
        }
        .drawingGroup()
    }
}



public extension SevenSegmentReadout {
    /// Creates a new readout consisting of a series of displays which, together, resemble the given text
    ///
    /// - Parameters:
    ///   - sequence: The text to display
    ///   - color:    The color of each segment
    init<CharSequence>(resembling sequence: CharSequence, color: Color = .red)
        where
            CharSequence: Sequence,
            CharSequence.Element == Character
    {
        self.init(color: color, states: sequence.map { character in
            SevenSegmentDisplay.DisplayState(resembling: character) ?? []
        })
    }
    
    
    /// Sets the aspect ratio of this readout based on the number of characters it contains
    ///
    /// - Parameter ratio: The aspect ratio of each character in this readout
    func eachCharacterAspectRatio(_ ratio: CGFloat) -> some View {
        if states.isEmpty {
            return aspectRatio(ratio, contentMode: .fit)
        }
        else {
            return aspectRatio(ratio * CGFloat(states.count), contentMode: .fit)
        }
    }
    
    
    /// Sets the aspect ratio of this readout based on the number of characters it contains
    ///
    /// - Parameter ratio: The aspect ratio of each character in this readout
    @inlinable
    func eachCharacterAspectRatio(_ ratio: CGSize) -> some View {
        eachCharacterAspectRatio(ratio.width / ratio.height)
    }
}



private extension SevenSegmentReadout {
    func displaySpacing(in geometry: GeometryProxy) -> CGFloat {
        guard states.count > 1 else {
            return 0
        }
        
        return (geometry.size.width / 20) / CGFloat(states.count - 1)
    }
}



struct SevenSegmentReadout_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(resembling: digitCharacters)
                .previewDisplayName("Digits")
            
            preview(resembling: upperCaseLatinLetterCharacters)
                .previewDisplayName("Upper-Case Letters")
            
            preview(resembling: lowerCaseLatinLetterCharacters)
                .previewDisplayName("Lower-Case Letters")
            
            preview(resembling: "HELLO hello")
                .previewDisplayName("\"HELLO hello\"")
        }
    }
    
    
    static let digitCharacters = "0123456789"
    static let lowerCaseLatinLetterCharacters = "abcdefghijklmnopqrstuvwxyz"
    static let upperCaseLatinLetterCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    
    static func preview(resembling text: String) -> some View {
        SevenSegmentReadout(resembling: text)
            .frame(width: 9 * 4 * CGFloat(text.count), height: 16 * 4, alignment: .center)
    }
}
