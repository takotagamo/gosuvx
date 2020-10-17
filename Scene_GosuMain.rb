
class MySprite
    attr_accessor :x, :y, :z

    def initialize(width, height, c)
        @x = 0
        @y = 0
        @z = 0
        @width = width
        @height = height
        @color = c
    end

    def draw
        x2 = @x + @width - 1
        y2 = @y + @height - 1

        Gosu::draw_triangle @x, @y, Gosu::Color::RED, @x, y2, Gosu::Color::GREEN, x2, y2, Gosu::Color::BLUE, @z
    end
end

class MyWin < Gosu::Window
    def initialize
        super

        @img = MySprite.new(64, 64, Gosu::Color::GREEN)
        @img.x = 64
        @img.y = 64
        @img.z = 0

        @img2 = MySprite.new(64, 64, Gosu::Color::RED)
        @img2.x = 128
        @img2.y = 128
        @img2.z = 1
    end

    def button_up(id)
        case id
        when Gosu::KB_W
            @img.y -= 8
            @img2.y += 8
        when Gosu::KB_A
            @img.x -= 8
            @img2.x += 8
        when Gosu::KB_S
            @img.y += 8
            @img2.y -= 8
        when Gosu::KB_D
            @img.x += 8
            @img2.x -= 8
        when Gosu::KB_Q
            self.close!
        end
    end

    def button_down(id)
        case id
        when Gosu::KB_W
            @img.y -= 8
            @img2.y += 8
        when Gosu::KB_A
            @img.x -= 8
            @img2.x += 8
        when Gosu::KB_S
            @img.y += 8
            @img2.y -= 8
        when Gosu::KB_D
            @img.x += 8
            @img2.x -= 8
        end
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
  