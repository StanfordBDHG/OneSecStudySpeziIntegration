//
//  IfIOS17Modifier.swift
//  SpeziOneSec
//
//  Created by Lennart Fischer on 21.08.25.
//

public import SwiftUI

public struct ConditionalApply<Transformed: View>: ViewModifier {
    public let transform: (AnyView) -> Transformed
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            transform(AnyView(content))
        } else {
            content
        }
    }
}

public extension View {
    func conditionallyApply<Transformed: View>(
        @ViewBuilder _ transform: @escaping (AnyView) -> Transformed
    ) -> some View {
        self.modifier(ConditionalApply(transform: transform))
    }
}
