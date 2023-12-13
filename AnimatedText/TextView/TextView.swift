//
//  TextView.swift
//  AnimatedText
//
//  Created by Damra on 27.11.2023.
//

import Foundation
import SwiftUI

struct TextView: View {
    let string: String
    let fontSize: CGFloat
    
    @State private var scaleFactors: [CGFloat] = []
    @State private var selectedCharacterIndex: Int? = nil
    @State private var characterCenters: [CGPoint] = [] // Array to store center positions of each character
    
    private let selectedScale: CGFloat = 1.7
    private let unSelectedScale: CGFloat = 1
    private let adjacentScale: CGFloat = 1.2
    
    init(_ string: String, fontSize: CGFloat) {
        self.string = string
        self.fontSize = fontSize
        _scaleFactors = State(initialValue: Array(repeating: 1.0, count: Array(string).count))
    }
    
    var body: some View {
        ZStack{
            Color.primary.ignoresSafeArea()
            
            HStack(spacing: 0.5) {
                ForEach(Array(string.enumerated()), id: \.offset) { (index, character) in
                    Text(String(character))
                        .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(calculateForegroundColor(for: index))
                        .scaleEffect(scaleFactors[index])
                        .offset(y: -scaleFactors[index] * (fontSize + 5))
                        .zIndex(scaleFactors[index])
                }
            }
            .gesture(dragGesture())
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            characterCenters = getCharacterCenters(in: geo)
                        }
                }
            )
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    TextView("HELLO", fontSize: 45)
}

extension TextView {
    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let selectedIndex = self.selectedCharacterIndex
                let dragPosition = value.location // current drag position
                
                if let index = self.calculateSelectedIndex(for: dragPosition) {
                    if index != selectedIndex {
                        print("index:", index)
                        //light haptic feedback when focused index changes
                        HapticManager.shared.generateFeedback()
                        //update selected index and scale factors
                        withAnimation(.spring()) {
                            self.selectedCharacterIndex = index
                            self.updateScaleFactors(for: index)
                        }
                    }
                }
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    self.selectedCharacterIndex = nil
                    self.resetScaleFactors()
                }
            }
    }
    
    private func calculateSelectedIndex(for position: CGPoint) -> Int? {
        //calculate distance between position and center each character
        let distances = characterCenters.map {
            distance($0, position)
        }
        guard let closestIndex = distances.enumerated().min(by: {$0.1 < $1.1})?.offset else {return nil}
        
        return closestIndex
        
    }
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return sqrt(xDist * xDist + yDist * yDist)
    }
    
    private func updateScaleFactors(for index: Int) {
        for i in 0..<scaleFactors.count {
            if i == index {
                scaleFactors[i] = selectedScale
            } else if i == index || i == index + 1 {
                scaleFactors[i] = adjacentScale
            }else {
                scaleFactors[i] = unSelectedScale
            }
        }
    }
    
    private func resetScaleFactors() {
        scaleFactors = Array(repeating: unSelectedScale, count: string.count)
    }
    
    private func getCharacterCenters(in geometry: GeometryProxy) -> [CGPoint] {
        var centers: [CGPoint] = []
        //Loop through each character in the string
        for index in 0..<string.count {
            //Calculate the bounding box for the current character.
            let bounds = geometry.frame(in: .local)
            let size = CGSize(width: bounds.width / CGFloat(string.count), height: bounds.height)
            let origin = CGPoint(x: bounds.minX + size.width * CGFloat(index), y: bounds.minY)
            let center = CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
            
            //add the center point to the array
            centers.append(center)
        }
        return centers
    }
    
    private func calculateForegroundColor(for index: Int) -> Color {
        guard let selectedIndex = selectedCharacterIndex else {return Color.white}
        
        let distance = CGFloat(abs(selectedIndex - index))
        if distance == 0 {
            return Color.color1
        }else if distance == 1 {
            return Color.color2
        }else {
            return Color.color3
        }
    }
}


