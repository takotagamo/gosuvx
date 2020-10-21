
module GosuVx
    def self.min(a, b)
        if a < b then a else b end
    end

    def self.max(a, b)
        if a < b then b else a end
    end

    def self.clamp(min, max, v)
        if v < min then
            min
        elsif v > max then
            max
        else
            v
        end
    end
end

module Gosu
    GP_LEFT = Input::LEFT
    GP_RIGHT = Input::RIGHT
    GP_UP = Input::UP
    GP_DOWN = Input::DOWN
    GP_BUTTON_0 = Input::A
    GP_BUTTON_1 = Input::B
    GP_BUTTON_2 = Input::C
    GP_BUTTON_3 = Input::X
    GP_BUTTON_4 = Input::Y
    GP_BUTTON_5 = Input::Z
    GP_BUTTON_6 = Input::L
    GP_BUTTON_7 = Input::R

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
    KB_F5 = Input::F5
    KB_F6 = Input::F6
    KB_F7 = Input::F7
    KB_F8 = Input::F8
    KB_F9 = Input::F9

    # what id is safe?
    MS_LEFT = 0.1
    MS_RIGHT = 0.2

    def self.available_width(win = nil)
        640
    end

    def self.available_height(win = nil)
        480
    end

    def self.button_down?(id)
        $gosu_buttons.include?(id) and Input::press?(id)
    end

    def self.fps
        Graphics.frame_rate
    end

    def self.draw_rect(x, y, width, height, c, z = 0)
        $gosu_window._layer(z).bitmap.fill_rect x, y, width, height, c
    end

    def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0)
        Gosu::_draw_line x1, y1, c1, x2, y2, c2, $gosu_window._layer(z).bitmap
    end

    def self._draw_line(x1, y1, c1, x2, y2, c2, bitmap)
        if c1 == c2
            if x1 == x2
                Gosu::draw_rect x1, GosuVx::min(y1, y2), 1, GosuVx::max(y1, y2), c1

                return
            elsif y1 == y2
                Gosu::draw_rect GosuVx::min(x1, x2), y1, GosuVx::max(x1, x2), 1, c1

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

        (n + 1).times {|i|
            x, y = (x1 + ux * i).floor, (y1 + uy * i).floor
            c = Gosu::Color.argb((a1 + ua * i).floor, (r1 + ur * i).floor, (g1 + ug * i).floor, (b1 + ub * i).floor)

            bitmap.set_pixel x, y, c
        }
    end

    def self.draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z = 0)
        rect = Gosu::_get_triangle_rect(x1, y1, x2, y2, x3, y3)
        left = rect.x
        top = rect.y
        rect.x = 0
        rect.y = 0

        x1 -= left
        x2 -= left
        x3 -= left
        y1 -= top
        y2 -= top
        y3 -= top

        if x2 < x1 and x1 < x3
            x1, y1, c1,  x2, y2, c2 = x2, y2, c2,  x1, y1, c1
        elsif x3 < x2 and x2 < x1
                x1, y1, c1,  x2, y2, c2,  x3, y3, c3 = x3, y3, c3,  x2, y2, c2,  x1, y1, c1
        elsif x3 < x2 and x2 < x1
            x1, y1, c1,  x3, y3, c3 = x3, y3, c3,  x1, y1, c1
        end

        cacheKey = "#{x1},#{y1},#{c1.gl};#{x2},#{y2},#{c2.gl};#{x3},#{y3},#{c3.gl}"
        caches = $gosu_caches

        cache = caches.find {|i| i.key == cacheKey }

        if not cache.nil?
            caches.delete(cache)
            caches.insert 0, cache
        else
            if caches.size >= $gosu_caches_size
                cache = caches.pop
                cache.dispose
                cache = nil
            end

            cache = GosuVx::Cache.new(cacheKey, rect)
            caches = caches.insert(0, cache)

            Gosu::_draw_triangle x1, y1, c1, x2, y2, c2, x3, y3, c3, cache.bitmap
        end

        $gosu_window._layer(z).bitmap.blt left, top, cache.bitmap, rect
    end

    def self._get_triangle_rect(x1, y1, x2, y2, x3, y3)
        xs = [x1, x2, x3].sort
        ys = [y1, y2, y3].sort

        Rect.new(xs[0], ys[0], xs[2] - xs[0] + 1, ys[2] - ys[0] + 1)
    end

    def self._draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, bitmap)
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

            Gosu::_draw_line((x1 + ux * i).floor, (y1 + uy * i).floor, c, x3, y3, c3, bitmap)
        }
    end
end

class GosuVx::Cache
    attr_reader :key, :bitmap

    def initialize(key, rect)
        @key = key
        @bitmap = Bitmap.new(rect.width, rect.height)
    end

    def dispose
        @bitmap.dispose
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
        Gosu::Color._gatherGl(alpha.floor, red.floor, green.floor, blue.floor)
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
    def self.from_text(text, line_height, options = {})
        if options[:width].nil?
            rect = $gosu_window._layers(0).text_size(text)

            width = line_height * (rect.width / rect.height)
        else
            width = options[:width]
        end

        result = Gosu::Image.new(nil, {
            :rect => {
                :x => 0, :y => 0,
                :width => width,
                :height => line_height
            }
        })

        # redraw with different font when called .draw with different color
        result._bitmap.draw_text result._bitmap.rect, text

        result
    end

    attr_reader :_bitmap

    def initialize(source = nil, options = {})
        if source.nil?
            size = if options[:rect].nil? then
                { :width => 640, :height => 480 }
            else
                options[:rect]
            end

            @_bitmap = Bitmap.new(size[:width], size[:height])
        else
            @_bitmap = Bitmap.new(source)
        end
    end

    def subimage(left, top, width, height)
        result = Gosu::Image.new(width, height)
        result.blt 0, 0, @_bitmap, Rect.new(left, top, width, height)

        result
    end

    def draw(x, y, z, scale_x = 1, scale_y = 1, color = 0xFFFFFFFF)
        dest = Rect.new(x, y, @_bitmap.width * scale_x, @_bitmap.height * scale_y)

        $gosu_window._layer(z).bitmap.stretch_blt dest, @_bitmap, @_bitmap.rect
    end
end


# accepts only $gosu_song_length ms files
class Gosu::Song
    @@current_song = nil

    def self.current_song
        @@current_song
    end

    def self._update
        return if @@current_song.nil? 
            
        song = @@current_song

        if song.playing and not song._first_frame.nil?
            if song._first_frame >= Graphics.frame_count - $gosu_song_length
                song.stop
            end
        end
    end

    def initialize(window, filename = nil)
        if filename.nil?
            filename = window
        end

        @filename = filename
        @playing = false
        @paused = true
        @volume = 1
        @first_frame = nil
    end

    def playing?
        @playing
    end

    def play(looping = false)
        Audio.bgm_play @filename, @volume

        if not looping
            @first_frame = Graphics.frame_count
        end

        @@current_song = self
    end

    def paused?
        @paused
    end

    # con not resume
    def pause
        Audio.bgm_stop
        @paused = true
        @playing = false
        @first_frame = -1
    end

    def stop
        Audio.bgm_stop
        @playing = false
        @first_frame = -1

        @@current_song = nil
    end
end


class Gosu::Window
    def initialize(width = -1, height = -1, options = {})
        @original_frame_rate = Graphics.frame_rate
        if not options[:update_interval].nil?
            update_interval = options[:update_interval]
        end

        @resizable = (not options[:resizable].nil?) and options[:resizable]

        # always ignores options[:fullscreen]

        width = Graphics.width if width < 0
        height = Graphics.height if height < 0
        @original_width = Graphics.width
        @original_height = Graphics.height
        Graphics.resize_screen width, height

        @needs_close = false
    
        @layers = []

        $gosu_layers = GosuVx::clamp(1, 16, $gosu_layers)
        $gosu_layers.times {|i|
            layer = Sprite.new
            layer.bitmap = Bitmap.new(640, 480)
            layer.x = 0
            layer.y = 0
            layer.z = i

            @layers.push layer
        }

        @mouse_x = 0
        @mouse_y = 0

        if $gosu_vmouse_enabled
            $gosu_vmouse = Sprite.new
            $gosu_vmouse.bitmap = Bitmap.new(4, 4)
            $gosu_vmouse.bitmap.fill_rect 0, 0, 4, 4, Color.new(255, 255, 255)
            $gosu_vmouse.bitmap.fill_rect 1, 1, 3, 3, Color.new(127, 127, 127)
            $gosu_vmouse.bitmap.clear_rect 2, 2, 2, 2
            $gosu_vmouse.x = 0
            $gosu_vmouse.y = 0
            $gosu_vmouse.z = $gosu_layers

            $gosu_buttons = $gosu_buttons_all.dup.find_all { |i| not $gosu_buttons_vmouse.include?(i) }
        else
            $gosu_buttons = $gosu_buttons_all
        end

        @button_stats = {}

        $gosu_buttons_all.each {|i|
            @button_stats[i] = false
        }

        $gosu_caches.clear

        $gosu_window = self
    end

    # Maker's Bitmap
    def _layer(z)
        z = GosuVx::clamp(0, @layers.size - 1, z)

        @layers[z]
    end

    def _dispose
        @layers.each {|i| i.dispose }
        @layers.clear

        $gosu_vmouse.dispose if $gosu_vmouse_enabled
        $gosu_caches.clear

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
            Graphics.resize_screen GosuVx::clamp(0, Gosu::available_width, value), Graphics.height
        end
    end

    def width
        Graphics.width
    end

    def height=(value)
        if @resizable
            Graphics.resize_screen Graphics.width, GosuVx::clamp(0, Gosu::available_height, value)
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
        Graphics.frame_rate = @original_frame_rate
        width = @original_width
        height = @original_height

        @needs_close = true
    end

    def draw
        @layers.each {|i|
            i.update
        }

        $gosu_vmouse.update if $gosu_vmouse_enabled

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

    # id triggers id2 event
    def _update_button_event(id, id2)
        if Input.trigger?(id)
            @button_stats[id] = true
            self.button_down(id2)
        elsif not Input.press?(id) and @button_stats[id]
            @button_stats[id] = false
            self.button_up(id2)
        end
    end

    def show
        while not @needs_close
            self.draw
            Input.update

            if $gosu_vmouse_enabled
                @mouse_x -= $gosu_vmouse_speed if Input.press?(Input::LEFT)
                @mouse_x += $gosu_vmouse_speed if Input.press?(Input::RIGHT)
                @mouse_y -= $gosu_vmouse_speed if Input.press?(Input::UP)
                @mouse_y += $gosu_vmouse_speed if Input.press?(Input::DOWN)

                $gosu_vmouse.x = @mouse_x
                $gosu_vmouse.y = @mouse_y

                self._update_button_event Gosu::KB_X, Gosu::MS_RIGHT
                self._update_button_event Gosu::KB_Z, Gosu::MS_LEFT
            end

            $gosu_buttons.each {|i|
                self._update_button_event i, i
            }

            self.update

            Gosu::Song._update
        end

        if not Gosu::Song.current_song.nil?
            Gosu::Song.current_song.stop
        end
    end

    def close!
        self.close
    end

    attr_reader :mouse_x, :mouse_y

    # incompatible things

    # window title
    def caption=(text)
        @caption = text
    end

    def caption
        @caption
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



# can be changed before Window.new

# z depth. 
$gosu_layers = 4
# in frames. limitation: all files should have this length.
$gosu_song_length = 7200
# number of cached shapes (currently triangles-only)
$gosu_caches_size = 32
# enables virtual mouse that uses BUTTON_1/2 + UDLR 
$gosu_vmouse_enabled = false
# pixels per frame
$gosu_vmouse_speed = 2
# for light responce
$gosu_disabled_buttons = []

# for internal use

$gosu_buttons_vmouse = [
    Gosu::GP_LEFT, Gosu::GP_RIGHT, Gosu::GP_UP, Gosu::GP_DOWN,  
    Gosu::GP_BUTTON_1, Gosu::GP_BUTTON_2
]

$gosu_buttons_all = [
    Gosu::GP_LEFT, Gosu::GP_RIGHT, Gosu::GP_UP, Gosu::GP_DOWN,  
    Gosu::GP_BUTTON_0, Gosu::GP_BUTTON_1, Gosu::GP_BUTTON_2,  
    Gosu::GP_BUTTON_3, Gosu::GP_BUTTON_4, Gosu::GP_BUTTON_5,  
    Gosu::GP_BUTTON_6, Gosu::GP_BUTTON_7,  
    Gosu::KB_F5, Gosu::KB_F6, Gosu::KB_F7, Gosu::KB_F8, Gosu::KB_F9
]
$gosu_buttons = $gosu_buttons_all
$gosu_window = nil
$gosu_vmouse = nil
$gosu_caches = []
