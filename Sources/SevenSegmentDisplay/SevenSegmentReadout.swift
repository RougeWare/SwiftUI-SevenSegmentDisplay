//
//  SevenSegmentReadout.swift
//  Seven-Segment Display
//
//  Created by Ben Leggiero on 2020-01-02.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//

import SwiftUI
import SafePointer



public struct SevenSegmentReadout: View {
    
    @MutableSafePointer
    public var color: Color
    
    @MutableSafePointer
    public var states: [SevenSegmentDisplay.DisplayState]
    
    
    public var body: some View {
        HStack {
            ForEach(states, id: \.self) { state in
                SevenSegmentDisplay(color: self.color, displayState: state)
            }
        }
        .drawingGroup()
    }
}



public extension SevenSegmentReadout {
    init<CharSequence>(resembling sequence: CharSequence, color: Color = .red)
        where
            CharSequence: Sequence,
            CharSequence.Element == Character
    {
        self.init(color: color, states: sequence.map { character in
            SevenSegmentDisplay.DisplayState(resembling: character) ?? []
        })
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
