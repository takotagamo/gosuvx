# z depth. can be changed before Window.new
$gosu_layers = 4


module Gosu
    KB_LEFT = Input::LEFT
    KB_RIGHT = Input::RIGHT
    KB_UP = Input::UP
    KB_DOWN = Input::DOWN
    KB_X = Input::B
    KB_Z = Input::C
    KB_W = Input::R
    KB_A = Input::X
    KB_S = Input::Y
    KB_D = Input::Z
    KB_Q = Input::L

    KEYS = [
        Gosu::KB_LEFT, Gosu::KB_RIGHT, Gosu::KB_UP, Gosu::KB_DOWN,
        Gosu::KB_X, Gosu::KB_Z,
        Gosu::KB_W, Gosu::KB_A, Gosu::KB_S, Gosu::KB_D,
        Gosu::KB_Q
    ]

    def self.draw_rect(x, y, width, height, c, z = 0)
        $gosu_window._layer(z).bitmap.fill_rect x, y, width, height, c
    end

    def self._min(a, b)
        if a < b then a else b end
    end

    def self._max(a, b)
        if a < b then b else a end
    end

    def self._clamp(min, max, v)
        if v < min then
            min
        elsif v > max then
            max
        else
            v
        end
    end

    def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0)
        if c1 == c2
            if x1 == x2
                Gosu::draw_rect x1, Gosu::_min(y1, y2), 1, Gosu::_max(y1, y2), c1

                return
            elsif y1 == y2
                Gosu::draw_rect Gosu::_min(x1, x2), y1, Gosu::_max(x1, x2), 1, c1

                return
            end
        end

        r1, r2 = c1.red, c2.red
        g1, g2 = c1.green, c2.green
        b1, b2 = c1.blue, c2.blue
        a1, a2 = c1.alpha, c2.alpha

        dx = x2 - x1
        dy = y2 - y1
        dr = r2 - r1
        dg = g2 - g1
        db = b2 - b1
        da = a2 - a1

        if dx.abs < dy.abs
            n = dy
        else
            n = dx
        end

        ux = dx.to_f / n
        uy = dy.to_f / n
        ur = dr.to_f / n
        ug = dg.to_f / n
        ub = db.to_f / n
        ua = da.to_f / n

        bitmap = $gosu_window._layer(z).bitmap

        (n + 1).times {|i|
            x, y = (x1 + ux * i).floor, (y1 + uy * i).floor
            c = Gosu::Color.argb((a1 + ua * i).floor, (r1 + ur * i).floor, (g1 + ug * i).floor, (b1 + ub * i).floor)

            bitmap.set_pixel x, y, c
        }
    end

    def self.draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z = 0)
        r1, r2 = c1.red, c2.red
        g1, g2 = c1.green, c2.green
        b1, b2 = c1.blue, c2.blue
        a1, a2 = c1.alpha, c2.alpha

        dx = x2 - x1
        dy = y2 - y1
        dr = r2 - r1
        dg = g2 - g1
        db = b2 - b1
        da = a2 - a1

        if dx.abs < dy.abs
            n = dy
        else
            n = dx
        end

        ux = dx.to_f / n
        uy = dy.to_f / n
        ur = dr.to_f / n
        ug = dg.to_f / n
        ub = db.to_f / n
        ua = da.to_f / n

        (n + 1).times {|i|
            c = Gosu::Color.argb((a1 + ua * i).floor, (r1 + ur * i).floor, (g1 + ug * i).floor, (b1 + ub * i).floor)

            Gosu::draw_line((x1 + ux * i).floor, (y1 + uy * i).floor, c, x3, y3, c3, z)
        }
    end
end

# hsvは後回し
class Gosu::Color < Color
    attr_reader :gl, :hue, :satulation

    def initialize(a = 255, r = 0, g = 0, b = 0)
        super(r, g, b, a)
    end

    def ==(v)
        red == v.red and green == v.green and blue == v.blue and alpha == v.alpha
    end

    def gl=(v)
        alpha, red, green, blue = Gosu::Color._splitGl(v)
    end

    def gl
        Gosu::Color._gatherGl(alpha, red, green, blue)
    end

    def self._splitGl(v)
        return (@gl >> 24) & 255, (@gl >> 16) & 255, (@gl >> 8) & 255, @gl & 255
    end

    def self._gatherGl(a, r, g, b)
        (a << 24) | (r << 16) | (g << 8) | b
    end

    def self.argb(a, r = nil, g = nil, b = nil)
        if r.nil?
            a, r, g, b = Gosu::Color._splitGl(r)
        end

        Gosu::Color.new(a, r, g, b)
    end

    def self.rgba(r, g = nil, b = nil, a = nil)
        if g.nil?
            r, g, b, a = Gosu::Color._splitGl(r)
        end

        Gosu::Color.argb(a, r, g, b)
    end
end

Gosu::Color::BLACK = Gosu::Color.argb(255, 0, 0, 0)
Gosu::Color::WHITE = Gosu::Color.argb(255, 255, 255, 255)
Gosu::Color::RED = Gosu::Color.argb(255, 255, 0, 0)
Gosu::Color::GREEN = Gosu::Color.argb(255, 0, 255, 0)
Gosu::Color::BLUE = Gosu::Color.argb(255, 0, 0, 255)


class Gosu::Image
    def initialize(source = nil, options = {})
        if source.nil?
            size = if options[:rect].nil? then
                { :width => 640, :height => 480 }
            else
                options[:rect]
            end

            @bitmap = Bitmap.new(size.width, size.height)
        else
            @bitmap = Bitmap.new(source)
        end

        $gosu_window._push_bitmap @bitmap
    end

    def subimage(left, top, width, height)
        result = Gosu::Image.new(width, height)
        result.blt 0, 0, @bitmap, Rect.new(left, top, width, height)

        result
    end

    def draw(x, y, z)
        $gosu_window._layer(z).bitmap.blt x, y, @bitmap
    end
end


class Gosu::Window
    def initialize(width = -1, height = -1, options = {})
        @original_frame_rate = Graphics.frame_rate
        if options[:update_interval] != nil
            @update_interval = options[:update_interval]
        end

        @resizable = options[:resizable] != nil and options[:resizable]

        # always ignores options[:fullscreen]

        width = Graphics.width if width < 0
        height = Graphics.height if height < 0
        @original_width = Graphics.width
        @original_height = Graphics.height
        Graphics.resize_screen width, height

        @needs_close = false

        @keys = {}

        Gosu::KEYS.each {|i|
            @keys[i] = false
        }
    
        @layers = []

        $gosu_layers = Gosu::_clamp(1, 16, $gosu_layers)
        $gosu_layers.times {|i|
            layer = Sprite.new
            layer.bitmap = Bitmap.new(640, 480)
            layer.x = 0
            layer.y = 0
            layer.z = i

            @layers.push layer
        }

        $gosu_window = self
    end

    # Maker's Bitmap
    def _layer(z)
        z = Gosu::_clamp(0, @layers.size - 1, z)

        @layers[z]
    end

    def _dispose
        @layers.each {|i| i.dispose }
        @layers.clear

        $gosu_window = nil
    end

    def update_interval=(interval)
        # ms to fps
        Graphics.frame_rate =  1000 / interval
    end

    def update_interval
        1000 / Graphics.frame_rate
    end

    def width=(value)
        if @resizable
            Graphics.resize_screen value, Graphics.height
        end
    end

    def width
        Graphics.width
    end

    def height=(value)
        if @resizable
            Graphics.resize_screen Graphics.width, value
        end
    end

    def height
        Graphics.height
    end

    def button_up(id)
    end

    def button_down(id)
    end

    def close
        false
    end

    def draw
        @layers.each {|i|
            i.update
        }

        Graphics.update

        @layers.each {|i|
            i.bitmap.clear_rect 0, 0, 640, 480
        }
    end

    def needs_redraw?
        false
    end

    def update
    end

    def resizable?
        @resizable
    end

    def show
        while not @needs_close
            self.draw
            Input.update

            Gosu::KEYS.each {|i|
                if Input.trigger?(i)
                    @keys[i] = true
                    self.button_down(i)
                elsif not Input.press?(i) and @keys[i]
                    @keys[i] = false
                    self.button_up(i)
                end
            }

            self.update
        end
    end

    def close!
        Graphics.frame_rate = @original_frame_rate
        width = @original_width
        height = @original_height

        @needs_close = true
    end

    # incompatible things

    # window title
    def caption=(text)
        @caption = text
    end

    def caption
        @caption
    end

    def mouse_x
        0
    end

    def mouse_y
        0
    end

    def text_input
        nil
    end

    def drop(filname)
    end

    def needs_cursor?
        false
    end

    def fullscreen?
        false
    end
end
