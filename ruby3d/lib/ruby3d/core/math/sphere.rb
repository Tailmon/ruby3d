# Sphere class, this class represents a mathematical sphere definition
# sphere.rb
# Author: Pablo Sanabria

require 'ruby3d/core/math/vector'
require 'ruby3d/core/math/ray'

include Math

module Ruby3d
  module Core
    module Math
      class Sphere
        attr_reader :radius
        attr_reader :center
        def initialize(center, radius)
          @center = center
          @radius = radius
        end

        def intersect(ray, t0, tf, intersection_info)
          d = ray.position
          e = ray.origin
          c = center

          discriminant = (d.dot_product3(e - c)) ** 2 - (d.dot_product3 d) * ((e - c).dot_product3(e - c) - radius * radius)

          return false if discriminant < 0

          m = d.dot_product3(e - c)
          n = d.dot_product3 d

          t1 = (-m + sqrt(discriminant)) / n
          t2 = (-m - sqrt(discriminant)) / n
          min_t = [t1, t2].min
          max_t = [t1, t2].max
          
          if min_t >= t0
            if min_t <= tf
              intersection_info.object = self
              intersection_info.info.x = min_t
              return true
            end
            false
          else
            if max_t >= t0
              if max_t <= tf
                intersection_info.object = self
                intersection_info.info.x = max_t
                return true
              end
            end
            false
          end
        end
        
        def to_s
          "Sphere\nCenter: #{@center}\n" \
          "Radius: #{@radius}\n"          
        end
      end      
    end
  end
end