LibGDX and JRuby
================

Setup
-----

The Eclipse [DLTK plugin](http://www.eclipse.org/dltk/) does a decent job with JRuby. You'll be giving up some of the content-assist you had with Java in Eclipse (For instance, you don't have the shortcut to automatically require the right imports), but Ruby comes with advantages of its own and with DLTK you still get some things like auto-complete.

Since this is for the desktop the project setup is very easy. First, I create a project directory containing three subdirectories.

    /TestGame
    /TestGame/assets
    /TestGame/libs
    /TestGame/src

Put the main gdx files for your OS in the '/libs' folder. I would also grab gdx-tools out of '/extensions' in the [libGdx archive](http://libgdx.badlogicgames.com/nightlies/) so you can automatically pack your textures. On linux, mine looks like this.

    /libs/gdx.jar
    /libs/gdx-backend-lwjgl.jar
    /libs/gdx-backend-lwjgl-natives.jar
    /libs/gdx-natives.jar
    /libs/gdx-tools.jar

We need a simple Ruby script to test the setup. Add one called '/Test-Game/src/TestGame.rb'.

    require 'src/util/Initializer'

    class TestGame < Game
  
      def create()
        #Game goes here
      end
  
    end

    LwjglApplication.new(TestGame.new, "Test Game", 800, 600, true)
    
That's pretty much it. This should display a black window if we add the 'src/util/Initializer.rb' script. Which is just a convenience to avoid having imports clutter up all of your scripts. For now, this is all that is needed.

    require 'java'
    
    Dir["libs/\*.jar"].each { |jar| require jar }
    
    java_import com.badlogic.gdx.Gdx
    java_import com.badlogic.gdx.Game
    
The project should now run. The second line is just a way of loading all of the jars out of the '/libs' folder in one swipe. Iterations in Ruby are done using the .each method for an object. JRuby allows you to call .each on native Java collections as well. The 'require 'java'' line allows direct access to all of the builtin Java classes. Of course, you will need to have installed [JRuby](https://github.com/jruby/jruby/wiki/GettingStarted).

Adding A Camera and Tiled Map
-----------------------------

To get a Tiled map displayed on a basic game screen we first need to add one line to 'TestGame.rb'.

    def create()
      setScreen(GameScreen.new)
    end

Now we need the GameScreen class. I setup my '/src' directory like this.

    /src/logic
    /src/objects
    /src/util
    
With TestGame sitting outside alone.

    /src/TestGame.rb
    
Put the GameScreen script in '/objects'.

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
        
I won't explain how to use libGdx, but a couple things are worth noting with JRuby. When you want to refer to the underlying class you will need to use .java_class, because it will otherwise refer to the Ruby object which the Java library doesn't know how to handle. Other than that, notice that pretty much *all* parenthesis are optional. I use them when a method needs arguments and when defining a method, but both of these can be done away with.

    def onEvent(type, source)

is equivalent to

    def onEvent type, source
    
in Ruby.

        ...
            
        @cam = OrthographicCamera.new(Gdx.graphics.getWidth * C::WTB, Gdx.graphics.getHeight * C::WTB)
        @cam.setToOrtho(false, 40, 30)
        @cam.position.set(Vector3.new(32, 26, 0))
        @cam.update
            
        @renderer = OrthogonalTiledMapRenderer.new(@map, 1 / 16.0)
        @renderer.getSpriteBatch.setProjectionMatrix(@cam.combined)
        @renderer.setView(@cam)
                
      end
      
      ...
      
When you need to refer to an object within a namespace you use the :: operator to access it. C::WTB is the "World to Box" conversion scale that is used in Box2d to get the units right. This is also how you access a subclass when importing from java.

    java_import com.badlogic.gdx.Input::Keys

You can also access a java class directly. I used this in the case of the libGdx Array class, because otherwise it will bark at you about trying to redefine the Array that is included from Java if try and use it in the general namespace by importing it.

    frameTiles = Java::ComBadLogicUtils::Array.new

You just remove all the periods and use CamelCase to access the class directly without importing. If you needed to use it numerous times you could just create an alias for it using Ruby to avoid the warning.

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

You need to declare the implemented methods. I think in Java it ignores them if they are missing. Also, notice that Ruby pretty much treats all numbers the same. No more f's all over the place or issues with whether or not you sent a float or a int to a function. If you need to convert something they have short little methods built in along with basic math functions.

    @float.to_i
    @integer.to_s
    
These will take a float to an integer and an integer to a string. There are more .to_ methods and other builtins like .abs and exponentiation.

    @float**3

To make it run the Initializer must be updated to include all of the new imports and require statements for the scripts you want to use.

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
    
Lastly, add the two utility scripts for the game's constants and texture packing. I name my constants script C. I don't know if this is considered bad practice, but I like how simple it is. Ruby has a more bare module object which works as a simple block of code instead of the full class structure where I put my constants that are used across many scripts like the Box2d conversions.

C.rb:

    module C

      BOX_STEP = 1/45.0
      BOX_VELOCITY_ITERATIONS = 8
      BOX_POSITION_ITERATIONS = 3
      BTW, WTB = 16.0, 1/16.0
    
    end
    
Any variable declared with a capital letter is considered a constant and shouldn't be changed. Ruby allows for parallel assignment.

TextureSetup.rb:

    class TextureSetup
      
      def initialize()
        
        TexturePacker2.process("assets/gfx", "assets/gfx", "graphics.pack")
        
      end
      
    end

The initialize method is similar to the Java constructor. It is a private hidden method that is called through the .new method of a class. 

You should now have a simple rendered map and associated camera with libGdx and JRuby.
