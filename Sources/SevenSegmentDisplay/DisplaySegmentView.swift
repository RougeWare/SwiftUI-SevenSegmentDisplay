//
//  DisplaySegmentView.swift
//  Seven-Segment Display
//
//  Created by Ben Leggiero on 2019-12-20.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//

import SwiftUI
import RectangleTools
import SafePointer



public struct DisplaySegmentView: View {
    
    @MutableSafePointer
    public var color: Color = .red
    
    @MutableSafePointer
    public var kind: Kind = .dot
    
    
    public init(color: Color, kind: Kind) {
        self.color = color
        self.kind = kind
    }
    
    
    public var body: some View {
        GeometryReader { geometry in
            self.path(in: geometry)
                .fill(self.color)
        }
        .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
    }
}



public extension DisplaySegmentView {
    enum Kind {
        case vertical
        case horizontal
        case dot
    }
}



private extension DisplaySegmentView {
    func path(in geometry: GeometryProxy) -> Path {
        let localFrame = geometry.frame(in: .local)
        
        switch kind {
        case .vertical:
            return verticalSegmentPath(in: localFrame)
            
        case .horizontal:
            return horizontalSegmentPath(in: localFrame)
            
        case .dot:
            return dotSegmentPath(in: localFrame)
        }
    }
    
    
    private func verticalSegmentPath(in localFrame: CGRect) -> Path {
        Path { path in
            path.move(to: localFrame.midXmaxY)
            path.addLine(to: localFrame.maxX(yPercent: 0.9))
            path.addLine(to: localFrame.maxX(yPercent: 0.1))
            path.addLine(to: localFrame.midXminY)
            path.addLine(to: localFrame.minX(yPercent: 0.1))
            path.addLine(to: localFrame.minX(yPercent: 0.9))
            path.closeSubpath()
        }
    }
    
    
    private func horizontalSegmentPath(in localFrame: CGRect) -> Path {
        Path { path in
            path.move(to: localFrame.maxXmidY)
            path.addLine(to: localFrame.maxY(xPercent: 0.9))
            path.addLine(to: localFrame.maxY(xPercent: 0.1))
            path.addLine(to: localFrame.minXmidY)
            path.addLine(to: localFrame.minY(xPercent: 0.1))
            path.addLine(to: localFrame.minY(xPercent: 0.9))
            path.closeSubpath()
        }
    }
    
    
    private func dotSegmentPath(in localFrame: CGRect) -> Path {
        Path(ellipseIn: localFrame)
    }
}

struct DisplaySegment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DisplaySegmentView(color: .red, kind: .vertical)
                .frame(width: 4, height: 16, alignment: .center)
            DisplaySegmentView(color: .red, kind: .horizontal)
                .frame(width: 16, height: 4, alignment: .center)
            DisplaySegmentView(color: .red, kind: .dot)
                .frame(width: 4, height: 4, alignment: .center)
        }
    }
}
