require 'java'

Dir["libs/\*.jar"].each { |jar| require jar }

java_import 'aurelienribon.tweenengine.BaseTween'
java_import 'aurelienribon.tweenengine.Timeline'
java_import 'aurelienribon.tweenengine.Tween'
java_import 'aurelienribon.tweenengine.TweenCallback'
java_import 'aurelienribon.tweenengine.TweenManager'
java_import 'aurelienribon.tweenengine.TweenAccessor'

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
