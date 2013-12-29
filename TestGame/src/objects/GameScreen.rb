class GameScreen
  java_implements Screen
  
  def show()
    
    #TextureSetup.new
    
    @manager = AssetManager.new
    @manager.setLoader(TiledMap.java_class, TmxMapLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/maps/level1.tmx", TiledMap.java_class)
    @manager.setLoader(TextureAtlas.java_class, TextureAtlasLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/gfx/graphics.pack", TextureAtlas.java_class)
    @manager.finishLoading
    
    @atlas = @manager.get("assets/gfx/graphics.pack")
    @map = @manager.get("assets/maps/level1.tmx")
    @numLayers = @map.getLayers.getCount
    
    @camOffset = 10
    @cam = OrthographicCamera.new(Gdx.graphics.getWidth * C::WTB, Gdx.graphics.getHeight * C::WTB)
    
    @renderer = OrthogonalTiledMapRenderer.new(@map, C::WTB)
    @renderer.getSpriteBatch.setProjectionMatrix(@cam.combined)
    @renderer.setView(@cam)
    @batch = @renderer.getSpriteBatch
    @debugRenderer = Box2DDebugRenderer.new
    
    @world = World.new(Vector2.new(0, C::GRAVITY), true)
    
    @player = Player.new(@atlas)
    @player.pos = Vector2.new(26, 15)
    @player.setupBody(@world, C::PLAYER, C::TILE)
    
    @contactListener = PlayerContactListener.new(@player)
    @playerListener = PlayerListener.new(@player)
    @world.setContactListener(@contactListener)
    
    setupTileBodies("mid", C::TILE, C::PLAYER)
    
    Gdx.input.setInputProcessor(@playerListener)
    
  end
  
  
  def update(delta)
    
    @world.step(C::BOX_STEP, C::BOX_VELOCITY_ITERATIONS, C::BOX_POSITION_ITERATIONS)
    
    @cam.position.x = @player.pos.x
    @cam.position.y = @player.pos.y + @camOffset
    @cam.update
    
    @player.update(delta)
    
  end
  

  def render(delta)
    
    update(delta)
    
    Gdx.gl.glClearColor(0, 0, 0, 1)
    Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

    @renderer.setView(@cam)
    
    renderLayers
    
    #@debugRenderer.render(@world, @cam.combined)
    
  end
  
  
  def renderLayers
    
    for i in 0...@numLayers
      
      tint = Math.exp(-0.22 * (@numLayers - i))
      @batch.setColor(tint, tint, tint, 1)
      
      @batch.begin
      
        @renderer.renderTileLayer(@map.getLayers.get(i))
        
        if @map.getLayers.get(i).name == "mid"
          @player.draw(@batch)
        end
      
      @batch.end
      
    end
    
  end
  
  
  def setupTileBodies(layerName, category, mask)
    
    tileLayer = @map.getLayers.get(layerName)
      
    for col in 0..tileLayer.getWidth
      
      for row in 0..tileLayer.getHeight
        
        next if tileLayer.getCell(col, row).nil?
          
        if tileLayer.getCell(col, row).getTile.getProperties.get("solid")
          
          bodyDef = BodyDef.new
          bodyDef.position.set(Vector2.new(col + 0.5, row + 0.5))
            
          body = @world.createBody(bodyDef)
          
          body.setUserData(tileLayer.getCell(col, row).getTile)
          
          box = PolygonShape.new
          box.setAsBox(0.5, 0.5)
          
          fixtureDef = FixtureDef.new
          fixtureDef.shape = box
          fixtureDef.filter.categoryBits = category
          fixtureDef.filter.maskBits = mask
          
          body.createFixture(fixtureDef)
          
          box.dispose
          
        end
        
      end
    
    end
    
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