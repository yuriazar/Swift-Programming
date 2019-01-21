//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by Yuri Azar on 1/19/19.
//  Copyright © 2019 Yuri Azar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    let birdTexture = SKTexture(imageNamed: "flappy1.png")
    var score = 0
    var timer = Timer()
    
    enum Collider : UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    @objc func makePipes() {
        let movePipes = SKAction.move(by: CGVector(dx: -2*self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        let upperPipeTexture = SKTexture(imageNamed: "pipe1.png")
        let upperPipe = SKSpriteNode(texture: upperPipeTexture)
        
        upperPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + upperPipeTexture.size().height / 2 + gapHeight/2 + pipeOffset)
        upperPipe.run(moveAndRemovePipes)
        
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipeTexture.size())
        upperPipe.physicsBody!.isDynamic = false
        
        upperPipe.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        upperPipe.physicsBody!.categoryBitMask = Collider.Object.rawValue
        upperPipe.physicsBody!.collisionBitMask = Collider.Object.rawValue
        
        self.addChild(upperPipe)
        
        let lowerPipeTexture = SKTexture(imageNamed: "pipe2.png")
        let lowerPipe = SKSpriteNode(texture: lowerPipeTexture)
        
        lowerPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - upperPipeTexture.size().height / 2 - gapHeight/2 + pipeOffset)
        lowerPipe.run(moveAndRemovePipes)
        
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipeTexture.size())
        lowerPipe.physicsBody!.isDynamic = false
        
        lowerPipe.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        lowerPipe.physicsBody!.categoryBitMask = Collider.Object.rawValue
        lowerPipe.physicsBody!.collisionBitMask = Collider.Object.rawValue
        
        self.addChild(lowerPipe)
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperPipeTexture.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        
        gap.run(moveAndRemovePipes)
        
        gap.physicsBody!.contactTestBitMask = Collider.Bird.rawValue
        gap.physicsBody!.categoryBitMask = Collider.Gap.rawValue
        gap.physicsBody!.collisionBitMask = Collider.Gap.rawValue
        
        self.addChild(gap)
        
    }

    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        setupGame()
        
    }
    
    func setupGame() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        let bgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 10)
        let shiftBg = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        
        let moveBackground = SKAction.repeatForever(SKAction.sequence([bgAnimation, shiftBg]))
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        
        var i : CGFloat = 0
        
        while i < 3 {
            bg = SKSpriteNode(texture: bgTexture)
            
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            
            bg.run(moveBackground)
            
            bg.zPosition = -1
            
            self.addChild(bg)
            
            i+=1
            
            
        }
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        bird.physicsBody!.categoryBitMask = Collider.Bird.rawValue
        bird.physicsBody!.collisionBitMask = Collider.Bird.rawValue
        
        self.addChild(bird)
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        ground.physicsBody!.categoryBitMask = Collider.Object.rawValue
        ground.physicsBody!.collisionBitMask = Collider.Object.rawValue
        
        self.addChild(ground)
        
        let sky = SKNode()
        sky.position = CGPoint(x: self.frame.midX, y: self.frame.height/2-44)
        
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        sky.physicsBody!.isDynamic = false
        
        self.addChild(sky)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = String(score)
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70 - 44)
        
        self.addChild(scoreLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == Collider.Gap.rawValue || contact.bodyB.categoryBitMask == Collider.Gap.rawValue {
            
            score += 1
            scoreLabel.text = String(score)
            
        } else {
        
            let gameOverLabel = SKLabelNode()
            self.speed = 0
            gameOver = true
            timer.invalidate()
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over. Tap to play again"
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            self.addChild(gameOverLabel)
        }
    }
}
