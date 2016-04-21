# Matrix class, this class defines a 4x4 matrix with the basic operation around Matrix, like Addition, Product
# matrix.rb
# Author: Pablo Sanabria Quispe
require 'ruby3d/core/math/vector'
require 'ruby3d/core/math/vector4d'

include Math

module Ruby3d
  module Core
    module Math
      class Matrix
        include Comparable
        MATRIX_SIZE = 4
        def initialize(m = nil)
          if m.nil?
            @matrix = Array.new(MATRIX_SIZE) {Array.new(MATRIX_SIZE) {0}}
          else
            @matrix = Array.new(MATRIX_SIZE) {Array.new(MATRIX_SIZE) {0}}

            (0..MATRIX_SIZE - 1).each do |i|
              (0..MATRIX_SIZE - 1).each do |j|
                @matrix[i][j] = m[j][i]
              end
            end
          end

        end

        def [](row, column)
          raise IndexError unless row >= -MATRIX_SIZE && row < MATRIX_SIZE && column >= -MATRIX_SIZE && column < MATRIX_SIZE
          @matrix[row][column]
        end

        def []=(row, column, value)
          raise IndexError unless row >= -MATRIX_SIZE && row < MATRIX_SIZE && column >= -MATRIX_SIZE && column < MATRIX_SIZE
          @matrix[row][column] = value
        end

        def identity!
          (0...MATRIX_SIZE).each do |row|
          (0...MATRIX_SIZE).each do |column|
              @matrix[row][column] = 0
            end
          end
          @matrix[0][0] = 1.0
          @matrix[1][1] = 1.0
          @matrix[2][2] = 1.0
          @matrix[3][3] = 1.0
          self
        end

        def rotate_x!(angle)
          (0...MATRIX_SIZE).each do |row|
          (0...MATRIX_SIZE).each do |column|
              @matrix[row][column] = 0
            end
          end
          cos_a = cos(angle)
          sin_a = sin(angle)
          @matrix[1][1] = cos_a
          @matrix[1][2] = -sin_a
          @matrix[2][1] = sin_a
          @matrix[2][2] = cos_a
          @matrix[0][0] = @matrix[3][3] = 1.0
          self
        end

        def rotate_y!(angle)
          (0...MATRIX_SIZE).each do |row|
          (0...MATRIX_SIZE).each do |column|
              @matrix[row][column] = 0
            end
          end
          cos_a = cos(angle)
          sin_a = sin(angle)
          @matrix[0][0] = cos_a
          @matrix[0][2] = sin_a
          @matrix[2][0] = -sin_a
          @matrix[2][2] = cos_a
          @matrix[1][1] = @matrix[3][3] = 1.0
          self
        end

        def rotate_z!(angle)
          (0...MATRIX_SIZE).each do |row|
          (0...MATRIX_SIZE).each do |column|
              @matrix[row][column] = 0
            end
          end
          cos_a = cos(angle)
          sin_a = sin(angle)
          @matrix[0][0] = cos_a
          @matrix[0][1] = -sin_a
          @matrix[1][0] = sin_a
          @matrix[1][1] = cos_a
          @matrix[2][2] = @matrix[3][3] = 1.0
          self
        end

        def rotate_arbitrary!(vector, angle)
          (0...MATRIX_SIZE).each do |row|
          (0...MATRIX_SIZE).each do |column|
              @matrix[row][column] = 0
            end
          end
          sin_a = sin(angle)
          cos_a = cos(angle)
          unit = vector.normalize
          diff = 1 - cos_a

          @matrix[0][0] = cos_a + unit.x * unit.x * diff
          @matrix[0][1] = unit.x * unit.y * diff - unit.z * sin_a
          @matrix[0][2] = unit.x * unit.z * diff + unit.y * sin_a
          @matrix[1][0] = unit.y * unit.x * diff + unit.z * sin_a
          @matrix[1][1] = cos_a + unit.y * unit.y * diff
          @matrix[1][2] = unit.y * unit.z * diff - unit.x * sin_a
          @matrix[2][0] = unit.z * unit.x * diff - unit.y * sin_a
          @matrix[2][1] = unit.z * unit.y * diff + unit.x * sin_a
          @matrix[2][2] = cos_a + unit.z * unit.z * diff
          @matrix[3][3] = 1.0
          self
        end

        def translate_matrix!(displacement)
          identity!
          @matrix[3][0] = displacement.x
          @matrix[3][1] = displacement.y
          @matrix[3][2] = displacement.z
          self
        end
        
        def scale_matrix!(scale_vector)
          identity!
          @matrix[0][0] = scale_vector.x
          @matrix[1][1] = scale_vector.y
          @matrix[2][2] = scale_vector.z
          self
        end

        def transpose_of!(matrix2)
          @matrix = matrix2.transpose
          self
        end

        def determinant
          # Implementación analítica de la regla de Crammer
          f1 = @matrix[2][2] * @matrix[3][3] - @matrix[2][3] * @matrix[3][2]
          f2 = @matrix[2][1] * @matrix[3][3] - @matrix[2][3] * @matrix[3][1]
          f3 = @matrix[2][1] * @matrix[3][2] - @matrix[2][2] * @matrix[3][1]
          f4 = @matrix[2][0] * @matrix[3][3] - @matrix[2][3] * @matrix[3][0]
          f5 = @matrix[2][0] * @matrix[3][1] - @matrix[2][1] * @matrix[3][0]
          f6 = @matrix[2][0] * @matrix[3][2] - @matrix[2][2] * @matrix[3][0]

          a00 = @matrix[0][0] * (@matrix[1][1] * f1 - @matrix[1][2] * f2 + @matrix[1][3] * f3)
          a01 = @matrix[0][1] * (@matrix[1][0] * f1 - @matrix[1][2] * f4 + @matrix[1][3] * f6)
          a03 = @matrix[0][2] * (@matrix[1][0] * f2 - @matrix[1][1] * f4 + @matrix[1][3] * f5)
          a04 = @matrix[0][3] * (@matrix[1][0] * f3 - @matrix[1][1] * f6 + @matrix[1][2] * f5)

          a00 - a01 + a03 - a04
        end

        def inverse_of!(matrix2)
          fa0 = matrix2[0, 0] * matrix2[1, 1] - matrix2[0, 1] * matrix2[1, 0]
          fa1 = matrix2[0, 0] * matrix2[1, 2] - matrix2[0, 2] * matrix2[1, 0]
          fa2 = matrix2[0, 0] * matrix2[1, 3] - matrix2[0, 3] * matrix2[1, 0]
          fa3 = matrix2[0, 1] * matrix2[1, 2] - matrix2[0, 2] * matrix2[1, 1]
          fa4 = matrix2[0, 1] * matrix2[1, 3] - matrix2[0, 3] * matrix2[1, 1]
          fa5 = matrix2[0, 2] * matrix2[1, 3] - matrix2[0, 3] * matrix2[1, 2]
          fb0 = matrix2[2, 0] * matrix2[3, 1] - matrix2[2, 1] * matrix2[3, 0]
          fb1 = matrix2[2, 0] * matrix2[3, 2] - matrix2[2, 2] * matrix2[3, 0]
          fb2 = matrix2[2, 0] * matrix2[3, 3] - matrix2[2, 3] * matrix2[3, 0]
          fb3 = matrix2[2, 1] * matrix2[3, 2] - matrix2[2, 2] * matrix2[3, 1]
          fb4 = matrix2[2, 1] * matrix2[3, 3] - matrix2[2, 3] * matrix2[3, 1]
          fb5 = matrix2[2, 2] * matrix2[3, 3] - matrix2[2, 3] * matrix2[3, 2]
          
          matrix = Array.new(MATRIX_SIZE) {Array.new(MATRIX_SIZE) {0}}

          matrix[0][0] = +matrix2[1, 1] * fb5 - matrix2[1, 2] * fb4 + matrix2[1, 3] * fb3
          matrix[1][0] = -matrix2[1, 0] * fb5 + matrix2[1, 2] * fb2 - matrix2[1, 3] * fb1
          matrix[2][0] = +matrix2[1, 0] * fb4 - matrix2[1, 1] * fb2 + matrix2[1, 3] * fb0
          matrix[3][0] = -matrix2[1, 0] * fb3 + matrix2[1, 1] * fb1 - matrix2[1, 2] * fb0
          matrix[0][1] = -matrix2[0, 1] * fb5 + matrix2[0, 2] * fb4 - matrix2[0, 3] * fb3
          matrix[1][1] = +matrix2[0, 0] * fb5 - matrix2[0, 2] * fb2 + matrix2[0, 3] * fb1
          matrix[2][1] = -matrix2[0, 0] * fb4 + matrix2[0, 1] * fb2 - matrix2[0, 3] * fb0
          matrix[3][1] = +matrix2[0, 0] * fb3 - matrix2[0, 1] * fb1 + matrix2[0, 2] * fb0
          matrix[0][2] = +matrix2[3, 1] * fa5 - matrix2[3, 2] * fa4 + matrix2[3, 3] * fa3
          matrix[1][2] = -matrix2[3, 0] * fa5 + matrix2[3, 2] * fa2 - matrix2[3, 3] * fa1
          matrix[2][2] = +matrix2[3, 0] * fa4 - matrix2[3, 1] * fa2 + matrix2[3, 3] * fa0
          matrix[3][2] = -matrix2[3, 0] * fa3 + matrix2[3, 1] * fa1 - matrix2[3, 2] * fa0
          matrix[0][3] = -matrix2[2, 1] * fa5 + matrix2[2, 2] * fa4 - matrix2[2, 3] * fa3
          matrix[1][3] = +matrix2[2, 0] * fa5 - matrix2[2, 2] * fa2 + matrix2[2, 3] * fa1
          matrix[2][3] = -matrix2[2, 0] * fa4 + matrix2[2, 1] * fa2 - matrix2[2, 3] * fa0
          matrix[3][3] = +matrix2[2, 0] * fa3 - matrix2[2, 1] * fa1 + matrix2[2, 2] * fa0

          det = matrix2.determinant
          raise ZeroDivisionError if det == 0
          @matrix = matrix
          @matrix = (self * (1.0 / det)).matrix
          self
        end
        
        def inverse
          resp = Matrix.new
          resp.inverse_of! self
        end

        def *(other)
          if other.is_a? Matrix
            n = MATRIX_SIZE
            c = Matrix.new
            0.upto(n - 1) do |i|
              0.upto(n - 1) do |j|
                0.upto(n - 1) do |k|
                c[i, j] += self[i, k] * other[k, j]
                end
              end
            end
            c
          elsif other.is_a? Vector
            x = Vector4d.new(@matrix[0][0], @matrix[0][1], @matrix[0][2], @matrix[0][3]) * other
            y = Vector4d.new(@matrix[1][0], @matrix[1][1], @matrix[1][2], @matrix[1][3]) * other
            z = Vector4d.new(@matrix[2][0], @matrix[2][1], @matrix[2][2], @matrix[2][3]) * other
            w = Vector4d.new(@matrix[3][0], @matrix[3][1], @matrix[3][2], @matrix[3][3]) * other
            Vector.new(x, y, z, w)
          else
            c = Matrix.new
            c.matrix = @matrix.map {|row| row.map {|elem| elem * other}}
            c
          end
        end

        def ==(other)
          if other.is_a? Matrix
            return @matrix == other.matrix
          end
          false
        end

        def eql?(other)
          if other.is_a? Matrix
            return @matrix.eql? other.matrix
          end
          false
        end

        def hash
          @matrix.hash
        end

        def <=>(other)
          return nil unless other.is_a? Matrix
          @matrix <=> other.matrix
        end

        def coerce(another)
          [self, another]
        end
        
        def to_s
          s = "Matrix:\n("
          @matrix.each do |row|
            row.each do |elem|
              s += "#{elem}\t"
            end
            s += "\n"
          end
          s + ")\n"
        end
        protected
        attr_accessor :matrix
      end
    end
  end
end
