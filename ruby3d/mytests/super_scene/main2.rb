require 'ruby3d'

include Ruby3d
include Ruby3d::Core::Math
include Ruby3d::Assets
include Ruby3d::Graphics::Scene::Light
include Ruby3d::Graphics::Scene

class MyGame < Game
  def start_game
    super
    to = Time.now
    scene.ambient_color = Color.new(0.1, 0.1, 0.1)
    scene.ambient_color = Color.new(0.1, 0.1, 0.1)
    scene.camera = Ruby3d::Graphics::Scene::Camera::FirstPersonCamera.new(20)
    scene.camera.position = Vector.new(0.0, 0.0, 0.0)
    scene.camera.field_of_view = 47
    scene.camera.far_clip = 2000.0
   # scene.enable_fog(Color.new(0.5, 0.5, 0.5, 1.0), 0.35, 0.0, 120.0)
    scene.enable_show_bounding_box

    model = asset_manager.load_obj_model('Models/sponza.obj')
    model.scale(0.25, 0.25, 0.25)
    #model.translate(24.8, -10.4, 10.0)
    scene.add_geometry(model)

    light = PointLight.new
    light.set_position(0, 18, 0.01)
    #light.set_direction(12, 18, 0.01)
    light.light_color = Color.new(1.0, 1.0, 1.0)
    scene.add_light(light)
   # scene.enable_shadowing(200)
    tf = Time.now
    puts "Tiempo transcurrido: #{tf - to}"
  end



  def update

  end
end


MyGame.instance.run