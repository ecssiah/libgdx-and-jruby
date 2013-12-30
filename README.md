LibGDX and Ruby 
===============
Platformer Tutorial
-------------------

This is a general reference for using Ruby with libgdx. It does not explain libgdx in great detail, but it is a fairly thorough introduction to JRuby. It is also a tutorial for creating a basic working platformer using the builtin box2d support. It includes some assets that are free to use in any way you want. The full project is in this repository in the TestGame directory. If you're on Linux, you should be able to import it directly into Eclipse and run it as a reference for following the tutorial. If you're on Windows, then swap your jars into '/libs'.

What you need:
* Eclipse
* [DLTK plugin](http://www.eclipse.org/dltk/)
* [JRuby](https://github.com/jruby/jruby/wiki/GettingStarted)
* Assets from this repository
* [libgdx](http://libgdx.badlogicgames.com/nightlies/), and a decent understanding of it

Setup
-----

The Eclipse DLTK plugin does a decent job with Ruby. Add it through the marketplace. You'll be giving up some of the content-assist you had with Java (there is no shortcut to automatically add the right imports or quickfix), but Ruby comes with advantages of its own. Also, with the DLTK you still get basic things like auto-complete on your own objects.

Since this is for the desktop, the project setup is very easy. Create a project directory like this.

    /TestGame/assets
    /TestGame/libs
    /TestGame/src

Put the main gdx files for your OS in '/libs'. I would also grab gdx-tools.jar out of '/extensions' in the libgdx archive so you can automatically pack your textures. On linux, mine looks like this.

    /libs/gdx.jar
    /libs/gdx-backend-lwjgl.jar
    /libs/gdx-backend-lwjgl-natives.jar
    /libs/gdx-natives.jar
    /libs/gdx-tools.jar

We need a simple Ruby script to test the setup. Add TestGame.rb to '/src'.

TestGame.rb:

    require 'src/util/Initializer'

    class TestGame < Game
  
      def create()
        #Game goes here
      end
  
    end

    LwjglApplication.new(TestGame.new, "Test Game", 800, 600, true)
    
That's pretty much it. The boolean argument after the screen size tells it to use OpenGL 2.0. This should display a black window if we add the Initializer.rb script to 'src/util'. This is just a convenience to avoid having imports clutter up all of your scripts. For now, this is all that is needed.

Initializer.rb:

    require 'java'
    
    Dir["libs/\*.jar"].each { |jar| require jar }
    
    java_import com.badlogic.gdx.Gdx
    java_import com.badlogic.gdx.Game
    java_import com.badlogic.gdx.graphics.GL20
    
The project should now run. The first line allows direct access to all of the builtin Java classes through JRuby. The second line is a way of requiring all of the jars out of the '/libs' folder in one swipe. Iterations in Ruby are done using the .each method of an object. JRuby allows you to call .each on native Java collections as well. If you want an index then Ruby has a simple for loop.

    for i in @min..@max
      #Do things with i while it runs from the value @min up to and including @max
    end

Adding A Camera and Tiled Map
-----------------------------

To get a Tiled map displayed on a basic game screen we first need to add one line to TestGame.rb.

    def create()
      setScreen(GameScreen.new)
    end

Now we need the GameScreen.rb class. I setup my '/src' directory like this.

    /src/logic
    /src/objects
    /src/util
    
With TestGame.rb sitting outside alone.

    /src/TestGame.rb
    
Put the GameScreen.rb script in '/objects'.

GameScreen.rb show:

    ...

    #TextureSetup.new
    
    @manager = AssetManager.new
    @manager.setLoader(TiledMap.java_class, TmxMapLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/maps/level1.tmx", TiledMap.java_class)
    @manager.setLoader(TextureAtlas.java_class, TextureAtlasLoader.new(InternalFileHandleResolver.new))
    @manager.load("assets/gfx/graphics.pack", TextureAtlas.java_class)
    @manager.finishLoading
    
    @atlas = @manager.get("assets/gfx/graphics.pack")
    @map = @manager.get("assets/maps/level1.tmx")
    
    ...

If you change or add any textures to the project you should uncomment the TextureSetup.new line and it will automatically pack all of your textures again, but it is a nuisance having it run every time.

    @manager.load("assets/maps/level1.tmx", TiledMap.java_class)
        
Notice when you want to refer to the underlying class while using Ruby you will need to use .java_class, because .class will now refer to the Ruby object which the Java method won't understand. Other than that, *all* of these parenthesis are optional. I use them when a method needs arguments and when defining a method, but both of these can be done away with.

    def onEvent(type, source)

is equivalent to

    def onEvent type, source
    
In Ruby, they say you should use on_event instead of onEvent, but I don't like all the extra underscores you end up typing and the java methods you'll be using are CamelCase so it just seems smoother to ignore this rule when working with JRuby.

GameScreen.rb show:

        ...

        @cam = OrthographicCamera.new(Gdx.graphics.getWidth * C::WTB, Gdx.graphics.getHeight * C::WTB)
        @cam.setToOrtho(false, 40, 30)
        @cam.position.set(Vector3.new(32, 26, 0))
        @cam.update
            
        @renderer = OrthogonalTiledMapRenderer.new(@map, C::WTB)
        @renderer.getSpriteBatch.setProjectionMatrix(@cam.combined)
        @renderer.setView(@cam)
                
      end
      
When you need to refer to an object within another namespace you use the :: operator to access it. C::WTB is the "World to Box" conversion factor that is used in Box2d to get the units right. This is also how you access a subclass or an enum when importing from java.

    java_import com.badlogic.gdx.Input::Keys

You can access a java class directly. I used this in the case of the libgdx Array class, because otherwise it will bark at you about trying to redefine the Array that is included from Java.

    frames = Java::ComBadLogicUtils::Array.new

You remove all the periods and use CamelCase to access the class directly without importing. I have no idea why they embraced the Camel here. If you needed to use it numerous times you could just create an alias for it to avoid the warning. I find I rarely need to rely on a Java collection though.

GameScreen.rb:

      ...
            
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

You need to declare the implemented methods from Screen. I think in Java it ignores them if they are missing. Also, notice that Ruby pretty much treats all numbers the same. No more f's all over the place or issues with whether or not you sent a float or an int to a method. If you need to convert something there are short little methods built in along with basic math functions.

    @float.to_i
    @integer.to_s
    
These will take a float to an integer and an integer to a string. There are more .to_ methods and other builtins like .abs and exponentiation.

    @float**3
    @float *= Math::PI
    @float <=> 0     #Works as a sign operator, returns 1, 0, -1 depending on the sign of @float

To make it run, the Initializer must be updated to include all of the new imports and require statements for the scripts that are now used by GameScreen.rb.

Initializer.rb:

    require 'java'
    
    Dir["libs/\*.jar"].each { |jar| require jar }
    
    java_import com.badlogic.gdx.backends.lwjgl.LwjglApplication
    
    java_import com.badlogic.gdx.Gdx
    java_import com.badlogic.gdx.Game
    java_import com.badlogic.gdx.Screen
    java_import com.badlogic.gdx.graphics.GL20
    java_import com.badlogic.gdx.graphics.OrthographicCamera
    java_import com.badlogic.gdx.graphics.g2d.TextureRegion
    java_import com.badlogic.gdx.graphics.g2d.TextureAtlas
    java_import com.badlogic.gdx.assets.AssetManager
    java_import com.badlogic.gdx.assets.loaders.TextureAtlasLoader
    java_import com.badlogic.gdx.assets.loaders.resolvers.InternalFileHandleResolver
    java_import com.badlogic.gdx.maps.tiled.TiledMap
    java_import com.badlogic.gdx.maps.tiled.TmxMapLoader
    java_import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer
    java_import com.badlogic.gdx.math.Vector3
    java_import com.badlogic.gdx.tools.imagepacker.TexturePacker2
    
    require 'src/objects/GameScreen'
    require 'src/util/C'
    require 'src/util/TextureSetup'
    
Lastly, add the two utility scripts for the game's constants and texture packing. I name my constants script C. I don't know if this is considered bad practice, but I like how simple it is. Ruby has a module object like Python which is just a block of code instead of the full class structure. This is where I put my constants that are used across many scripts in the game.

C.rb:

    module C

      BOX_STEP = 1/45.0
      BOX_VELOCITY_ITERATIONS = 8
      BOX_POSITION_ITERATIONS = 3
      BTW, WTB = 16.0, 1/16.0
    
    end
    
Any variable declared with a capital letter in Ruby is considered a constant and shouldn't be modified. Ruby allows for parallel assignment as in the last line. This is also how I declare something like an enum.

    Left, Right, Up, Down, Center = 0, 1, 2, 3, 4
    
This will work for many purposes where you would use an enum in Java like the state of an entity. Alternatively, you could use symbols.

    :left, :right, :up, :down, :center
    
You don't even need to declare symbols or instance variables ahead of time in Ruby. Just use them when you need them and the prefix will determine their scope.

TextureSetup.rb:

    class TextureSetup
      
      def initialize()
        
        TexturePacker2.process("assets/gfx", "assets/gfx", "graphics.pack")
        
      end
      
    end

The initialize method is similar to the Java constructor. It is a private hidden method that is called through the .new method of a Ruby class. Both .new and initialize() can be overriden separately so it is not identical to a Java constructor, but they get the same job done.

You should now have a simple rendered map and associated camera with libgdx and JRuby.

Collision With The Tile Map
---------------------------

Before we can put a box2d player on the screen we have to make parts of the map solid. First, update your Initializer script with all of the new imports so that is out of the way. You can get the full list out of the repository. I won't print it here. **Order can be important.** Make sure a class is available to be inherited or implemented when it is needed. That's already thought through in the repository Initializer for this project. Just copy it and look it through.

GameScreen.rb will now have to be updated as well. In the show method the manager setup remains the same, but the rest will change a bit.

GameScreen.rb show:

    ...
    
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
    
    ...
    
Add a reference to the number of map layers, because it doesn't change and it is used during rendering so there is no reason to keep looking it up. @camOffset is to raise the camera over the player's head. Erase the setToOrtho and position assignments. The camera will now be following the player. Finally, add a box2d debug renderer so we can see the world we create.

GameScreen.rb show:

    ...
    
    @world = World.new(Vector2.new(0, C::GRAVITY), true)
    
    @player = Player.new(@atlas)
    @player.pos = Vector2.new(26, 15)
    @player.setupBody(@world, C::PLAYER, C::TILE)
    
    @contactListener = PlayerContactListener.new(@player)
    @playerListener = PlayerListener.new(@player)
    @world.setContactListener(@contactListener)
    
    setupTileBodies("mid", C::TILE, C::PLAYER)
    
    Gdx.input.setInputProcessor(@playerListener)
    
    ...
    
Notice that the player's position is in world units and not pixels thanks to the box2d conversions. Many of these classes don't exist yet, but it lays the foundation for the box2d world and control of the player. Some constants need to be added to C.rb as well. C::PLAYER and C::TILE are hexadecimal constants that are used for collision filtering. And C::GRAVITY is...well, the gravity. Add all the new constants now from the repository copy of C.rb.

GameScreen.rb update:

    @world.step(C::BOX_STEP, C::BOX_VELOCITY_ITERATIONS, C::BOX_POSITION_ITERATIONS)
    
    @cam.position.x = @player.pos.x
    @cam.position.y = @player.pos.y + @camOffset
    @cam.update
    
    @player.update(delta)
    
Step the box2d world using the predefined constants and have the camera follow the player.

GameScreen.rb render:

    update(delta)
    
    Gdx.gl.glClearColor(0, 0, 0, 1)
    Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

    @renderer.setView(@cam)
    
    renderLayers
    
    #@debugRenderer.render(@world, @cam.combined)
    
The render method needs to be changed slightly. We will now move the rendering into its own method. Don't forget the call to render the debugRenderer.

GameScreen.rb renderLayers:

    for i in 0...@numLayers
      
      tint = Math.exp(-0.22 * (@numLayers + 1 - i))
      @batch.setColor(tint, tint, tint, 1)
      
      @batch.begin
      
        @renderer.renderTileLayer(@map.getLayers.get(i))
        
        if @map.getLayers.get(i).name == "mid"
          @player.draw(@batch)
        end
      
      @batch.end
      
    end
    
This method for rendering the layers displays a nice Ruby feature.

    for i in 0...@numLayers
    
This range has three periods instead of two. Normally in Java you'd need a (@numLayers - 1), but with Ruby ranges .. means "up to and including" while ... means just "up to". So by adding the third period into the range you avoid tagging on - 1 to a lot of things. For some reason, I feel like it would have made more sense if they were flipped, but it is still a nice feature.

    for i in 0..6
      puts i    #prints 0, 1, 2, 3, 4, 5, 6
    end
    
    for i in 0...6
      puts i    #prints 0, 1, 2, 3, 4, 5
    end

Other than that, the only tricky part may be how the tint is calculated. Instead of trying to set an individual brightness for each layer I just use an exponential decay function. The value of this effort increases greatly when you start jumping between many layers and adjusting the brightness of all of them to match. It's a bit overkill for this simple example. Skip this part if you just want to know how to make a simple jumper. It's mostly aesthetic. 

---- MATH ----

The decay function kind of looks like a roller coaster drop and makes a nice natural fall off in brightness. It would look like this for 6 layers.

    Layer 6    |
    Layer 5    ||
    Layer 4    |||
    Layer 3    |||||
    Layer 2    ||||||||||
    Layer 1    |||||||||||||||||||
    Layer 0    ||||||||||||||||||||||||||||||||||||
    
Since the layers are rendered from the bottom up, I use (@numLayers - 1 - i) for the argument to the function. This is so that the tint starts dark and becomes brightest when it is at the final, or closest, layer. It contains the - 1 we avoided by using 0...6 instead of 0..6. So on the "graph" as we render the layers it starts at the bottom right and works towards the top left increasing in brightness. Really we are going backwards through the function. This is why you need (*@numLayers - 1* - i) instead of just i as the argument. You could also just resort the layers, but you'll find that you then have to go backwards through them to render and do other things with them since you draw to the screen from the back to the front. If you substitute the index of the final layer, i = @numLayers - 1,  into the function you get:

    Math.exp(-0.22 * (@numLayers - 1 - (@numLayers - 1)))

That gives you Math.exp(0) which is 1. That is the maximum value for the exponential function with coefficent 1 and an below or equal to zero. So you end up with the *last* layer rendererd being the brightest. And the first layer rendered being the darkest. As it should be.

---- END MATH ----

GameScreen.rb renderLayers:

    ...

    if @map.getLayers.get(i).name == "mid"
      @player.render(batch)
    end
    
    ...
    
This makes sure that the player is rendered right after the "mid" layer is rendered and at the same tint. The player is meant to be standing on the "mid" layer. That is the layer that will have solid blocks.

GameScreen.rb setupTileBodies:

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
    

The next method is setupTileBodies where the solid tiles are given box2d bodies for collision. I won't go into how to use Tiled map editor, but if you open the map from the repository you'll see that some of the tiles are given a "solid" property. This will be used to build their box2d bodies. Since I'm taking these methods from my game you can see that they are intended to be used for multiple layers with different collision masks, but for now it is just a single layer that gets setup. The method goes through every tile in the layer and checks to see if it has the property of "solid".

    next if tileLayer.getCell(col, row).nil?

This is an inline if statement in Ruby that will jump to the next iteration if the current cell of the map contains no tile. The rest is basic box2d stuff. The cell's Tile object is set as userData for the body. This will be used later. That is it for the new GameScreen script, but we need to add a few classes before anything will run.

That is it for the new GameScreen script. After we add the player scripts this will be a working platformer.
    
Getting A Player Setup
----------------------

There are three scripts involved in getting the player up and running. Player.rb, PlayerListener.rb, and PlayerContactListener.rb. I won't cover every detail, but I'll try and get the key ideas. Rely on the source in the repository to make sure you have everything.

Player.rb:

     class Player
  
       attr_accessor :pos, :vel, :body, :contacts
   
       MAX_VELX, MAX_VELY = 20, 30
       
       ...

Here you can see how to setup getters, setters, and constants for a class in Ruby. @pos will now be available as an instance variable defaulted to nil and can be accessed and read like this.

    GET_OBJECT = @player.pos
    @player.pos = SET_OBJECT
    
These can also be overriden if you need to put extra logic into them.

    def pos(pos)
      @pos = pos
    end
    
To access this one treat it as a method.

    @player.pos(Vector2.new)
    
I often prefer overriding = though.

    def pos=(pos)
      @pos = pos
    end
    
This can be accessed in the exact same way as the default setter.

    @player.pos = Vector2.new

But remember that if you add extra logic and you need to have it run from the class it was declared in you'll have to use the self reference. That confused me for a while. It doesn't come up much.

    self.pos = Vector2.new

-----

There are a couple things to say about how the animations are setup.

Player.rb initialize:

    ...

    @width = C::WTB * @atlas.findRegion("security1/idleUp1").getRegionWidth
    @height = C::WTB * @atlas.findRegion("security1/idleUp1").getRegionHeight

    ...
    
This is to convert the raw pixel sizes into the box2d scale when getting the size from the atlas. C::WTB is the "World To Box" factor again.

Player.rb initialize:

    ...
    
    frames = Java::ComBadlogicGdxUtils::Array.new
    
    for i in 1..8
      frames.add(@atlas.findRegion("security1/walkLeft#{i}"))
    end
    
    @walkLeft = Animation.new(0.0874, frames)
    
    ...
    
This is the example of accessing a Java class directly I was referring to before. Since Animation takes a libgdx Array it was easier to start with one instead of trying to convert it from a Ruby array. By easier, I mean I tried for a long time to do it the other way and then gave up and just looked up how to access the class directly. It was worth knowing anyway. You can also see how Ruby lets you embed a variable into a string. This would also work.

    frames.add(@atlas.findRegion("security1/walkLeft" + i.to_s))
    
You can see the use of some symbols in the update method.

Player.rb update:

    ...

    if @contacts == 0
             
      if @facing == :left
        @frame = @jumpLeft.getKeyFrame(@stateTime, true)
      elsif @facing == :right
        @frame = @jumpRight.getKeyFrame(@stateTime, true)
      end
      
      ...
    
Notice how neither :left or :right were ever declared before this in the class. It doesn't matter to Ruby. @contacts is the number of objects the player's foot sensor is touching. If the player is facing left or right and their feet are not contacting the ground then the player is assumeed to be jumping by checking if @contacts == 0. If you aren't touching the ground then you're jumping. How @contacts is determined will come a little later.

Player.rb updateVelocity:

    ...
    
    if linVel.x.abs > MAX_VELX
      linVel.set((linVel.x <=> 0) * MAX_VELX, linVel.y)
    end
    
    ...
    
Another nice Ruby operator is used here. The <=> operator becomes a sign operator when the second argument is 0. But you can use it on any two arguments to test which is greater than the other or are they equal all in one check. Here it is used to set the sign of the player's velocity based on whether or not the linear velocity in the x direction is positive or negative.

If you're going to add to this code, remember that the player's draw method is offset so that the player's position is in the center of their body instead of on the lower left.

Player.rb draw:

    batch.draw(@frame, @pos.x - @width / 2, @pos.y - @height / 2, @width, @height)

The setupBody method may seem complicated, but it is just a lot of the same thing over and over. This is where the capsule-like box2d body is setup for the player. It can easily be changed to setup a body for any entity in the game. As a matter of fact, I created the method by swapping a couple things in my setupEntity class for my game. I don't think there is much more that needs to be explained in Player.rb with regards to working with Ruby. There are plenty of libgdx references if a particular method doesn't make sense. The one thing to notice is that the foot sensor is given the number 0 as userData. This will be used to check if it is the player's foot hitting the ground instead of their torso or head. You don't want to be considered standing on the ground if only your head is touching the ground.

     @body.createFixture(sensorFixture).setUserData(0)

Finally, take a look at the slightly more simple "switch" statement that is in the keyDown method. In Ruby it is called "case". The number of contacts is used here again to make sure the player can't move or jump in the air.

Player.rb keyDown:

    ...

    if @contacts > 0
    
      case keycode
          
        when Keys::W, Keys::UP
          
          @facing = :back
          
        ...

That's it for the player script. The two listeners are the last pieces. The PlayerListener.rb and PlayerContactListener.rb are almost exactly as you'd setup in Java and don't represent anything different from what has already been done. Just copy them from the repository and look them over to make sure you see how they work. There are just a couple things about the contact listener that are worth pointing out.

PlayerContactListener.rb beginContact:
    
    ...

    if a.instance_of?(Player) 
      
      if contact.getFixtureA.getUserData == 0 && b.instance_of?(StaticTiledMapTile)
        @player.contacts += 1
      end   
    
    end
     
    ...
     
Notice Ruby's instanceOf method. This is the general format for testing methods in Ruby - with the ? at the end like that. .kind_of? also works. The same method is used to determine if it has contacted a StaticTiledMapTile. Ruby also has all the string tests built in like:

    string.start_with?("prefix")
    string.end_with?("suffix")
    string.include?("this string")

We also use the userData we set earlier to make sure we have the foot sensor instead of another part of the player's body. If that is all true then the number of contacts is increased, or decreased when the contact ends. Ruby does not include the ++ or -- operator.

If you run the completed program with the debugRenderer uncommented in GameScreen.rb you should have a basic working platformer and a player that can climb stairs and jump around on the map. Request any clarifications or additions at 08kabbotta80@gmail.com.


