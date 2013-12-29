class PlayerListener
  java_implements InputListener
  
  def initialize(player)
    @player = player
  end

  def keyDown(keycode)
    
    @player.keyDown(keycode)
    return true
    
  end
  
    
  def keyUp(keycode)
    
    @player.keyUp(keycode)
    return true
    
  end
  
  def keyTyped(char)
    return false
  end
  
  
  def mouseMoved(x, y)
    return false
  end
  
  
  def scrolled(amount)
    return false
  end
  
  
  def touchDown(x, y, pointer, button)
  
    puts x, y
    return true
    
  end

  
  def touchDragged(x, y, pointer)
    return false
  end
  
  
  def touchUp(x, y, pointer, button)
    return false
  end
  
end