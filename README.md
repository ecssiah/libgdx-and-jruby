Setup
-----

The Eclipse [DLTK plugin](http://www.eclipse.org/dltk/) does a decent job with JRuby. Just search for it in the marketplace. You'll be giving up some of the content-assist you had with Java (there is no shortcut to automatically add the right imports or quickfix), but Ruby comes with advantages of its own. Also, with the DLTK you still get basic things like auto-complete on your own objects and the builtin java classes. I have tried to get auto-complete for libgdx methods, but I don't think the plugin supports linking source to a Ruby project yet.

Since this is for the desktop, the project setup is very easy. Create a project directory like this.

    /TestGame/assets
    /TestGame/libs
    /TestGame/src

Put the main gdx files for your OS in the '/libs' folder. I would also grab gdx-tools.jar out of '/extensions' in the [libGdx archive](http://libgdx.badlogicgames.com/nightlies/) so you can automatically pack your textures. On linux, mine looks like this.

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
    
That's pretty much it. The boolean argument tells libGdx to use OpenGL 2.0. If you don't install 2.0 then you'll have to put false and change the import to GL10. This should display a black window if we add the Initializer.rb script to 'src/util'. This is just a convenience to avoid having imports clutter up all of your scripts. For now, this is all that is needed.

Initializer.rb:

    require 'java'
    
    Dir["libs/\*.jar"].each { |jar| require jar }
    
    java_import com.badlogic.gdx.Gdx
    java_import com.badlogic.gdx.Game
    java_import com.badlogic.gdx.graphics.GL20
    
The project should now run. The first line allows direct access to all of the builtin Java classes. Of course, you will need to have installed [JRuby](https://github.com/jruby/jruby/wiki/GettingStarted). The second line is just a way of loading all of the jars out of the '/libs' folder in one swipe. Iterations in Ruby are done using the .each method of an object. JRuby allows you to call .each on native Java collections as well. If you want an index then Ruby has a nice clean for loop.

    for i in @min..@max
      #Do things with i while it runs from the value @min up to @max
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

GameScreen.rb:

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
        
        ...
        
I won't explain how to use libGdx, but a couple things are worth noting with JRuby. When you want to refer to the underlying class you will need to use .java_class, because .class will now refer to the Ruby object which Java won't like. Other than that, notice that *all* of these parenthesis are optional. I use them when a method needs arguments and when defining a method, but both of these can be done away with.

    def onEvent(type, source)

is equivalent to

    def onEvent type, source
    
In Ruby, they say you should use on_event instead of onEvent, but I don't like all the extra underscores you end up typing and the java methods you'll be using are CamelCase so it just seems smoother to ignore this rule in this case.

        ...
            
        @cam = OrthographicCamera.new(Gdx.graphics.getWidth * C::WTB, Gdx.graphics.getHeight * C::WTB)
        @cam.setToOrtho(false, 40, 30)
        @cam.position.set(Vector3.new(32, 26, 0))
        @cam.update
            
        @renderer = OrthogonalTiledMapRenderer.new(@map, C::WTB)
        @renderer.getSpriteBatch.setProjectionMatrix(@cam.combined)
        @renderer.setView(@cam)
                
      end
      
      ...
      
When you need to refer to an object within another namespace you use the :: operator to access it. C::WTB is the "World to Box" conversion factor that is used in Box2d to get the units right. This is also how you access a subclass or an enum when importing from java.

    java_import com.badlogic.gdx.Input::Keys

You can access a java class directly. I used this in the case of the libGdx Array class, because otherwise it will bark at you about trying to redefine the Array that is included from Java.

    frameTiles = Java::ComBadLogicUtils::Array.new

You remove all the periods and use CamelCase to access the class directly without importing. I have no idea why they embraced the Camel here. If you needed to use it numerous times you could just create an alias for it using Ruby to avoid the warning. I find I rarely need to rely on a Java collection though.

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

The initialize method is similar to the Java constructor. It is a private hidden method that is called through the .new method of a Ruby class. Both .new and initialize() can be overriden separately so it is not identical to a Java constructor, but gets the same job done.

You should now have a simple rendered map and associated camera with libGdx and JRuby.


Getting A Player On Screen
--------------------------

Now, I'll stop going through every line of code and just point out the key ideas. The full source is in the TestGame folder in this repository. You should be able to import it directly into Eclipse as a project if you're on Linux. Add the Player.rb, PlayerListener.rb, and PlayerContactListener.rb scripts.

     class Player
  
       attr_accessor :pos, :vel, :body, :contacts
   
       MAX_VELX, MAX_VELY = 20, 30
       
       ...

Here you can see how to set up getters and setters and constants for a class in Ruby. pos will now be available as an instance variable defaulted to nil and can be accessed and read like this.

    @cam.position.x = @player.pos.x
    @player.pos = Vector2.new(0, 0)
    
These can also be overriden if you need to put logic into a setter or getter.

    def pos=(pos)
    
        #Do things related to setting @pos
        @pos = pos
    
    end
    
This can be accessed in the exact same way as the default setter.

    frames = Java::ComBadlogicGdxUtils::Array.new
    
    for i in 1..8
      frames.add(@atlas.findRegion("security1/walkLeft#{i}"))
    end
    
    @walkLeft = Animation.new(0.0874, frames)
    
This is an example of accessing a Java class directly. Since Animation takes a libGDX Array it was easier to start with one instead of trying to convert it afterwards. You can also see how Ruby lets you embed a variable into a string. This would also work.

    frames.add(@atlas.findRegion("security1/walkLeft" + i.to_s))
    
The update method for Player doesn't really have much to point out. It's all pretty much basic libGdx movement stuff. You can see the use of some symbols there.

Player.rb 57:

    ...

    if @contacts == 0
             
      if @facing == :left
        @frame = @jumpLeft.getKeyFrame(@stateTime, true)
      elsif @facing == :right
        @frame = @jumpRight.getKeyFrame(@stateTime, true)
      end
      
      ...
    
See how neither :left or :right were ever declared before this in the class. It doesn't matter to Ruby. @contacts is the number of objects the player's foot sensor is touching. If the player is facing left or right and and their feet are not contacting the ground then the frame is set for the correct jump animation. How @contacts is determined will come a little later.

The setupBody method may seem complicated, but it is just a lot of the same thing over and over. This is where the capsule-like box2d body is setup for the player. It can easily be changed to setup a body for any entity in the game. As a matter of fact, I created the method by swapping a couple things in my setupEntity class for my game. I don't think there is much mroe that needs to be explained in the light of Ruby and Java. There are plenty of libgdx references if a particular method doesn't make sense.

One last thing to notice is in the keyDown method. Ruby allows for an inline if statement like Java.

    Gdx.app.exit if keycode == Keys::ESCAPE
    
This will act exactly as

    if(keycode == Keys.ESCAPE) Gdx.app().exit();
    
does in Java.


Collision With The Tile Map
---------------------------
