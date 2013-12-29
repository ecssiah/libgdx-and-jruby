require 'java'

Dir["libs/\*.jar"].each { |jar| require jar }

java_import com.badlogic.gdx.backends.lwjgl.LwjglApplication

java_import com.badlogic.gdx.Gdx
java_import com.badlogic.gdx.Game
java_import com.badlogic.gdx.Screen
java_import com.badlogic.gdx.Input::Keys
java_import com.badlogic.gdx.graphics.GL20
java_import com.badlogic.gdx.graphics.Color
java_import com.badlogic.gdx.graphics.OrthographicCamera
java_import com.badlogic.gdx.graphics.g2d.TextureRegion
java_import com.badlogic.gdx.graphics.g2d.TextureAtlas
java_import com.badlogic.gdx.graphics.g2d.Animation
java_import com.badlogic.gdx.assets.AssetManager
java_import com.badlogic.gdx.assets.loaders.TextureAtlasLoader
java_import com.badlogic.gdx.assets.loaders.resolvers.InternalFileHandleResolver
java_import com.badlogic.gdx.maps.tiled.TiledMap
java_import com.badlogic.gdx.maps.tiled.TmxMapLoader
java_import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer
java_import com.badlogic.gdx.maps.tiled.tiles.StaticTiledMapTile
java_import com.badlogic.gdx.math.Vector2
java_import com.badlogic.gdx.math.Vector3
java_import com.badlogic.gdx.scenes.scene2d.InputListener
java_import com.badlogic.gdx.physics.box2d.World
java_import com.badlogic.gdx.physics.box2d.BodyDef  
java_import com.badlogic.gdx.physics.box2d.BodyDef::BodyType  
java_import com.badlogic.gdx.physics.box2d.Fixture  
java_import com.badlogic.gdx.physics.box2d.FixtureDef
java_import com.badlogic.gdx.physics.box2d.CircleShape
java_import com.badlogic.gdx.physics.box2d.PolygonShape
java_import com.badlogic.gdx.physics.box2d.Filter
java_import com.badlogic.gdx.physics.box2d.ContactListener
java_import com.badlogic.gdx.physics.box2d.Box2DDebugRenderer  
java_import com.badlogic.gdx.tools.imagepacker.TexturePacker2

require 'src/logic/PlayerListener'
require 'src/logic/PlayerContactListener'
require 'src/objects/Player'
require 'src/objects/GameScreen'
require 'src/util/C'
require 'src/util/TextureSetup'
