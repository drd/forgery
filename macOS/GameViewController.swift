//
//  GameViewController.swift
//  mesher macOS
//
//  Created by Eric O'Connell on 12/26/18.
//  Copyright © 2018 Eric O'Connell. All rights reserved.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.clearColor = MTLClearColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        mtkView.device = defaultDevice

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
    
    override func scrollWheel(with event: NSEvent) {
        if (event.modifierFlags.isEmpty) {
            renderer?.scrolled(
                delta: float3(
                    Float(event.scrollingDeltaX),
                    Float(event.scrollingDeltaY),
                    0
                )
            )
        } else if (event.modifierFlags.contains(.option) && event.modifierFlags.contains(.shift)) {
            renderer?.rotated(
                delta: float3(
                    0,
                    -Float(event.scrollingDeltaY),
                    -Float(event.scrollingDeltaX)
                )
            )
        } else if (event.modifierFlags.contains(.option)) {
            renderer?.rotated(
                delta: float3(
                    -Float(event.scrollingDeltaY),
                    -Float(event.scrollingDeltaX),
                    0
                )
            )
        } else if (event.modifierFlags.contains(.shift)) {
            renderer?.scrolled(
                delta: float3(
                    Float(event.scrollingDeltaX),
                    0,
                    Float(event.scrollingDeltaY)
                )
            )
        }
    }
}


