# Triangle Class, this class represents a mathematical definition of a triangle
# triangle.rb
# Author: Pablo Sanabria

require 'ruby3d/core/math/vector'
require 'ruby3d/core/math/ray'

module Ruby3d
  module Core
    module Math    
      class Triangle
        attr_reader :vertex1
        attr_reader :vertex2
        attr_reader :vertex3

        def initialize(vertex1, vertex2, vertex3)
          @vertex1 = vertex1
          @vertex2 = vertex2
          @vertex3 = vertex3
        end

        def intersect(ray, t0, tf, intersection_info)
          a = vertex1.x - vertex2.x
          b = vertex1.y - vertex2.y
          c = vertex1.z - vertex2.z
          d = vertex1.x - vertex3.x
          e = vertex1.y - vertex3.y
          f = vertex1.z - vertex3.z
          g = ray.position.x
          h = ray.direction.y
          i = ray.direction.z
          j = vertex1.x - ray.origin.x
          k = vertex1.y - ray.origin.y
          l = vertex1.z - ray.origin.z
          
          f1 = e * i - h * f
          f2 = g * f - d * i
          f3 = d * h - e * g
          f4 = a * k - j * b
          f5 = j * c - a * l
          f6 = b * l - k * c
          
          m = a * f1 + b * f2 + c * f3          
          
          return false if m == 0
          
          t = -(f * f4 + e * f5 + d * f6) / m          
          
          return false if t < t0 || t > tf
          
          gamma = (i * f4 + h * f5 + g * f6) / m
                    
          return false if gamma < 0 || gamma > 1
          
          beta = (j * f1 + k * f2 + l * f3) / m
                    
          return false if beta < 0 || beta > 1
          
          intersection_info.object = self
          intersection_info.info.y = beta
          intersection_info.info.z = gamma
          intersection_info.info.x = t
          
          true
        end
        
        def to_s
          "Triangle:\nVertex 1: #{@vertex1}\n" \
          "Vertex 2: #{@vertex2}\n" \
          "Vertex 3: #{@vertex3}\n"
        end
      end
    end
  end
end