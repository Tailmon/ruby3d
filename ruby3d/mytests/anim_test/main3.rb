require 'ruby3d'

include Ruby3d
include Ruby3d::Core::Math
include Ruby3d::Assets
include Ruby3d::Graphics::Scene::Light
include Ruby3d::Graphics::Scene

class MyGame < Game
  def start_game
    super
    scene.ambient_color = Color.new(0.8, 0.8, 0.8)
    scene.camera.position = Vector.new(0.0, 15.0, -15.0)
    scene.camera.field_of_view = 47
    scene.camera.look_at = Vector.new(0.0, 8.0, 0.0)
   # scene.enable_fog(Color.new(0.5, 0.5, 0.5, 1.0), 0.35, 0.0, 120.0)

    model = asset_manager.load_md5_model('Models/Boblamp/boblampclean.md5mesh', 'Models/Boblamp/boblampclean.md5anim')
    model.scale(0.2, 0.2, 0.2)
    model.rotation_x = 90
    model.rotation_y = 180
    scene.add_geometry(model)
    @model = model


    light = PointLight.new
    light.set_position(0, 18, 0.01)
    #light.set_direction(12, 18, 0.01)
    light.light_color = Color.new(1.0, 1.0, 1.0)
    scene.add_light(light)
 #   scene.enable_shadowing(50)
  #  scene.enable_show_bounding_box
  end


  def update
    @model.update(@elapsed_time)
  end
end


MyGame.instance.run