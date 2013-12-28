LibGDX and Ruby
===============

Setup
-----

The Eclipse [DLTK plugin](http://www.eclipse.org/dltk/) does a decent job with JRuby. You'll be giving up some of the content-assist you had with Java in Eclipse (For instance, you don't have the shortcut to automatically require the right imports), but Ruby comes with advantages of its own and with DLTK you still get some things like auto-complete.

Since this is for the desktop the project setup is very easy. First, I create a project directory containing three subdirectories.

    /Test-Game
    /Test-Game/assets
    /Test-Game/libs
    /Test-Game/src

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

Seting Up A Camera and Tiled Map
--------------------------------




