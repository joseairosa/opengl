require 'opengl'
require 'chunky_png'

class Lesson11
  include Gl
  include Glu
  include Glut

  def initialize
    @textures = nil
    @xrot = 0.0
    @yrot = 0.0
    @zrot = 0.0

    factor = 10.0 / 9 * Math::PI
    @points = Array.new 45 do |x|
      Array.new 45 do |y|
        [x / 5.0 - 4.5, y / 5.0 - 4.5,
         Math.sin(x / factor)]
      end
    end

    @wiggle_count = 0

    glutInit

    glutInitDisplayMode GLUT_RGB | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH
    glutInitWindowSize 640, 480
    glutInitWindowPosition 0, 0

    @window = glutCreateWindow "NeHe Lesson 11 - ruby-opengl version"

    glutDisplayFunc :draw_gl_scene
    glutReshapeFunc :reshape
    glutIdleFunc :idle
    glutKeyboardFunc :keyboard

    reshape 640, 480
    load_texture
    init_gl

    glutMainLoop
  end

  def init_gl
    glEnable GL_TEXTURE_2D
    glShadeModel GL_SMOOTH
    glClearColor 0.0, 0.0, 0.0, 0.5
    glClearDepth 1.0
    glEnable GL_DEPTH_TEST
    glDepthFunc GL_LEQUAL
    glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

    glPolygonMode GL_BACK, GL_FILL
    glPolygonMode GL_FRONT, GL_LINE

    true
  end

  def reshape width, height
    width   = width.to_f
    height = height.to_f
    height = 1.0 if height.zero?

    glViewport 0, 0, width, height

    glMatrixMode GL_PROJECTION
    glLoadIdentity

    gluPerspective 45.0, width / height, 0.1, 100.0

    glMatrixMode GL_MODELVIEW
    glLoadIdentity

    true
  end

  def draw_gl_scene
    glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    glLoadIdentity

    glTranslatef 0.0, 0.0, -12.0
    glRotatef @xrot, 1.0, 0.0, 0.0
    glRotatef @yrot, 0.0, 1.0, 0.0
    glRotatef @zrot, 0.0, 0.0, 1.0

    glBindTexture GL_TEXTURE_2D, @textures[0]

    glBegin GL_QUADS do
      (0...44).each do |x|
        (0...44).each do |y|
          tex_x = x / 44.0
          tex_y = y / 44.0
          tex_xb = (x + 1) / 44.0
          tex_yb = (y + 1) / 44.0

          glTexCoord2f tex_x, tex_y
          glVertex3f @points[x][y][0], @points[x][y][1], @points[x][y][2]

          glTexCoord2f tex_x, tex_yb
          glVertex3f @points[x][y+1][0], @points[x][y+1][1], @points[x][y+1][2]

          glTexCoord2f tex_xb, tex_yb
          glVertex3f @points[x+1][y+1][0], @points[x+1][y+1][1], @points[x+1][y+1][2]

          glTexCoord2f tex_xb, tex_y
          glVertex3f @points[x+1][y][0], @points[x+1][y][1], @points[x+1][y][2]
        end
      end
    end

    if @wiggle_count == 4 then
      (0...45).each do |y|
        tmp = @points[0][y][2]
        (0...44).each do |x|
          @points[x][y][2] = @points[x+1][y][2]
        end
        @points[44][y][2] = tmp
      end

      @wiggle_count = 0
    end

    @wiggle_count += 1

    @xrot += 0.03
    @yrot += 0.02
    @zrot += 0.04

    glutSwapBuffers
  end

  def idle
    glutPostRedisplay
  end

  def keyboard key, x, y
    case key
    when ?\e
      glutDestroyWindow @window
      exit 0
    when 'F' then 
      @fullscreen = !@fullscreen

      if @fullscreen then
        glutFullScreen
      else
        glutPositionWindow 0, 0
      end
    end

    glutPostRedisplay
  end

  def load_texture
    png = ChunkyPNG::Image.from_file(File.expand_path('../tim.png', __FILE__))

    height = png.height
    width = png.width

    image = png.to_rgba_stream.each_byte.to_a

    @textures = glGenTextures 1
    glBindTexture GL_TEXTURE_2D, @textures[0]
    glTexImage2D GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image
    glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
    glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
  end

end

Lesson11.new

