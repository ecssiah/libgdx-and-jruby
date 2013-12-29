require 'src/util/Initializer'

class TestGame < Game
  
  def create()
    setScreen(GameScreen.new)
  end
  
end

LwjglApplication.new(TestGame.new, "Test Game", 800, 600, true)