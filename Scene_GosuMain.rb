
class MySprite
    attr_accessor :x, :y, :z, :width, :height

    def initialize(width, height, z)
        @x = 0
        @y = 0
        @z = z
        @width = width
        @height = height
    end

    def draw
        x2 = @x + @width - 1
        y2 = @y + @height - 1

        Gosu::draw_triangle @x, @y, Gosu::Color::RED, @x, y2, Gosu::Color::GREEN, x2, y2, Gosu::Color::BLUE, @z
    end

    def collide?(rect)
        @x <= rect.x + rect.width - 1 and @y <= rect.y + rect.height - 1 and
            @x + @width > rect.x and @y + @height > rect.y
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

        @img = MySprite.new(64, 64, 1)
        @img.x = 64
        @img.y = 64

        @imgs = (0...16).map {|i|
            img = MySprite.new(64, 64, 2)
            img.x = rand(width - 64)
            img.y = rand(height - 64)

            img
        }

        @imgs[0].z = 0
    end

    def player_hide_exit?
        @imgs.any? {|i| i.z < @img.z and i.collide?(@img) }
    end

    def control(id, n)
        case id
        when Gosu::GP_UP
            @img.y -= n
        when Gosu::GP_LEFT
            @img.x -= n
        when Gosu::GP_DOWN
            @img.y += n
        when Gosu::GP_RIGHT
            @img.x += n
        when Gosu::GP_BUTTON_2
            return (not player_hide_exit?)
        when Gosu::MS_LEFT
            return (not player_hide_exit?)
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
        @img.y -= 2 if Gosu::button_down?(Gosu::GP_UP)
        @img.y += 2 if Gosu::button_down?(Gosu::GP_DOWN)

        @imgs.each {|i|
            i.x = GosuVx::clamp(0, width - i.width, i.x + rand(3) - 1)
            i.y = GosuVx::clamp(0, height - i.height, i.y + rand(3) - 1)
        }
    end

    def draw
        super

        Gosu::draw_rect 0, 0, width, height, Gosu::Color::BLACK
        @img.draw
        @imgs.each {|i| i.draw }
    end
end

class Scene_GosuMain < Scene_Base
    def initialize(win = nil, next_scene = nil)
        # $gosu_vmouse_enabled = true
        @next_scene = next_scene

        @win_cls = win
        @win = nil
    end

    def start
        super

        if @win_cls.is_a?(Gosu::Window)
            @win = @win_cls
        elsif @win_cls.is_a?(Class)
            @win = @win_cls.new
        else
            @win = Gosu::Window.new
        end
    end

    def post_start
        super
    end

    def update
        super

        @win.show

        if @next_scene.nil?
            $scene = Scene_Title.new
        elsif @next_scene.is_a?(Scene_Base)
            $scene = @next_scene
        else
            $scene = @next_scene.new
        end
    end

    def pre_terminate
        super
    end

    def terminate
        super

        @win._dispose if not @win_cls.is_a?(Gosu::Window)
        @win = nil
    end

end
