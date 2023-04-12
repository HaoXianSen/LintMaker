//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/4/7.
//

import Foundation

public class WaitingAnimation {
    public var prefix: String = "Loading... "
    public var animationTime: TimeInterval = 0.1
    public var animationSymbols: [String] = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]
    
    private var timer: Timer?
    
    public func begin() {
        if let _ = timer {
            return
        }
        print("", terminator: "\n")
        var counter = 0
        let unownedSelf = self
        self.timer = Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true, block: { timer in
            let symbol = unownedSelf.animationSymbols[counter % unownedSelf.animationSymbols.count]
            let loadingText = "\u{1B}[1A\u{1B}[K\(unownedSelf.prefix)\(symbol)"
            fflush(stdout)
            fputs(loadingText + "\n", stderr)
            counter += 1
        })
        RunLoop.current.add(self.timer!, forMode: .common)
        
        RunLoop.current.run()
    }
    
    public func end() {
        guard let timer = timer else {
            return
        }
        
        timer.invalidate()
        self.timer = nil
    }
}
