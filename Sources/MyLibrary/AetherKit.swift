import UIKit
import CoreGraphics

public class AetherParticle {
    public var position: CGPoint
    public var velocity: CGPoint
    public var lifetime: CGFloat
    public var color: UIColor
    public var size: CGFloat
    public var rotation: CGFloat
    public var angularVelocity: CGFloat

    public init(position: CGPoint, velocity: CGPoint, lifetime: CGFloat, color: UIColor = .white, size: CGFloat = 5, rotation: CGFloat = 0, angularVelocity: CGFloat = 0) {
        self.position = position
        self.velocity = velocity
        self.lifetime = lifetime
        self.color = color
        self.size = size
        self.rotation = rotation
        self.angularVelocity = angularVelocity
    }

    public func aetherUpdate(deltaTime: CGFloat) {
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
        lifetime -= deltaTime
        rotation += angularVelocity * deltaTime
    }

    public func aetherIsAlive() -> Bool {
        return lifetime > 0
    }

    public func aetherChangeColor(to color: UIColor) {
        self.color = color
    }

    public func aetherChangeSize(to size: CGFloat) {
        self.size = size
    }

    public func aetherChangeRotation(by rotation: CGFloat) {
        self.rotation += rotation
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
    public var gravity: CGPoint
    public var wind: CGPoint

    public init(position: CGPoint, emissionRate: Int, particleLifetime: CGFloat, velocityRange: CGFloat, particleColor: UIColor = .white, particleSize: CGFloat = 5, angularVelocityRange: CGFloat = 0, rotation: CGFloat = 0, gravity: CGPoint = CGPoint(x: 0, y: 0), wind: CGPoint = CGPoint(x: 0, y: 0)) {
        self.position = position
        self.emissionRate = emissionRate
        self.particleLifetime = particleLifetime
        self.velocityRange = velocityRange
        self.particleColor = particleColor
        self.particleSize = particleSize
        self.angularVelocityRange = angularVelocityRange
        self.rotation = rotation
        self.gravity = gravity
        self.wind = wind
    }

    public func aetherEmitParticles() {
        for _ in 0..<emissionRate {
            let velocity = CGPoint(x: CGFloat.random(in: -velocityRange...velocityRange), y: CGFloat.random(in: -velocityRange...velocityRange))
            let angularVelocity = CGFloat.random(in: -angularVelocityRange...angularVelocityRange)
            let particle = AetherParticle(position: position, velocity: velocity, lifetime: particleLifetime, color: particleColor, size: particleSize, rotation: rotation, angularVelocity: angularVelocity)
            particles.append(particle)
        }
    }

    public func aetherUpdate(deltaTime: CGFloat) {
        aetherEmitParticles()
        particles.removeAll { !$0.aetherIsAlive() }
        for particle in particles {
            particle.aetherUpdate(deltaTime: deltaTime)
            particle.velocity.x += gravity.x * deltaTime
            particle.velocity.y += gravity.y * deltaTime
            particle.velocity.x += wind.x * deltaTime
            particle.velocity.y += wind.y * deltaTime
        }
    }

    public func aetherRender(in context: CGContext) {
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

    public func aetherChangeGravity(to gravity: CGPoint) {
        self.gravity = gravity
    }

    public func aetherChangeWind(to wind: CGPoint) {
        self.wind = wind
    }

    public func aetherSetParticleColor(_ color: UIColor) {
        self.particleColor = color
    }

    public func aetherSetParticleSize(_ size: CGFloat) {
        self.particleSize = size
    }

    public func aetherSetEmissionRate(_ rate: Int) {
        self.emissionRate = rate
    }

    public func aetherSetVelocityRange(_ range: CGFloat) {
        self.velocityRange = range
    }

    public func aetherSetLifetime(_ lifetime: CGFloat) {
        self.particleLifetime = lifetime
    }
}

public class AetherRigidBody {
    public var position: CGPoint
    public var velocity: CGPoint
    public var mass: CGFloat
    public var friction: CGFloat
    public var acceleration: CGPoint
    public var forces: [CGPoint] = []
    public var dragCoefficient: CGFloat

    public init(position: CGPoint, velocity: CGPoint, mass: CGFloat, friction: CGFloat, dragCoefficient: CGFloat = 0.1, acceleration: CGPoint = .zero) {
        self.position = position
        self.velocity = velocity
        self.mass = mass
        self.friction = friction
        self.dragCoefficient = dragCoefficient
        self.acceleration = acceleration
    }

    public func aetherApplyForce(_ force: CGPoint) {
        forces.append(force)
    }

    public func aetherUpdate(deltaTime: CGFloat) {
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
        velocity.x -= dragCoefficient * velocity.x * deltaTime
        velocity.y -= dragCoefficient * velocity.y * deltaTime
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
    }

    public func aetherRender(in context: CGContext) {
        context.setFillColor(UIColor.blue.cgColor)
        context.addRect(CGRect(x: position.x, y: position.y, width: 20, height: 20))
        context.fillPath()
    }

    public func aetherSetFriction(_ friction: CGFloat) {
        self.friction = friction
    }

    public func aetherSetMass(_ mass: CGFloat) {
        self.mass = mass
    }

    public func aetherSetPosition(_ position: CGPoint) {
        self.position = position
    }

    public func aetherSetVelocity(_ velocity: CGPoint) {
        self.velocity = velocity
    }

    public func aetherSetDragCoefficient(_ coefficient: CGFloat) {
        self.dragCoefficient = coefficient
    }
}

public class AetherSpring {
    public var start: CGPoint
    public var end: CGPoint
    public var stiffness: CGFloat
    public var damping: CGFloat
    public var restLength: CGFloat

    public init(start: CGPoint, end: CGPoint, stiffness: CGFloat, damping: CGFloat, restLength: CGFloat) {
        self.start = start
        self.end = end
        self.stiffness = stiffness
        self.damping = damping
        self.restLength = restLength
    }

    public func aetherApplySpringForces(particle: AetherParticle) {
        let dx = end.x - particle.position.x
        let dy = end.y - particle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        let forceMagnitude = stiffness * (distance - restLength) - damping * (particle.velocity.x * dx + particle.velocity.y * dy) / distance
        let force = CGPoint(x: forceMagnitude * dx / distance, y: forceMagnitude * dy / distance)
        particle.velocity.x += force.x
        particle.velocity.y += force.y
    }
}

public extension AetherParticleEmitter {
    func aetherChangeGravity(to gravity: CGPoint) {
        self.gravity = gravity
    }

    func aetherChangeWind(to wind: CGPoint) {
        self.wind = wind
    }

    func aetherSetAngularVelocityRange(_ range: CGFloat) {
        self.angularVelocityRange = range
    }

    func aetherSetRotation(_ rotation: CGFloat) {
        self.rotation = rotation
    }
}

public extension AetherRigidBody {
    func aetherSetDragCoefficient(_ coefficient: CGFloat) {
        self.dragCoefficient = coefficient
    }

    func aetherApplyExternalForce(_ force: CGPoint) {
        self.aetherApplyForce(force)
    }
}

public class AetherParticleSystem {
    public var emitters: [AetherParticleEmitter] = []

    public init() {}

    public func aetherAddEmitter(_ emitter: AetherParticleEmitter) {
        emitters.append(emitter)
    }

    public func aetherUpdateAll(deltaTime: CGFloat) {
        for emitter in emitters {
            emitter.aetherUpdate(deltaTime: deltaTime)
        }
    }

    public func aetherRenderAll(in context: CGContext) {
        for emitter in emitters {
            emitter.aetherRender(in: context)
        }
    }
}
