class GameScreen
  java_implements Screen
  
  def show()
    
    TextureSetup.new
    
    @manager = AssetManager.new
    @manager.setLoader(TiledMap.java_class, TmxMapLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/maps/level1.tmx", TiledMap.java_class)
    @manager.setLoader(TextureAtlas.java_class, TextureAtlasLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/gfx/graphics.pack", TextureAtlas.java_class)
    @manager.finishLoading
    
    @atlas = @manager.get("assets/gfx/graphics.pack")
    @map = @manager.get("assets/maps/level1.tmx")
    
    @cam = OrthographicCamera.new(Gdx.graphics.getWidth * C::WTB, Gdx.graphics.getHeight * C::WTB)
    @cam.setToOrtho(false, 40, 30)
    @cam.position.set(Vector3.new(32, 26, 0))
    @cam.update
    
    @renderer = OrthogonalTiledMapRenderer.new(@map, 1 / 16.0)
    @renderer.getSpriteBatch.setProjectionMatrix(@cam.combined)
    @renderer.setView(@cam)
    
  end
  

  def render(delta)
    
    Gdx.gl.glClearColor(0, 0, 0, 1)
    Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

    @renderer.setView(@cam)
    
    @renderer.render
    
  end
  
  
  def resize(width, height)
    
  end
  
  def pause()
    
  end
  
  def resume()
    
  end
  
  def hide()
    
  end
  
  def dispose()
    
  end
  
end
