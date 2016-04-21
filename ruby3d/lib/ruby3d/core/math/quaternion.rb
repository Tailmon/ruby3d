# Class Quaternion, this class represents a Quaternion
# quaternion.rb
# Pablo Sanabria Quispe
require 'ruby3d/core/math/vector'
require 'ruby3d/core/math/matrix'

module Ruby3d::Core::Math
  class Quaternion
    attr_accessor :vector
    attr_accessor :scalar

    def initialize(x = 0.0, y = 0.0, z = 0.0, w = 0.0)
      @vector = Vector3d.new(x, y, z)
      @scalar = w
    end

    def +(other)
      respV = other.vector + @vector
      respS = other.scalar + @scalar
      Quaternion.new(respV.x, respV.y, respV.z, respS)
    end

    def *(other)
      if (other.is_a? Quaternion)
        respV = @scalar * other.vector + other.scalar * @vector + @vector.cross_product(other.vector)
        respS = @scalar * other.scalar - @vector * other.vector

        return Quaternion.new(respV.x, respV.y, respV.z, respS)
      elsif (other.is_a? Vector3d)
        uv_x = @vector.y * other.z - @vector.z * other.y
        uv_y = @vector.z * other.x - @vector.x * other.z
        uv_z = @vector.x * other.y - @vector.y * other.x

        uuv_x = @vector.y * uv_z - @vector.z * uv_y
        uuv_y = @vector.z * uv_x - @vector.x * uv_z
        uuv_z = @vector.x * uv_y - @vector.y * uv_x
        uv_x = 2 * @scalar * uv_x
        uv_y = 2 * @scalar * uv_y
        uv_z = 2 * @scalar * uv_z

        uuv_x = 2 * uuv_x
        uuv_y = 2 * uuv_y
        uuv_z = 2 * uuv_z

        return Vector.new(other.x + uv_x + uuv_x,
                          other.y + uv_y + uuv_y,
                          other.z + uv_z + uuv_z)
      else
        respV = other * @vector
        respS = @scalar * other

        return Quaternion.new(respV.x, respV.y, respV.z, respS)
      end
    end

    def sqr_length
      @vector.sqr_length + @scalar * @scalar
    end

    def length
      Math.sqrt(sqr_length)
    end

    def conjugate
      Quaternion.new(-@vector.x, -@vector.y, -@vector.z, @scalar)
    end

    def conjugate!
      @vector.negate!
    end

    def inverse
      temp_length = sqr_length
      conjugate * (1.0 / temp_length)
    end

    def inverse!
      temp_length = sqr_length
      @vector = @vector.negate / temp_length
      @scalar = @scalar / temp_length
    end

    def to_matrix
      matrix = Matrix.new
      x = @vector.x
      y = @vector.y
      z = @vector.z
      w = @scalar

      matrix[0, 0] = 1 - 2 * y * y - 2 * z * z
      matrix[0, 1] = 2 * x * y + 2 * z * w
      matrix[0, 2] = 2 * x * z - 2 * y * w
      matrix[1, 0] = 2 * x * y - 2 * z * w
      matrix[1, 1] = 1 - 2 * x * x - 2 * z * z
      matrix[1, 2] = 2 * y * z + 2 * x * w
      matrix[2, 0] = 2 * x * z + 2 * y * w
      matrix[2, 1] = 2 * y * z - 2 * x * w
      matrix[2, 2] = 1 - 2 * x * x - 2 * y * y

      matrix
    end

    def dot_product(q2)
       @vector * q2.vector + @scalar * q2.scalar
    end

    def coerce(another)
      [self, another]
    end

    def Quaternion.rotation(axis, angle)
      unit_axis = axis.normalize
      Quaternion.new(unit_axis.x * Math::sin(angle / 2), unit_axis.y * Math::sin(angle / 2), unit_axis.z * Math::sin(angle / 2), Math::cos(angle / 2))
    end

    def Quaternion.matrix_to_quaternion(matrix)
      trace = matrix[0, 0] + matrix[1, 1] + matrix[2, 2]

      if (trace > 0.0)
        s = Math.sqrt(trace + 1.0)
        t = 0.5 / s
        return Quaternion.new((matrix[2, 1] - matrix[1, 2]) * t, (matrix[0, 2] - matrix[2, 0]) * t, (matrix[1, 0] - matrix[0, 1]) * t, s * 0.5)
      else
        i = 0

        if (matrix[1, 1] > matrix[0, 0])
          i = 1
        end

        if (matrix[2, 2] > matrix[i, i])
          i = 2
        end

        the_next = [1, 2, 0]
        j = the_next[i]
        k = the_next[j]

        s = Math.sqrt((matrix[i, i] - (matrix[j, j] + matrix[k, k])) + 1.0)
        q = Array.new(4) {0}
        q[i] = s * 0.5
        t = 0
        if (s != 0.0)
          t = 0.5 / s
        else
          t = s
        end
        q[3] = (matrix[k, j] - matrix[j, k]) * t
        q[j] = (matrix[j, i] + matrix[i, j]) * t
        q[k] = (matrix[k, i] + matrix[i, k]) * t
        return Quaternion.new(q[0], q[1], q[2], q[3])
      end
    end

    def Quaternion.lerp(qa, qb, beta)
      qLerp = (1 - beta) * qa + beta * qb
      qLerp * (1.0 / qLerp.length)
    end

    def Quaternion.slerp(qa, qb, beta)
      angle = Math.acos(qa.dot_product(qb))
      wp = Math.sin((1 - beta) * angle) / Math.sin(angle)
      wq = Math.sin(beta * angle) / Math.sin(angle)
      resp = wp * qa + wq * qb
      resp * (1.0 / resp.length)
    end
  end
end