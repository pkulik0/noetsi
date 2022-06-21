//
//  NoteBackground.swift
//  noetsi
//
//  Created by pkulik0 on 12/06/2022.
//

import SwiftUI

/// The view used as the background of ``Note``.
struct NoteBackground: View {
    
    /// The ``Note``'s color.
    let color: Color
    
    /// Background pattern.
    let pattern: Note.Pattern
    
    private let patternOpacity = 0.15
    
    private var patternSize: Int {
        Int(pattern.size)
    }

    var body: some View {
        ZStack {
            color.opacity(0.4)
            
            if pattern.type != .None {
                GeometryReader { geo in
                    if pattern.type == .Grid {
                        ForEach(0..<Int(geo.size.width) / patternSize, id: \.self) { i in
                            Path { path in
                                let x = (i + 1) * patternSize
                                path.move(to: CGPoint(x: x, y: 0))
                                // Draw beyond max height to avoid buggy animations
                                path.addLine(to: CGPoint(x: x, y: Int(geo.size.height * 2)))
                                path.closeSubpath()
                            }
                            .stroke(color.opacity(patternOpacity), lineWidth: 2)
                        }
                    }
                    
                    ForEach(0..<Int(geo.size.height) / patternSize, id: \.self) { i in
                        Path { path in
                            let y = (i + 1) * patternSize
                            path.move(to: CGPoint(x: 0, y: y))
                            // Draw beyond max width to avoid buggy animations
                            path.addLine(to: CGPoint(x: Int(geo.size.width * 2), y: y))
                            path.closeSubpath()
                        }
                        .stroke(color.opacity(patternOpacity), lineWidth: 2)
                    }
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
    }
}
