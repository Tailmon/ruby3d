require 'ruby3d'

include Ruby3d
include Ruby3d::Core::Math
include Ruby3d::Assets
include Ruby3d::Graphics::Scene::Light
include Ruby3d::Graphics::Scene

class MyGame < Game
  def start_game
    super
    scene.ambient_color = Color.new(0.3, 0.3, 0.3)
   # scene.camera = Ruby3d::Graphics::Scene::Camera::FirstPersonCamera.new(20)
    scene.camera.position = Vector.new(0.0, 0.0, 60.0)
    scene.camera.field_of_view = 45
    scene.camera.look_at = Vector.new(0.0, -1.0, -10.0)
    scene.enable_fog(Color.new(0.5, 0.5, 0.5, 1.0), 0.35, 0.0, 120.0)

    add_walls

    model = asset_manager.load_obj_model('Models/Teapot.obj')
    model.scale(4.0, 4.0, 4.0)
    scene.add_geometry(model)
    @model = model
    @angle = 0
    @y_pos = 10
    @gravity = 9.8

    model = asset_manager.load_obj_model('Models/Desk.obj')
    model.scale(5.6, 5.6, 5.6)
    model.translate(17.2, -20, -7.2)
    model.rotate(270, 0.0, 1.0, 0.0)
    scene.add_geometry(model)

    model = asset_manager.load_obj_model('Models/Table.obj')
    model.scale(0.36, 0.36, 0.36)
    model.translate(25.8, -20.4, 13.8)
    model.rotate(270, 0.0, 1.0, 0.0)
    scene.add_geometry(model)

    model = asset_manager.load_obj_model('Models/soda.obj')
    model.scale(1.6, 1.6, 1.6)
    model.translate(23.2, -9.2, -16.8)
    scene.add_geometry(model)

    model = asset_manager.load_obj_model('Models/statue.obj')
    model.scale(0.14, 0.14, 0.14)
    model.translate(-20, -20.4, -11)
    model.rotate(0, 0.0, 1.0, 0.0)
    scene.add_geometry(model)



    light = PointLight.new
    light.set_position(0, 18, 0.01)
    #light.set_direction(12, 18, 0.01)
    light.light_color = Color.new(1.0, 1.0, 1.0)
    scene.add_light(light)
    scene.enable_shadowing(50, 756)
  end

  def add_walls
    wallMaterial = Material.new('wall')
    asset_manager.add_material(wallMaterial)
    wallMaterial.diffuse_color = Color.new(1.0, 1.0, 1.0)
    wallMaterial.texture = asset_manager.load_texture('Textures/wall.jpg')
    wallMaterial.normal_map = asset_manager.load_texture('Textures/normal.bmp')

    ceil_material = Material.new('ceil')
    asset_manager.add_material(ceil_material)
    ceil_material.diffuse_color = Color.new(1.0, 1.0, 1.0)

    floorMaterial = Material.new('floor')
    asset_manager.add_material(floorMaterial)
    floorMaterial.diffuse_color = Color.new(1.0, 1.0, 1.0)
    floorMaterial.texture = asset_manager.load_texture('Textures/woodfloor.jpg')


    # Backwall
    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, 20, -20),
        Vector3d.new(-30, -20, -20),
        Vector3d.new(30, -20, -20)
    )
    triangle.normal1 = Vector3d.new(0, 0, 1)
    triangle.normal2 = Vector3d.new(0, 0, 1)
    triangle.normal3 = Vector3d.new(0, 0, 1)
    triangle.texture_coords1 = Vector2d.new(0, 0)
    triangle.texture_coords2 = Vector2d.new(0, 1)
    triangle.texture_coords3 = Vector2d.new(1, 1)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)

    triangle = Geometry::Triangle.new(
        Vector3d.new(30, 20, -20),
        Vector3d.new(-30, 20, -20),
        Vector3d.new(30, -20, -20)
    )
    triangle.normal1 = Vector3d.new(0, 0, 1)
    triangle.normal2 = Vector3d.new(0, 0, 1)
    triangle.normal3 = Vector3d.new(0, 0, 1)
    triangle.texture_coords1 = Vector2d.new(1, 0)
    triangle.texture_coords2 = Vector2d.new(0, 0)
    triangle.texture_coords3 = Vector2d.new(1, 1)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)


    #Leftwall
    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, -20, 20),
        Vector3d.new(-30, -20, -20),
        Vector3d.new(-30, 20, -20)
    )
    triangle.normal1 = Vector3d.new(1, 0, 0)
    triangle.normal2 = Vector3d.new(1, 0, 0)
    triangle.normal3 = Vector3d.new(1, 0, 0)
    triangle.texture_coords1 = Vector2d.new(1, 1)
    triangle.texture_coords2 = Vector2d.new(0, 1)
    triangle.texture_coords3 = Vector2d.new(0, 0)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)

    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, 20, 20),
        Vector3d.new(-30, -20, 20),
        Vector3d.new(-30, 20, -20)
    )
    triangle.normal1 = Vector3d.new(1, 0, 0)
    triangle.normal2 = Vector3d.new(1, 0, 0)
    triangle.normal3 = Vector3d.new(1, 0, 0)
    triangle.texture_coords1 = Vector2d.new(1, 0)
    triangle.texture_coords2 = Vector2d.new(1, 1)
    triangle.texture_coords3 = Vector2d.new(0, 0)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)

    #Rigthwall
    triangle = Geometry::Triangle.new(
        Vector3d.new(30, -20, -20),
        Vector3d.new(30, -20, 20),
        Vector3d.new(30, 20, -20)
    )
    triangle.normal1 = Vector3d.new(-1, 0, 0)
    triangle.normal2 = Vector3d.new(-1, 0, 0)
    triangle.normal3 = Vector3d.new(-1, 0, 0)
    triangle.texture_coords1 = Vector2d.new(0, 1)
    triangle.texture_coords2 = Vector2d.new(1, 1)
    triangle.texture_coords3 = Vector2d.new(0, 0)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)

    triangle = Geometry::Triangle.new(
        Vector3d.new(30, -20, 20),
        Vector3d.new(30, 20, 20),
        Vector3d.new(30, 20, -20)
    )
    triangle.normal1 = Vector3d.new(-1, 0, 0)
    triangle.normal2 = Vector3d.new(-1, 0, 0)
    triangle.normal3 = Vector3d.new(-1, 0, 0)
    triangle.texture_coords1 = Vector2d.new(1, 1)
    triangle.texture_coords2 = Vector2d.new(1, 0)
    triangle.texture_coords3 = Vector2d.new(0, 0)
    triangle.material1 = wallMaterial
    triangle.material2 = wallMaterial
    triangle.material3 = wallMaterial

    scene.add_geometry(triangle)

    #Ceil

    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, 20, -20),
        Vector3d.new(30, 20, -20),
        Vector3d.new(30, 20, 20)
    )
    triangle.normal1 = Vector3d.new(0, -1, 0)
    triangle.normal2 = Vector3d.new(0, -1, 0)
    triangle.normal3 = Vector3d.new(0, -1, 0)
    triangle.material1 = ceil_material
    triangle.material2 = ceil_material
    triangle.material3 = ceil_material

    scene.add_geometry(triangle)

    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, 20, -20),
        Vector3d.new(30, 20, 20),
        Vector3d.new(-30, 20, 20)
    )
    triangle.normal1 = Vector3d.new(0, -1, 0)
    triangle.normal2 = Vector3d.new(0, -1, 0)
    triangle.normal3 = Vector3d.new(0, -1, 0)
    triangle.material1 = ceil_material
    triangle.material2 = ceil_material
    triangle.material3 = ceil_material

    scene.add_geometry(triangle)

    #Floor
    triangle = Geometry::Triangle.new(
        Vector3d.new(-30, -20, -20),
        Vector3d.new(-30, -20, 20),
        Vector3d.new(30, -20, -20)
    )
    triangle.normal1 = Vector3d.new(0, 1, 0)
    triangle.normal2 = Vector3d.new(0, 1, 0)
    triangle.normal3 = Vector3d.new(0, 1, 0)
    triangle.texture_coords1 = Vector2d.new(0, 1)
    triangle.texture_coords2 = Vector2d.new(0, 0)
    triangle.texture_coords3 = Vector2d.new(1, 1)
    triangle.material1 = floorMaterial
    triangle.material2 = floorMaterial
    triangle.material3 = floorMaterial

    scene.add_geometry(triangle)

    triangle = Geometry::Triangle.new(
        Vector3d.new(30, -20, -20),
        Vector3d.new(-30, -20, 20),
        Vector3d.new(30, -20, 20)
    )
    triangle.normal1 = Vector3d.new(0, 1, 0)
    triangle.normal2 = Vector3d.new(0, 1, 0)
    triangle.normal3 = Vector3d.new(0, 1, 0)
    triangle.texture_coords1 = Vector2d.new(1, 1)
    triangle.texture_coords2 = Vector2d.new(0, 0)
    triangle.texture_coords3 = Vector2d.new(1, 0)
    triangle.material1 = floorMaterial
    triangle.material2 = floorMaterial
    triangle.material3 = floorMaterial

    scene.add_geometry(triangle)
  end

  def update
    @model.rotate(@angle, 0.0, 1.0, 0.0)
    @model.translate(24.8, @y_pos, 10.0)
    @angle += 2.0
    list = @model.collision_list(scene)
    if (list.size == 0)
      @y_pos -= 0.05
    end
   # @model_bob.update(@elapsed_time)
  end
end


MyGame.instance.run