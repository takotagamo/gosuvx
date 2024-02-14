class GosuVx_Scene_Base
    def main
        start
        Graphics.transition
        post_start
        while $scene == self
            update
        end
        pre_terminate
        terminate
    end

    def start
    end

    def post_start
    end

    def update
    end

    def terminate
    end

    def pre_terminate
    end
end    

Scene_Base = GosuVx_Scene_Base if RUBY_VERSION == "1.8.1"


class MySprite  
    attr_accessor :x, :y, :z, :width, :height

    def initialize(width, height, z)
        @x = 0
        @y = 0
        @z = z
        @width = width + z
        @height = height + z
        @c1 = Gosu::Color.rgba(255, 0, 0, 127)
        @c2 = Gosu::Color.rgba(0, 255, 0, 127)
        @c3 = Gosu::Color.rgba(0, 0, 255, 127)
    end

    def draw
        right = @x + @width - 1
        bottom = @y + @height - 1

        x1, y1 = @x, @y
        x2, y2 = @x, bottom
        x3, y3 = right, bottom

        if rand(8) == 0
            @c2.alpha = 127 + rand(2) * 64

            if @z == 0
                @c1.alpha = 127 + rand(2) * 64
            else
                @c3.alpha = 127 + rand(2) * 64
            end
        end

        Gosu::draw_triangle x1, y1, @c1, x2, y2, @c2, x3, y3, @c3, @z
    end

    def collide?(rect)
        @x <= rect.x + rect.width - 1 and @y <= rect.y + rect.height - 1 and
            @x + @width > rect.x and @y + @height > rect.y
    end
end

class MyTextSprite < MySprite
    def initialize(text, width, height, z = 0, c = nil)
        super width, height, z

        if c.nil?
            @c = Gosu::Color::GREEN
        else
            @c = c
        end
        
        @img = Gosu::Image.from_text(text, height, { :width => width })
        @i = 1.0
        @d = 0.0078125
    end

    def draw
        @img.draw @x, @y, @z, @i, @i

        @i = @i + @d

        if @i > 2 or @i <= 0
            @d = -@d
        end
    end
end

class MyImageSprite < MySprite
    def initialize(filename, z = 0)
        img = Gosu::Image.new(filename)

        super img.width, img.height, z
        
        @img  = img
        @i = 0
    end

    def draw
        2.times {|i|
            j = (i + 1) * 8
            @img.draw_rot(@x + j, @y + j, @z + i, @i)
        }

        @i = (@i + 4) % 360
    end
end

class MyWin < Gosu::Window
    def initialize(width = Graphics.width, height = Graphics.height, options = {})
        super(width, height, options)

        @txtimg = MyTextSprite.new("find it", 128, 16, 2)
        @txtimg.x = 128
        @txtimg.y = 128

        @img = MyImageSprite.new("Graphics/Pictures/image.png", 1)
        @img.x = 64
        @img.y = 64

        @imgs = (0...16).map {|i|
            img = MySprite.new(64, 64, rand($gosu_zdepth - 1) + 1)
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
        super

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
        Gosu::draw_rect 0, 0, width, height, Gosu::Color::BLACK
        @img.draw
        @txtimg.draw
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

        # if reuse this window in RPG Maker-style
        # @win._activate
    end

    def update
        super

        ## Gosu-style (fast, modal)
        @win.show

        ## RPG Maker-style (slow(?), modeless)
        # @win.update
        # return if @win._opened

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

        GosuVx::dispose_cache
        GosuVx::dispose_images
        @win = nil
    end

end
