require 'ruby3d/core/math'
require 'ruby3d/graphics/scene/geometry/geometry'
require 'opengl'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class SkeletonAnimation
    class JointInfo
      attr_accessor :name
      attr_accessor :parentID
      attr_accessor :flags
      attr_accessor :start_index
    end

    class Bound
      attr_accessor :min
      attr_accessor :max
    end

    class BaseFrame
      attr_accessor :pos
      attr_accessor :orient
    end

    class FrameData
      attr_accessor :frame_id
      attr_accessor :frame_data
    end

    class SkeletonJoint
      attr_accessor :parent
      attr_accessor :pos
      attr_accessor :orient

      def initialize(copy = nil)
        if (copy.nil?)
          @parent = -1
          @pos = Ruby3d::Core::Math::Vector3d.new
          @orient = Ruby3d::Core::Math::Quaternion.new
        else
          @pos = copy.pos
          @orient = copy.orient
        end
      end
    end

    class FrameSkeleton
      attr_accessor :joints

      def initialize
        @joints = Array.new
      end
    end

    attr_accessor :joint_infos
    attr_accessor :bounds
    attr_accessor :base_frames
    attr_accessor :frames
    attr_accessor :skeletons
    attr_accessor :animated_skeleton
    attr_accessor :num_joints

    def initialize
      @md5_version = 0
      @num_frames = 0
      @num_joints = 0
      @frame_rate = 0
      @num_animated_components = 0
      @anim_duration = 0
      @frame_duration = 0
      @anim_time = 0
      @log = Ruby3d::Core::Logger::Log.instance
      @joint_infos = Array.new
      @bounds = Array.new
      @base_frames = Array.new
      @frames = Array.new
      @skeletons = Array.new

    end

    def build_frame_skeleton(skeletons, joint_infos, base_frames, frame_data)
      skeleton = FrameSkeleton.new
      0.upto(joint_infos.length - 1) do |i|
        j = 0
        joint_info = joint_infos[i]
        animated_joint = SkeletonJoint.new base_frames[i]
        animated_joint.parent = joint_info.parentID

        if (joint_info.flags & 1 ) != 0
          animated_joint.pos.x = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        if (joint_info.flags & 2 ) != 0
          animated_joint.pos.y = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        if (joint_info.flags & 4 ) != 0
          animated_joint.pos.z = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        if (joint_info.flags & 8 ) != 0
          animated_joint.orient.vector.x = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        if (joint_info.flags & 16 ) != 0
          animated_joint.orient.vector.y = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        if (joint_info.flags & 32 ) != 0
          animated_joint.orient.vector.z = frame_data.frame_data[joint_info.start_index + j]
          j = j + 1
        end

        t = 1.0 - animated_joint.orient.vector.sqr_length
        if t < 0.0
          animated_joint.orient.scalar = 0.0
        else
          animated_joint.orient.scalar = -Math::sqrt(t)
        end

        if animated_joint.parent >= 0
          parent_joint = skeleton.joints[animated_joint.parent]
          rot_pos = parent_joint.orient * animated_joint.pos
          animated_joint.pos = parent_joint.pos + rot_pos
          animated_joint.orient = parent_joint.orient * animated_joint.orient

          animated_joint.orient * (1.0 / animated_joint.orient.length)
        end

        skeleton.joints << animated_joint
      end

      skeletons << skeleton
    end

    def interpolate_skeleton(final_skeleton, skeleton0, skeleton1, interpolate)
      0.upto(@num_joints - 1) do |i|
        final_joint = final_skeleton.joints[i]
        joint0 = skeleton0.joints[i]
        joint1 = skeleton1.joints[i]
        final_joint.parent = joint0.parent
        final_joint.pos = (1 - interpolate) * joint0.pos+  interpolate * joint1.pos
        final_joint.orient = Ruby3d::Core::Math::Quaternion::lerp(joint0.orient, joint1.orient, interpolate)
      end
    end

    def load_animation(file_name)
      @assets_config = Ruby3d::Core::Settings::Settings.instance.asset_settings
      paths = @assets_config.paths
      paths.each do |p|
        @file_name = p + '/' + file_name
        break if File::exist?(@file_name)
      end
      raise AssetError.new("The model's animation file couldn't be found") unless File::exist?(@file_name)
      raise AssetError.new("The model's animation file isn't a md5anim file") unless @file_name.end_with?('.md5anim')
      directories = file_name.split('/')
      @directory = file_name
      if directories.length > 1
        @directory = ''
        0.upto(directories.length - 3) do |i|
          @directory += directories[i] + '/'
        end
        @directory += directories[directories.length - 2]
      end

      file_path = @file_name
      self.joint_infos = Array.new
      self.bounds = Array.new
      self.base_frames = Array.new
      self.frames = Array.new
      self.animated_skeleton = FrameSkeleton.new

      File.open(file_path) do |file|
        while (line = file.gets)
          words = line.split
          param = words[0]
          if param == 'MD5Version'
              @md5_version = words[1].to_i
          elsif param == 'commandline'
            #ignorar linea
          elsif param == 'numFrames'
            @num_frames = words[1].to_i
          elsif param == 'numJoints'
            @num_joints = words[1].to_i
          elsif param == 'frameRate'
            @frame_rate = words[1].to_i
          elsif param == 'numAnimatedComponents'
            @num_animated_components = words[1].to_i
          elsif param == 'hierarchy'
            1.upto(@num_joints) do
              joint = JointInfo.new
              w = file.gets.split
              joint.name = w[0].chomp('"').reverse.chomp('"').reverse
              joint.parentID = w[1].to_i
              joint.flags = w[2].to_i
              joint.start_index = w[3].to_i
              joint_infos << joint
            end
           # gets
          elsif param == 'bounds'
            1.upto(@num_frames) do
              bound = Bound.new
              w = file.gets.split
              bound.min = Ruby3d::Core::Math::Vector3d.new(w[1].to_f, w[2].to_f, w[3].to_f)
              bound.max = Ruby3d::Core::Math::Vector3d.new(w[6].to_f, w[7].to_f, w[8].to_f)
              bounds << bound
            end
          elsif param == 'baseframe'
            1.upto(@num_joints) do
              base_frame = BaseFrame.new
              w = file.gets.split
              base_frame.pos = Ruby3d::Core::Math::Vector3d.new(w[1].to_f, w[2].to_f, w[3].to_f)
              base_frame.orient = Ruby3d::Core::Math::Quaternion.new(w[6].to_f, w[7].to_f, w[8].to_f)

              base_frames << base_frame
            end
          elsif param == 'frame'
            frame = FrameData.new
            frame.frame_id = words[1].to_i
            frame.frame_data = Array.new
            i = 0
            while i < @num_animated_components
              w = file.gets.split
              w.each do |n|
                frame.frame_data << n.to_f
                i = i + 1
              end
            end

            frames << frame
            build_frame_skeleton(skeletons, joint_infos, base_frames, frame)
          end
        end

        animated_skeleton.joints = Array.new(@num_joints) do
          SkeletonJoint.new
        end
        @frame_duration = 1.0 / @frame_rate
        @anim_duration = @frame_duration * @num_frames
        @anim_time = 0.0
        Ruby3d::Core::Logger::Log.instance.info self.class, "Model animation #{@file_name} loaded"
        return true
      end
    end

    def update(delta_time)
       if @num_frames >= 1
         @anim_time += delta_time
         while @anim_time > @anim_duration
           @anim_time -= @anim_duration
         end

         while @anim_time < 0
           @anim_time += @anim_duration
         end

         frame_num = @anim_time * @frame_rate
         frame0 = frame_num.floor
         frame1 = frame_num.ceil
         frame0 = frame0 % @num_frames
         frame1 = frame1 % @num_frames

         interpolate = @anim_time.modulo(@frame_duration) / @frame_duration
         interpolate_skeleton(animated_skeleton, skeletons[frame0], skeletons[frame1], interpolate)
       end
    end

    def render
      glPointSize(5.0)
      glColor3f(1.0, 0.0, 0.0)
      glPushAttrib(GL_ENABLE_BIT)
      glDisable(GL_LIGHTING)
      glDisable(GL_DEPTH_TEST)

      joints = animated_skeleton.joints
      glBegin(GL_POINTS)
      joints.each do |j|
        glVertex3f(j.pos.x, j.pos.y, j.pos.z)
      end
      glEnd

      glColor3f(0.0, 1.0, 0.0)
      glBegin(GL_LINES)
      joints.each do |j|
        if (j.parent != -1)
          j1 = joints[j.parent]
          glVertex3f(j.pos.x, j.pos.y, j.pos.z)
          glVertex3f(j1.pos.x, j1.pos.y, j1.pos.z)
        end
      end
      glEnd

      glPopAttrib
    end
  end
end
