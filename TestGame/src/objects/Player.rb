class Player
  
  attr_accessor :pos, :vel, :body, :contacts
   
  MAX_VELX, MAX_VELY = 20, 30
  
  def initialize(atlas)
    
    @atlas = atlas
    @contacts = 0
    @stateTime = 0
    @damping = 0.82
    @facing = :front
    @force = :none
    
    @width = C::WTB * @atlas.findRegion("security1/idleUp1").getRegionWidth
    @height = C::WTB * @atlas.findRegion("security1/idleUp1").getRegionHeight
    
    @idleFront = Animation.new(0, @atlas.findRegion("security1/idleDown1"))
    @idleBack = Animation.new(0, @atlas.findRegion("security1/idleUp1"))
    @idleLeft = Animation.new(0, @atlas.findRegion("security1/idleLeft1"))
    @idleRight = Animation.new(0, @atlas.findRegion("security1/idleRight1"))
    @jumpLeft = Animation.new(0, @atlas.findRegion("security1/walkLeft3"))
    @jumpRight = Animation.new(0, @atlas.findRegion("security1/walkRight3"))
    @jumpFront = Animation.new(0, @atlas.findRegion("security1/idleDown1"))
    @jumpBack = Animation.new(0, @atlas.findRegion("security1/idleUp1"))
      
    frames = Java::ComBadlogicGdxUtils::Array.new
    
    for i in 1..8
      frames.add(@atlas.findRegion("security1/walkLeft#{i}"))
    end
    
    @walkLeft = Animation.new(0.0874, frames)
    
    frames = Java::ComBadlogicGdxUtils::Array.new
        
    for i in 1..8
      frames.add(@atlas.findRegion("security1/walkRight#{i}"))
    end
    
    @walkRight = Animation.new(0.0874, frames)

    @frame = @idleFront.getKeyFrame(@stateTime, true)
    
  end
  
  
  def update(delta)
    
    linVel = updateVelocity(delta)
    
    @pos.x = @body.position.x
    @pos.y = @body.position.y
    
    #Set Animation Frame
    if @contacts == 0
             
      if @facing == :left
        @frame = @jumpLeft.getKeyFrame(@stateTime, true)
      elsif @facing == :right
        @frame = @jumpRight.getKeyFrame(@stateTime, true)
      end
      
    elsif linVel.x == 0 && linVel.y.abs < 0.001

      if @facing == :left
        @frame = @idleLeft.getKeyFrame(@stateTime, true)
      elsif @facing == :right
        @frame = @idleRight.getKeyFrame(@stateTime, true)
      elsif @facing == :front
        @frame = @idleFront.getKeyFrame(@stateTime, true)
      elsif @facing == :back
        @frame = @idleBack.getKeyFrame(@stateTime, true)
      end  
      
    elsif linVel.x > 0
      
      @frame = @walkRight.getKeyFrame(@stateTime, true)
    
    elsif linVel.x < 0
      
      @frame = @walkLeft.getKeyFrame(@stateTime, true)
    
    end
    
  end
  
  
  def updateVelocity(delta)
    
    @stateTime += delta
    
    if @force == :left
      @body.applyLinearImpulse(-2.8, 0, @pos.x, @pos.y, true)
    elsif @force == :right
      @body.applyLinearImpulse(2.8, 0, @pos.x, @pos.y, true)
    end
    
    linVel = @body.getLinearVelocity
    
    if linVel.x.abs < 0.3
      linVel.set(0, linVel.y)
    else
      linVel.set(linVel.x * @damping, linVel.y)
    end
    
    if linVel.x.abs > MAX_VELX
      linVel.set((linVel.x <=> 0) * MAX_VELX, linVel.y)
    end
    
    if linVel.y.abs > MAX_VELY
      linVel.set(linVel.x, (linVel.y <=> 0) * MAX_VELY)
    end
    
    @body.setLinearVelocity(linVel)
    
    return linVel
    
  end
  
  
  def draw(batch)
    
    batch.draw(@frame, @pos.x - @width / 2, @pos.y - @height / 2, @width, @height)
    
  end
  
  
  def setupBody(world, category, mask)
        
    bodyDef = BodyDef.new
    bodyDef.type = BodyType::DynamicBody
    bodyDef.position.set(@pos.x, @pos.y)
    
    @body = world.createBody(bodyDef)
    @body.setUserData(self)
     
    topShape = CircleShape.new
    topShape.setRadius(1.17)
    topShape.setPosition(Vector2.new(0, 2.91))
  
    midShape = PolygonShape.new
    midShape.setAsBox(0.9, 2.64, Vector2.new(0, 0.2), 0)
    
    botShape = CircleShape.new
    botShape.setRadius(1.54)
    botShape.setPosition(Vector2.new(0, -2.37))
      
    sensorShape = PolygonShape.new
    sensorShape.setAsBox(0.4, 1.0, Vector2.new(0, -3.72), 0)
    
    topFixture = FixtureDef.new
    topFixture.shape = topShape
    topFixture.friction = 0.0
    topFixture.filter.categoryBits = category
    topFixture.filter.maskBits = mask
    
    midFixture = FixtureDef.new
    midFixture.shape = midShape
    midFixture.friction = 0.0
    midFixture.filter.categoryBits = category
    midFixture.filter.maskBits = mask
        
    botFixture = FixtureDef.new
    botFixture.shape = botShape
    botFixture.friction = 0.0
    botFixture.filter.categoryBits = category
    botFixture.filter.maskBits = mask
    
    sensorFixture = FixtureDef.new
    sensorFixture.shape = sensorShape
    sensorFixture.friction = 0.0
    sensorFixture.isSensor = true
    sensorFixture.filter.categoryBits = category
    sensorFixture.filter.maskBits = mask
    
    @body.createFixture(topFixture)
    @body.createFixture(midFixture)
    @body.createFixture(botFixture)
    @body.createFixture(sensorFixture).setUserData(0)
    
    topShape.dispose
    midShape.dispose
    botShape.dispose
    sensorShape.dispose
    
  end
  
  
  def keyDown(keycode)

    Gdx.app.exit if keycode == Keys::ESCAPE
          
    if @contacts > 0
    
      case keycode
          
        when Keys::W, Keys::UP
          
          @facing = :back
          
        when Keys::S, Keys::DOWN
          
          @facing = :front
          
        when Keys::A, Keys::LEFT
          
          @facing = :left
          @force = :left
          
        when Keys::D, Keys::RIGHT
          
          @facing = :right
          @force = :right
          
        when Keys::SPACE
          
          @body.applyLinearImpulse(0, 20, @pos.x, @pos.y, true)
      
      end
    
    end
  
  end
  
    
  def keyUp(keycode)
        
    case keycode
    
      when Keys::A, Keys::LEFT
        
        @force = :none
        
      when Keys::D, Keys::RIGHT
        
        @force = :none
    
    end
    
  end

end
