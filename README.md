LibGDX-and-Ruby
===============

A general reference for using JRuby with libGDX for the Desktop platform.

Setup
-----

The Eclipse [DLTK plugin](http://www.eclipse.org/dltk/) does a decent job with JRuby. You'll be giving up some of the content-assist you had with Java in Eclipse (For instance, you don't have the shortcut to automatically require the right imports), but Ruby has advantages as well. 

Since this is for the desktop the project setup is very easy. First, I create a project folder containing three subfolders. For example,

    /Test-Game
    /Test-Game/assets
    /Test-Game/libs
    /Test-Game/src

In the '/libs' folder you need to put the main gdx files for your OS. I would also grab gdx-tools out of /extensions so you can automatically pack your textures. On linux, mine looks like this.

    /libs/gdx.jar
    /libs/gdx-backend-lwjgl.jar
    /libs/gdx-backend-lwjgl-natives.jar
    /libs/gdx-natives.jar
    /libs/gdx-tools.jar

That's pretty much it. We need a simple Ruby script to test the setup. Add a script /Test-Game/src/Test-Game.rb like this.

    require 'src/util/Initializer'

    class TestGame < Game
  
      def create()
        #Game goes here
      end
  
    end

    LwjglApplication.new(TestGame.new, "Test Game", 800, 600, true)
    
This should display a black window that is 800x600 if we add the 'src/util/Initializer.rb' file which is a just a convenience to avoid having imports clutter up all of your script files. For now, this is all that is needed.

    require 'java'
    
    Dir["libs/\*.jar"].each { |jar| require jar }
    
    java_import com.badlogic.gdx.Gdx
    java_import com.badlogic.gdx.Game
    
The project should now run.


