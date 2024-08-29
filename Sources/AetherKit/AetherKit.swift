//
//
// Copyright 2024 by Samuel Campos de Andrade 
// THE-PI
// Donation PIX: 06253847333
import UIKit
import CoreGraphics
import SwiftUI

public class AetherParticle {
    public var position: CGPoint
    public var velocity: CGPoint
    public var lifetime: CGFloat
    public var color: UIColor
    public var size: CGFloat
    public var rotation: CGFloat
    public var angularVelocity: CGFloat
    public var animationType: AnimationType = .none
    public var animationProgress: CGFloat = 0
    
    public enum AnimationType: CaseIterable {
        case none, bounce, fade, rotate, scale, wobble, pulse, sway, shrink, grow, jiggle, wave, spin, drift, zoom, flicker, flash, bounceX, bounceY, float, expand, contract, shimmer, bob
    }
    
    public init(position: CGPoint, velocity: CGPoint, lifetime: CGFloat, color: UIColor = .white, size: CGFloat = 5, rotation: CGFloat = 0, angularVelocity: CGFloat = 0) {
        self.position = position
        self.velocity = velocity
        self.lifetime = lifetime
        self.color = color
        self.size = size
        self.rotation = rotation
        self.angularVelocity = angularVelocity
    }
    
    public func update(deltaTime: CGFloat) {
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
        lifetime -= deltaTime
        rotation += angularVelocity * deltaTime
        applyAnimation(deltaTime: deltaTime)
    }
    
    private func applyAnimation(deltaTime: CGFloat) {
        switch animationType {
        case .bounce:
            position.y += sin(animationProgress) * 10
        case .fade:
            color = color.withAlphaComponent(max(0, 1 - animationProgress / 10))
        case .rotate:
            rotation += deltaTime * 2 * .pi
        case .scale:
            size = 5 + sin(animationProgress) * 5
        case .wobble:
            position.x += sin(animationProgress) * 5
        case .pulse:
            size = 5 + sin(animationProgress) * 3
        case .sway:
            position.y += sin(animationProgress) * 5
        case .shrink:
            size = max(1, size - deltaTime * 2)
        case .grow:
            size += deltaTime * 2
        case .jiggle:
            position.x += sin(animationProgress) * 3
            position.y += cos(animationProgress) * 3
        case .wave:
            position.y += sin(animationProgress) * 5
        case .spin:
            rotation += deltaTime * 5
        case .drift:
            position.x += sin(animationProgress) * 2
            position.y += cos(animationProgress) * 2
        case .zoom:
            size = max(1, size + deltaTime * 5)
        case .flicker:
            color = color.withAlphaComponent(0.5 + 0.5 * sin(animationProgress))
        case .flash:
            color = color.withAlphaComponent(abs(sin(animationProgress)) * 0.8)
        case .bounceX:
            position.x += sin(animationProgress) * 10
        case .bounceY:
            position.y += sin(animationProgress) * 10
        case .float:
            position.y += sin(animationProgress) * 2
        case .expand:
            size = max(1, size + sin(animationProgress) * 5)
        case .contract:
            size = max(1, size - sin(animationProgress) * 5)
        case .shimmer:
            color = color.withAlphaComponent(0.5 + 0.5 * abs(sin(animationProgress)))
        case .bob:
            position.y += sin(animationProgress) * 4
        case .none:
            break
        }
        animationProgress += deltaTime
    }
    
    public func isAlive() -> Bool {
        return lifetime > 0
    }
}

public class AetherParticleEmitter {
    public var position: CGPoint
    public var particles: [AetherParticle] = []
    public var emissionRate: Int
    public var particleLifetime: CGFloat
    public var velocityRange: CGFloat
    public var particleColor: UIColor
    public var particleSize: CGFloat
    public var angularVelocityRange: CGFloat
    public var rotation: CGFloat
    
    public init(position: CGPoint, emissionRate: Int, particleLifetime: CGFloat, velocityRange: CGFloat, particleColor: UIColor = .white, particleSize: CGFloat = 5, angularVelocityRange: CGFloat = 0, rotation: CGFloat = 0) {
        self.position = position
        self.emissionRate = emissionRate
        self.particleLifetime = particleLifetime
        self.velocityRange = velocityRange
        self.particleColor = particleColor
        self.particleSize = particleSize
        self.angularVelocityRange = angularVelocityRange
        self.rotation = rotation
    }
    
    public func emitParticles() {
        for _ in 0..<emissionRate {
            let velocity = CGPoint(x: CGFloat.random(in: -velocityRange...velocityRange), y: CGFloat.random(in: -velocityRange...velocityRange))
            let angularVelocity = CGFloat.random(in: -angularVelocityRange...angularVelocityRange)
            let particle = AetherParticle(position: position, velocity: velocity, lifetime: particleLifetime, color: particleColor, size: particleSize, rotation: rotation, angularVelocity: angularVelocity)
            particle.animationType = AetherParticle.AnimationType.allCases.randomElement() ?? .none
            particles.append(particle)
        }
    }
    
    public func update(deltaTime: CGFloat) {
        emitParticles()
        particles.removeAll { !$0.isAlive() }
        for particle in particles {
            particle.update(deltaTime: deltaTime)
        }
    }
    
    public func render(in context: CGContext) {
        for particle in particles {
            context.saveGState()
            context.translateBy(x: particle.position.x + particle.size / 2, y: particle.position.y + particle.size / 2)
            context.rotate(by: particle.rotation)
            context.translateBy(x: -particle.size / 2, y: -particle.size / 2)
            context.setFillColor(particle.color.cgColor)
            context.addEllipse(in: CGRect(x: 0, y: 0, width: particle.size, height: particle.size))
            context.fillPath()
            context.restoreGState()
        }
    }
}
public enum AnimationType: CaseIterable {
    case none, bounce, fade, rotate, scale, wobble, pulse, sway, shrink, grow, jiggle, wave, spin, drift, zoom, flicker, flash, bounceX, bounceY, float, expand, contract, shimmer, bob
}

public class AetherRigidBody {
    public var position: CGPoint
    public var velocity: CGPoint
    public var mass: CGFloat
    public var friction: CGFloat
    public var acceleration: CGPoint
    public var forces: [CGPoint] = []
    
    public init(position: CGPoint, velocity: CGPoint, mass: CGFloat, friction: CGFloat, acceleration: CGPoint = .zero) {
        self.position = position
        self.velocity = velocity
        self.mass = mass
        self.friction = friction
        self.acceleration = acceleration
    }
    
    public func applyForce(_ force: CGPoint) {
        forces.append(force)
    }
    
    public func update(deltaTime: CGFloat) {
        var totalForce = CGPoint.zero
        for force in forces {
            totalForce.x += force.x
            totalForce.y += force.y
        }
        forces.removeAll()
        
        let acceleration = CGPoint(x: totalForce.x / mass, y: totalForce.y / mass)
        velocity.x += acceleration.x * deltaTime
        velocity.y += acceleration.y * deltaTime
        velocity.x *= (1 - friction)
        velocity.y *= (1 - friction)
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
    }
    
    public func render(in context: CGContext) {
        context.setFillColor(UIColor.blue.cgColor)
        context.addRect(CGRect(x: position.x, y: position.y, width: 20, height: 20))
        context.fillPath()
    }
}



public class AetherSpring {
    public var start: CGPoint
    public var end: CGPoint
    public var stiffness: CGFloat
    public var damping: CGFloat
    
    public init(start: CGPoint, end: CGPoint, stiffness: CGFloat, damping: CGFloat) {
        self.start = start
        self.end = end
        self.stiffness = stiffness
        self.damping = damping
    }
    
    public func applySpringForces(to particle: AetherParticle) {
        let dx = end.x - particle.position.x
        let dy = end.y - particle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        let forceMagnitude = stiffness * (distance - 0) - damping * (particle.velocity.x * dx + particle.velocity.y * dy) / distance
        let force = CGPoint(x: forceMagnitude * dx / distance, y: forceMagnitude * dy / distance)
        particle.velocity.x += force.x
        particle.velocity.y += force.y
    }
}



public extension AetherParticleEmitter {
    func setParticleColor(_ color: UIColor) {
        self.particleColor = color
    }
    
    func setParticleSize(_ size: CGFloat) {
        self.particleSize = size
    }
    
    func setEmissionRate(_ rate: Int) {
        self.emissionRate = rate
    }
    
    func setVelocityRange(_ range: CGFloat) {
        self.velocityRange = range
    }
    
    func setLifetime(_ lifetime: CGFloat) {
        self.particleLifetime = lifetime
    }
    
    func setRotation(_ rotation: CGFloat) {
        self.rotation = rotation
    }
    
    func setAngularVelocityRange(_ range: CGFloat) {
        self.angularVelocityRange = range
    }
}



public extension AetherRigidBody {
    func setFriction(_ friction: CGFloat) {
        self.friction = friction
    }
    
    func setMass(_ mass: CGFloat) {
        self.mass = mass
    }
    
    func setPosition(_ position: CGPoint) {
        self.position = position
    }
    
    func setVelocity(_ velocity: CGPoint) {
        self.velocity = velocity
    }
    
    func applyExternalForce(_ force: CGPoint) {
        self.applyForce(force)
    }
}
class AetherEmitterView: UIView {
    private var emitter: AetherParticleEmitter
    private var rigidBody: AetherRigidBody
    private var lastUpdateTime: TimeInterval = 0
    
    init(frame: CGRect, emitter: AetherParticleEmitter, rigidBody: AetherRigidBody) {
        self.emitter = emitter
        self.rigidBody = rigidBody
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc private func update(_ displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = CGFloat(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        emitter.update(deltaTime: deltaTime)
        rigidBody.update(deltaTime: deltaTime)
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        emitter.render(in: context!)
        rigidBody.render(in: context!)
    }
    
    func updateEmitter(_ emitter: AetherParticleEmitter) {
        self.emitter = emitter
        self.setNeedsDisplay()
    }
    
    func updateRigidBody(_ rigidBody: AetherRigidBody) {
        self.rigidBody = rigidBody
        self.setNeedsDisplay()
    }
}
public struct AetherParticleUIView: UIViewRepresentable {
    @ObservedObject var viewModel: AetherViewModel
    
   public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let emitterView = AetherEmitterView(frame: UIScreen.main.bounds, emitter: viewModel.emitter, rigidBody: viewModel.rigidBody)
        view.addSubview(emitterView)
        context.coordinator.emitterView = emitterView
        return view
    }
    
   public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateEmitter(viewModel.emitter)
        context.coordinator.updateRigidBody(viewModel.rigidBody)
    }
    
   public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
   public class Coordinator: NSObject {
        var emitterView: AetherEmitterView?
        
       public func updateEmitter(_ emitter: AetherParticleEmitter) {
            emitterView?.updateEmitter(emitter)
        }
        
        public func updateRigidBody(_ rigidBody: AetherRigidBody) {
            emitterView?.updateRigidBody(rigidBody)
        }
    }
}
public class AetherViewModel: ObservableObject {
    @Published var emitter: AetherParticleEmitter
    @Published var rigidBody: AetherRigidBody
    
  public  init(emitter: AetherParticleEmitter, rigidBody: AetherRigidBody) {
        self.emitter = emitter
        self.rigidBody = rigidBody
    }
}
