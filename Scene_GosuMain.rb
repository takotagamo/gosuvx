
class MySprite
    attr_accessor :x, :y, :z

    def initialize(width, height)
        @x = 0
        @y = 0
        @z = 0
        @width = width
        @height = height
    end

    def draw
        x2 = @x + @width - 1
        y2 = @y + @height - 1

        Gosu::draw_triangle @x, @y, Gosu::Color::RED, @x, y2, Gosu::Color::GREEN, x2, y2, Gosu::Color::BLUE, @z
    end
end

class MyTextSprite < MySprite
    def initialize(text, width, height, c = nil)
        super width, height

        if c.nil?
            @c = Gosu::Color::GREEN
        else
            @c = c
        end
        
        @img = Gosu::Image.from_text(text, height, { :width => width })
    end

    def draw
        @img.draw @x, @y, @z, 1, 1, @c
    end
end

class MyWin < Gosu::Window
    def initialize
        super

        @img = MyTextSprite.new("hi", 64, 64)
        @img.x = 64
        @img.y = 64
        @img.z = 0

        @img2 = MyTextSprite.new("hello", 64, 64)
        @img2.x = 128
        @img2.y = 128
        @img2.z = 1
    end

    def control(id, n)
        case id
        when Gosu::GP_UP
            @img.y -= n
            @img2.y += n
        when Gosu::GP_LEFT
            @img.x -= n
            @img2.x += n
        when Gosu::GP_DOWN
            @img.y += n
            @img2.y -= n
        when Gosu::GP_RIGHT
            @img.x += n
            @img2.x -= n
#        when Gosu::GP_BUTTON_2
        when Gosu::MS_LEFT
            return false
        when Gosu::KB_Q
            return false
        end

        return true
    end

    def button_up(id)
        if not control(id, 1)
            self.close
        end
    end

    def button_down(id)
        control id, 1
    end

    def update
        @img.x -= 2 if Gosu::button_down?(Gosu::GP_LEFT)
        @img.x += 2 if Gosu::button_down?(Gosu::GP_RIGHT)
    end

    def draw
        super

        Gosu::draw_rect 0, 0, width, height, Gosu::Color::BLACK
        @img.draw
        @img2.draw
    end
end

class Scene_GosuMain < Scene_Base
    def initialize(win = nil, next_scene = nil)
        $gosu_vmouse_enabled = true
        @next_scene = next_scene

        if win == nil
            @win = Gosu::Window.new
        else
            @win = win.new
        end
    end

    def start
        super
    end

    def post_start
        super
    end

    def update
        super

        @win.show

        if @next_scene.nil?
            $scene = Scene_Title.new
        else
            $scene = @next_scene.new
        end
    end

    def pre_terminate
        super
    end

    def terminate
        super

        @win._dispose
        @win = nil
    end

end
