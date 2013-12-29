class PlayerContactListener 
  java_implements ContactListener
  
  def initialize(player)
    @player = player
  end
  
  
  def beginContact(contact)
    
    a = contact.getFixtureA.getBody.getUserData
    b = contact.getFixtureB.getBody.getUserData
    
    if a.instance_of?(Player) 
      
      if contact.getFixtureA.getUserData == 0 && b.instance_of?(StaticTiledMapTile)
        @player.contacts += 1
      end   
    
    end
    
    if b.instance_of?(Player)
      
      if contact.getFixtureB.getUserData == 0 && a.instance_of?(StaticTiledMapTile)
        @player.contacts += 1
      end      
    
    end
    
  end


  def endContact(contact)
    
    a = contact.getFixtureA.getBody.getUserData
    b = contact.getFixtureB.getBody.getUserData
    
    if a.instance_of?(Player)
      
      if contact.getFixtureA.getUserData == 0 && b.instance_of?(StaticTiledMapTile)
        @player.contacts -= 1
      end
      
    end
    
    if b.instance_of?(Player)
          
      if contact.getFixtureB.getUserData == 0 && a.instance_of?(StaticTiledMapTile)
        @player.contacts -= 1
      end
      
    end
    
  end


  def preSolve(contact, oldManifold)
    
  end
  
  
  def postSolve(contact, impulse)
  
  end
  
end
