require 'ruby3d'

include Ruby3d::Core::Math

puts 'Testeo de vectores'
v1 = Vector.new(1.0, 2.0, 0.0)
v2 = Vector.new(2.0, 2.0, 0.0)
v = Vector.new(1.0, 3.0, 2)

puts "v1: #{v1}"
puts "v2: #{v2}"
puts "Adición v1 + v2 #{v1 + v2}"
puts "Substracción v1 - v2 #{v1 - v2}"
puts "Escalamiento 5 * v1 #{5 * v1}"
puts "Producto escalar v1 * v2 #{v1 * v2}"
puts "Producto escalar 3D v1 * v2 #{v1.dot_product3 v2}"
puts "Producto vectorial v1 x v2 #{v1.cross_product v2}"
puts "Division v1 / 2 #{v1 / 2.0}"
puts "v: #{v}"
puts "v.normalize: #{v.normalize}"
puts "v: #{v}"
puts "v.normalize!: #{v.normalize!}"
puts "v: #{v}"
puts "v.length: #{v.length}"
puts "v1.negate: #{v.negate}"
puts "v == v?: #{v == v} "

puts 'Testeo de matrices'

m = Matrix.new
puts "m #{m}"
puts "m.identity! #{m.identity!}"
puts "m.rotateX! #{m.rotate_x! Math::PI / 6}"
puts "m.rotateY! #{m.rotate_y! Math::PI / 6}"
puts "m.rotateZ! #{m.rotate_z! Math::PI / 6}"
puts "m.translateMatrix! #{m.translate_matrix! v1}"
puts "m.scaleMatrix! #{m.scale_matrix! v1}"

m = Matrix.new
m.rotate_z! Math::PI / 6
m[3, 3] = 2.0
puts "m #{m}"
puts "m.determinant #{m.determinant}"
puts "m * inv(m): #{m * m.inverse}"
puts "m * inv(m) == I: #{m * m.inverse == Matrix.new.identity!}"

puts 'Rotar vector por 30 grados alrededor del eje Z'
m.rotate_z! Math::PI / 6
m2 = Matrix.new.scale_matrix! Vector.new(2, 2, 2)
v = Vector.new(2, 1)
puts "v #{v}"
puts "v.length #{v.length}"
puts "mRotación #{m}"
puts "mEscalar #{m2}"

v = m2 * m * v
puts "Vector rotado y escalado: mEscalar * mRotación * v #{v}"
puts "v.length #{v.length}"

puts 'Testeo de Colores'
v1 = Vector.new(0.1, 2.0, 0.0)
v2 = Vector.new(2.0, 0.1, 0.0)

puts "v1: #{v1}"
puts "v2: #{v2}"
puts "Adición v1 + v2 #{v1 + v2}"
puts "Substracción v1 - v2 #{v1 - v2}"
puts "Producto escalar v1 * v2 #{v1 * v2}"
puts "Division v1 / 2 #{v1 / 2.0}"

puts 'Testeo de Rayos y Objetos'
objects = [Sphere.new(Vector.new(2, 2, 2), 1.0),
           Triangle.new(Vector.new(1, 1, 6),
                        Vector.new(3, 1, 6),
                        Vector.new(2, 10, 6))]

puts objects

ray1 = Ray.new(Vector.new, Vector.new(1, 1, 1))
ray2 = Ray.new(Vector.new, Vector.new(2, 9, 6))

puts "Rayo 1: #{ray1}"
puts "Rayo 2: #{ray2}"

puts 'Prueba de intersección'

t0 = 0
tf = Float::INFINITY
intersected = Intersection.new
objects.each do |o|
  inter_info = Intersection.new
  if o.intersect(ray1, t0, tf, inter_info)
    tf = inter_info.info.x
    intersected = inter_info
  end
end

puts "Información de intersección con rayo1: #{intersected}"

t0 = 0
tf = Float::INFINITY
intersected = Intersection.new
objects.each do |o|
  inter_info = Intersection.new
  if o.intersect(ray2, t0, tf, inter_info)
    tf = inter_info.info.x
    intersected = inter_info
  end
end

puts "Información de intersección con rayo2: #{intersected}"